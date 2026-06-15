#!/usr/bin/env sh
set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/gatling-max-summary.XXXXXX")
trap 'rm -rf "$TMP_ROOT"' EXIT

mkdir -p "$TMP_ROOT/scripts"
cp "$REPO_ROOT/scripts/run-gatling-max-limit" "$TMP_ROOT/scripts/run-gatling-max-limit"

cat > "$TMP_ROOT/scripts/run-gatling-container" <<'SH'
#!/usr/bin/env sh
set -eu

OUTPUT_DIR="output/gatling/max-limit"
mkdir -p "$OUTPUT_DIR/raw/fake-run"

printf '%s|%s|%s|%s|%s\n' \
  "$GATLING_MAX_BASE_USERS" \
  "$GATLING_MAX_STEP_USERS" \
  "$GATLING_MAX_LIMIT_USERS" \
  "$GATLING_MAX_DURATION_SECONDS" \
  "$GATLING_MAX_RAMP_SECONDS" >> "$OUTPUT_DIR/raw/calls.log"

printf '%s\n' '<html>fake report</html>' > "$OUTPUT_DIR/index.html"
cat > "$OUTPUT_DIR/simulation.log" <<'LOG'
RUN	MetaSimulation	metasimulation	1000000	 	3.2.1
REQUEST	1		GET /meta	1007000	1020000	KO	i.n.c.ConnectTimeoutException: connection timed out
LOG
cat > "$OUTPUT_DIR/max-limit-run.log" <<'LOG'
================================================================================
---- Global Information --------------------------------------------------------
> request count                                        42 (OK=40     KO=2     )
> max response time                                  1200 (OK=800    KO=1200  )
> mean response time                                  120 (OK=100    KO=520   )
> response time 95th percentile                       900 (OK=850    KO=1200  )
> response time 99th percentile                      1200 (OK=950    KO=1200  )
> mean requests/sec                                 1.400 (OK=1.333  KO=0.067 )
---- Response Time Distribution ------------------------------------------------
> failed                                                 2 (  4%)
================================================================================
LOG
cat "$OUTPUT_DIR/max-limit-run.log"
exit 1
SH
chmod +x "$TMP_ROOT/scripts/run-gatling-container" "$TMP_ROOT/scripts/run-gatling-max-limit"

cd "$TMP_ROOT"
set +e
OUTPUT=$(
  GATLING_CONSOLE_MODE=summary \
  APP_BASE_URL=http://example.test/meta/ \
  GATLING_MAX_BASE_USERS=10 \
  GATLING_MAX_STEP_USERS=10 \
  GATLING_MAX_LIMIT_USERS=30 \
  GATLING_MAX_DURATION_SECONDS=5 \
  ./scripts/run-gatling-max-limit 2>&1
)
STATUS=$?
set -e

if [ "$STATUS" -ne 0 ]; then
  printf '%s\n' "$OUTPUT"
  printf '%s\n' "expected max-limit discovery to exit 0, got $STATUS" >&2
  exit 1
fi

assert_contains() {
  needle="$1"
  if ! printf '%s\n' "$OUTPUT" | grep -Fq -- "$needle"; then
    printf '%s\n' "$OUTPUT"
    printf '%s\n' "missing expected output: $needle" >&2
    exit 1
  fi
}

assert_not_contains() {
  needle="$1"
  if printf '%s\n' "$OUTPUT" | grep -Fq -- "$needle"; then
    printf '%s\n' "$OUTPUT"
    printf '%s\n' "unexpected step output: $needle" >&2
    exit 1
  fi
}

assert_contains "---- Global Information"
assert_not_contains "max limit staircase started : 10-30 users/sec | step: 10 users/sec | duration: 5s per level"
assert_not_contains "max limit level finished :"
assert_contains "Max-limit test summary:"
assert_contains "  app base URL: http://example.test/meta/"
assert_contains "  parameters: range 10-30 users/sec | step 10 users/sec | duration 5s/level | ramp 0s"
assert_contains "  key result: highest passing 10 users/sec | first failing 20 users/sec"
assert_not_contains "Max-limit testing level"
assert_not_contains "Max-limit level"
assert_not_contains "  cutoff rule:"
assert_not_contains "  latency review:"
assert_not_contains "  staircase Gatling report:"

if ! grep -Fq "Max-limit test summary:" output/gatling/max-limit/raw/max-limit-discovery.log; then
  printf '%s\n' "expected wrapper summary in discovery log" >&2
  exit 1
fi
if ! grep -Fq "  app base URL: http://example.test/meta/" output/gatling/max-limit/raw/max-limit-discovery.log; then
  printf '%s\n' "expected app base URL in discovery log summary" >&2
  exit 1
fi
if ! grep -Fq "  parameters: range 10-30 users/sec | step 10 users/sec | duration 5s/level | ramp 0s" output/gatling/max-limit/raw/max-limit-discovery.log; then
  printf '%s\n' "expected concise parameters in discovery log summary" >&2
  exit 1
fi
if ! grep -Fq "  key result: highest passing 10 users/sec | first failing 20 users/sec" output/gatling/max-limit/raw/max-limit-discovery.log; then
  printf '%s\n' "expected parsed key result in discovery log" >&2
  exit 1
fi
if ! grep -Fq "command parameters: GATLING_RUN_TYPE=max-limit APP_BASE_URL=http://example.test/meta/ GATLING_MAX_START_USERS_PER_SEC=10 GATLING_MAX_STEP_USERS_PER_SEC=10 GATLING_MAX_END_USERS_PER_SEC=30 GATLING_MAX_DURATION_SECONDS=5 GATLING_MAX_RAMP_SECONDS=0" output/gatling/max-limit/raw/max-limit-discovery.log; then
  printf '%s\n' "expected exact staircase command parameters in discovery log" >&2
  exit 1
fi
if ! grep -Fq "level schedule: 10 users/sec | report time window: 0-5s" output/gatling/max-limit/raw/max-limit-discovery.log; then
  printf '%s\n' "expected first staircase time window in discovery log" >&2
  exit 1
fi
if ! grep -Fq "level schedule: 30 users/sec | report time window: 10-15s" output/gatling/max-limit/raw/max-limit-discovery.log; then
  printf '%s\n' "expected final staircase time window in discovery log" >&2
  exit 1
fi
if ! grep -Fq "10|10|30|5|0" output/gatling/max-limit/raw/calls.log; then
  printf '%s\n' "expected one staircase runner call" >&2
  exit 1
fi

set +e
RAMP_OUTPUT=$(
  GATLING_CONSOLE_MODE=summary \
  APP_BASE_URL=http://example.test/meta/ \
  GATLING_MAX_BASE_USERS=10 \
  GATLING_MAX_STEP_USERS=10 \
  GATLING_MAX_LIMIT_USERS=30 \
  GATLING_MAX_DURATION_SECONDS=5 \
  GATLING_MAX_RAMP_SECONDS=2 \
  ./scripts/run-gatling-max-limit 2>&1
)
RAMP_STATUS=$?
set -e

if [ "$RAMP_STATUS" -ne 0 ]; then
  printf '%s\n' "$RAMP_OUTPUT"
  printf '%s\n' "expected ramped max-limit discovery to exit 0, got $RAMP_STATUS" >&2
  exit 1
fi

if ! printf '%s\n' "$RAMP_OUTPUT" | grep -Fq "  key result: highest passing 10 users/sec | first failing 20 users/sec"; then
  printf '%s\n' "$RAMP_OUTPUT"
  printf '%s\n' "expected ramp transition KO to preserve boundary key result" >&2
  exit 1
fi
if ! grep -Fq "ramp schedule: 0-10 users/sec | report time window: 0-2s" output/gatling/max-limit/raw/max-limit-discovery.log; then
  printf '%s\n' "expected initial ramp schedule in discovery log" >&2
  exit 1
fi
if ! grep -Fq "ramp schedule: 10-20 users/sec | report time window: 7-9s" output/gatling/max-limit/raw/max-limit-discovery.log; then
  printf '%s\n' "expected inter-level ramp schedule in discovery log" >&2
  exit 1
fi

RUNNER_ROOT="$TMP_ROOT/runner"
mkdir -p "$RUNNER_ROOT/scripts"
cp "$REPO_ROOT/scripts/run-gatling-container" "$RUNNER_ROOT/scripts/run-gatling-container"

cat > "$RUNNER_ROOT/fake-gatling.sh" <<'SH'
#!/usr/bin/env sh
set -eu

RAW_DIR=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -rf)
      RAW_DIR="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

mkdir -p "$RAW_DIR/fake-run"
printf '%s\n' '<html>fake report</html>' > "$RAW_DIR/fake-run/index.html"

cat <<'LOG'
Simulation MetaSimulation completed in 5 seconds
Parsing log file(s)...
Generating reports...

================================================================================
---- Global Information --------------------------------------------------------
> request count                                        42 (OK=40     KO=2     )
> min response time                                     1 (OK=1      KO=-     )
> max response time                                  1200 (OK=800    KO=1200  )
> mean response time                                  120 (OK=100    KO=520   )
> response time 95th percentile                       900 (OK=850    KO=1200  )
> response time 99th percentile                      1200 (OK=950    KO=1200  )
> mean requests/sec                                 1.400 (OK=1.333  KO=0.067 )
---- Response Time Distribution ------------------------------------------------
> failed                                                 2 (  4%)
================================================================================

Reports generated in 1s.
Please open the following file: /work/output/gatling/${GATLING_RUN_TYPE}/raw/fake-run/index.html
LOG
if [ "$GATLING_RUN_TYPE" = max-limit ] && [ "${GATLING_FORCE_FAILURE:-}" = 1 ]; then
  exit 1
fi
exit 0
SH
chmod +x "$RUNNER_ROOT/scripts/run-gatling-container" "$RUNNER_ROOT/fake-gatling.sh"

cd "$RUNNER_ROOT"
set +e
RUNNER_OUTPUT=$(
  GATLING_DOCKER_PIPELINE=1 \
  GATLING_RUN_TYPE=max-limit \
  GATLING_MAX_BASE_USERS=10 \
  GATLING_MAX_STEP_USERS=10 \
  GATLING_MAX_LIMIT_USERS=30 \
  GATLING_MAX_DURATION_SECONDS=5 \
  GATLING_FORCE_FAILURE=1 \
  GATLING_CONSOLE_MODE=summary \
  GATLING_BIN="$RUNNER_ROOT/fake-gatling.sh" \
  ./scripts/run-gatling-container 2>&1
)
RUNNER_STATUS=$?
set -e

if [ "$RUNNER_STATUS" -ne 1 ]; then
  printf '%s\n' "$RUNNER_OUTPUT"
  printf '%s\n' "expected runner to preserve Gatling failure status 1, got $RUNNER_STATUS" >&2
  exit 1
fi

if ! printf '%s\n' "$RUNNER_OUTPUT" | grep -Fq -- "---- Global Information"; then
  printf '%s\n' "$RUNNER_OUTPUT"
  printf '%s\n' "expected default Gatling Global Information summary" >&2
  exit 1
fi

if printf '%s\n' "$RUNNER_OUTPUT" | grep -Fq "Gatling summary:"; then
  printf '%s\n' "$RUNNER_OUTPUT"
  printf '%s\n' "expected default Gatling summary, not compact custom summary" >&2
  exit 1
fi

if printf '%s\n' "$RUNNER_OUTPUT" | grep -Fq "Gatling evidence:"; then
  printf '%s\n' "$RUNNER_OUTPUT"
  printf '%s\n' "expected final max-limit native summary without evidence path noise" >&2
  exit 1
fi

if printf '%s\n' "$RUNNER_OUTPUT" | grep -Fq "Gatling exited with status"; then
  printf '%s\n' "$RUNNER_OUTPUT"
  printf '%s\n' "expected final max-limit native summary without normalization status noise" >&2
  exit 1
fi

cat > "$RUNNER_ROOT/fake-gatling-no-summary.sh" <<'SH'
#!/usr/bin/env sh
set -eu

cat <<'LOG'
Compilation failed before Gatling produced a final report.
LOG
exit 1
SH
chmod +x "$RUNNER_ROOT/fake-gatling-no-summary.sh"

set +e
NO_SUMMARY_OUTPUT=$(
  GATLING_DOCKER_PIPELINE=1 \
  GATLING_RUN_TYPE=stress-5m \
  GATLING_CONSOLE_MODE=summary \
  GATLING_BIN="$RUNNER_ROOT/fake-gatling-no-summary.sh" \
  ./scripts/run-gatling-container 2>&1
)
NO_SUMMARY_STATUS=$?
set -e

if [ "$NO_SUMMARY_STATUS" -ne 1 ]; then
  printf '%s\n' "$NO_SUMMARY_OUTPUT"
  printf '%s\n' "expected no-summary Gatling failure status 1, got $NO_SUMMARY_STATUS" >&2
  exit 1
fi

summary_header_count=$(printf '%s\n' "$NO_SUMMARY_OUTPUT" | grep -Fc "Gatling console mode: summary." || true)
if [ "$summary_header_count" -ne 0 ]; then
  printf '%s\n' "$NO_SUMMARY_OUTPUT"
  printf '%s\n' "expected no summary-mode wrapper header, got $summary_header_count" >&2
  exit 1
fi

if ! printf '%s\n' "$NO_SUMMARY_OUTPUT" | grep -Fq "No Gatling summary lines matched; inspect output/gatling/stress-5m/stress-5m-run.log"; then
  printf '%s\n' "$NO_SUMMARY_OUTPUT"
  printf '%s\n' "expected no-summary fallback message" >&2
  exit 1
fi

set +e
PASSING_MAX_OUTPUT=$(
  GATLING_DOCKER_PIPELINE=1 \
  GATLING_RUN_TYPE=max-limit \
  GATLING_MAX_BASE_USERS=10 \
  GATLING_MAX_STEP_USERS=10 \
  GATLING_MAX_LIMIT_USERS=30 \
  GATLING_MAX_DURATION_SECONDS=5 \
  GATLING_CONSOLE_MODE=summary \
  GATLING_BIN="$RUNNER_ROOT/fake-gatling.sh" \
  ./scripts/run-gatling-container 2>&1
)
PASSING_MAX_STATUS=$?
set -e

if [ "$PASSING_MAX_STATUS" -ne 0 ]; then
  printf '%s\n' "$PASSING_MAX_OUTPUT"
  printf '%s\n' "expected passing max-limit step to exit 0, got $PASSING_MAX_STATUS" >&2
  exit 1
fi

if ! printf '%s\n' "$PASSING_MAX_OUTPUT" | grep -Fq -- "---- Global Information"; then
  printf '%s\n' "$PASSING_MAX_OUTPUT"
  printf '%s\n' "expected native Gatling summary for passing max-limit run" >&2
  exit 1
fi

if printf '%s\n' "$PASSING_MAX_OUTPUT" | grep -Fq "Gatling evidence:"; then
  printf '%s\n' "$PASSING_MAX_OUTPUT"
  printf '%s\n' "expected passing max-limit step evidence paths to stay out of the console" >&2
  exit 1
fi

set +e
LOAD_OUTPUT=$(
  GATLING_DOCKER_PIPELINE=1 \
  GATLING_RUN_TYPE=load-5m \
  GATLING_LOAD_USERS=5 \
  GATLING_CONSOLE_MODE=summary \
  GATLING_BIN="$RUNNER_ROOT/fake-gatling.sh" \
  ./scripts/run-gatling-container 2>&1
)
LOAD_STATUS=$?
set -e

if [ "$LOAD_STATUS" -ne 0 ]; then
  printf '%s\n' "$LOAD_OUTPUT"
  printf '%s\n' "expected load runner to exit 0, got $LOAD_STATUS" >&2
  exit 1
fi

if ! printf '%s\n' "$LOAD_OUTPUT" | grep -Fq -- "---- Global Information"; then
  printf '%s\n' "$LOAD_OUTPUT"
  printf '%s\n' "expected native Gatling Global Information summary for load" >&2
  exit 1
fi

if printf '%s\n' "$LOAD_OUTPUT" | grep -Fq -- "load test started"; then
  printf '%s\n' "$LOAD_OUTPUT"
  printf '%s\n' "expected load summary mode to omit wrapper start line" >&2
  exit 1
fi

if ! printf '%s\n' "$LOAD_OUTPUT" | grep -Fq "Load test summary:"; then
  printf '%s\n' "$LOAD_OUTPUT"
  printf '%s\n' "expected load wrapper summary" >&2
  exit 1
fi

if ! printf '%s\n' "$LOAD_OUTPUT" | grep -Fq "  app base URL: http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/"; then
  printf '%s\n' "$LOAD_OUTPUT"
  printf '%s\n' "expected load app base URL summary" >&2
  exit 1
fi

if ! printf '%s\n' "$LOAD_OUTPUT" | grep -Fq "  parameters: users 5 | duration 300s"; then
  printf '%s\n' "$LOAD_OUTPUT"
  printf '%s\n' "expected load parameter summary" >&2
  exit 1
fi

if ! printf '%s\n' "$LOAD_OUTPUT" | grep -Fq "  key result: Gatling completed with status 0"; then
  printf '%s\n' "$LOAD_OUTPUT"
  printf '%s\n' "expected load key result summary" >&2
  exit 1
fi

if printf '%s\n' "$LOAD_OUTPUT" | grep -Fq "Gatling console mode: summary."; then
  printf '%s\n' "$LOAD_OUTPUT"
  printf '%s\n' "expected load summary mode to omit wrapper header" >&2
  exit 1
fi

if printf '%s\n' "$LOAD_OUTPUT" | grep -Fq "Gatling summary:"; then
  printf '%s\n' "$LOAD_OUTPUT"
  printf '%s\n' "expected native Gatling summary for load, not compact custom summary" >&2
  exit 1
fi

if printf '%s\n' "$LOAD_OUTPUT" | grep -Fq "Gatling evidence:"; then
  printf '%s\n' "$LOAD_OUTPUT"
  printf '%s\n' "expected load summary mode without evidence path noise" >&2
  exit 1
fi

set +e
STRESS_OUTPUT=$(
  GATLING_DOCKER_PIPELINE=1 \
  GATLING_RUN_TYPE=stress-5m \
  GATLING_STRESS_START_USERS=5 \
  GATLING_STRESS_TARGET_USERS=50 \
  GATLING_CONSOLE_MODE=summary \
  GATLING_BIN="$RUNNER_ROOT/fake-gatling.sh" \
  ./scripts/run-gatling-container 2>&1
)
STRESS_STATUS=$?
set -e

if [ "$STRESS_STATUS" -ne 0 ]; then
  printf '%s\n' "$STRESS_OUTPUT"
  printf '%s\n' "expected stress runner to exit 0, got $STRESS_STATUS" >&2
  exit 1
fi

if ! printf '%s\n' "$STRESS_OUTPUT" | grep -Fq -- "---- Global Information"; then
  printf '%s\n' "$STRESS_OUTPUT"
  printf '%s\n' "expected native Gatling Global Information summary for stress" >&2
  exit 1
fi

if printf '%s\n' "$STRESS_OUTPUT" | grep -Fq -- "stress test started"; then
  printf '%s\n' "$STRESS_OUTPUT"
  printf '%s\n' "expected stress summary mode to omit wrapper start line" >&2
  exit 1
fi

if ! printf '%s\n' "$STRESS_OUTPUT" | grep -Fq "Stress test summary:"; then
  printf '%s\n' "$STRESS_OUTPUT"
  printf '%s\n' "expected stress wrapper summary" >&2
  exit 1
fi

if ! printf '%s\n' "$STRESS_OUTPUT" | grep -Fq "  app base URL: http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/"; then
  printf '%s\n' "$STRESS_OUTPUT"
  printf '%s\n' "expected stress app base URL summary" >&2
  exit 1
fi

if ! printf '%s\n' "$STRESS_OUTPUT" | grep -Fq "  parameters: range 5-50 users | duration 300s"; then
  printf '%s\n' "$STRESS_OUTPUT"
  printf '%s\n' "expected stress parameter summary" >&2
  exit 1
fi

if ! printf '%s\n' "$STRESS_OUTPUT" | grep -Fq "  key result: Gatling completed with status 0"; then
  printf '%s\n' "$STRESS_OUTPUT"
  printf '%s\n' "expected stress key result summary" >&2
  exit 1
fi

if printf '%s\n' "$STRESS_OUTPUT" | grep -Fq "Gatling console mode: summary."; then
  printf '%s\n' "$STRESS_OUTPUT"
  printf '%s\n' "expected stress summary mode to omit wrapper header" >&2
  exit 1
fi

if printf '%s\n' "$STRESS_OUTPUT" | grep -Fq "Gatling summary:"; then
  printf '%s\n' "$STRESS_OUTPUT"
  printf '%s\n' "expected native Gatling summary for stress, not compact custom summary" >&2
  exit 1
fi

if printf '%s\n' "$STRESS_OUTPUT" | grep -Fq "Gatling evidence:"; then
  printf '%s\n' "$STRESS_OUTPUT"
  printf '%s\n' "expected stress summary mode without evidence path noise" >&2
  exit 1
fi
