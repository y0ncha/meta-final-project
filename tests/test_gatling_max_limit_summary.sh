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

case "$GATLING_MAX_USERS" in
  10)
    printf '%s\n' "fake pass at ${GATLING_MAX_USERS}" >> "$OUTPUT_DIR/raw/calls.log"
    exit 0
    ;;
  20)
    printf '%s\n' '<html>fake report</html>' > "$OUTPUT_DIR/index.html"
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
    ;;
  *)
    printf '%s\n' "unexpected level ${GATLING_MAX_USERS}" >&2
    exit 2
    ;;
esac
SH
chmod +x "$TMP_ROOT/scripts/run-gatling-container" "$TMP_ROOT/scripts/run-gatling-max-limit"

cd "$TMP_ROOT"
set +e
OUTPUT=$(
  GATLING_CONSOLE_MODE=summary \
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
assert_not_contains "max limit tests started : 10-30 virtual users | step: 10 virtual users | duration: 5s per level"
assert_not_contains "max limit level finished : 10 virtual users | duration: 5s | passed"
assert_contains "Max-limit test summary:"
assert_contains "  tested range: 10-30 virtual users"
assert_contains "  highest passing tested level: 10 virtual users"
assert_contains "  first failing tested level: 20 virtual users"
assert_contains "  result: failure boundary found"
assert_contains "  Gatling report: output/gatling/max-limit/index.html"
assert_not_contains "Max-limit testing level 10 virtual users."
assert_not_contains "Max-limit level 10 virtual users passed."

if ! grep -Fq "Max-limit test summary:" output/gatling/max-limit/raw/max-limit-discovery.log; then
  printf '%s\n' "expected wrapper summary in discovery log" >&2
  exit 1
fi
if ! grep -Fq "  highest passing tested level: 10 virtual users" output/gatling/max-limit/raw/max-limit-discovery.log; then
  printf '%s\n' "expected highest passing level in discovery log" >&2
  exit 1
fi
if ! grep -Fq "  first failing tested level: 20 virtual users" output/gatling/max-limit/raw/max-limit-discovery.log; then
  printf '%s\n' "expected first failing level in discovery log" >&2
  exit 1
fi
if ! grep -Fq "Max-limit testing level 10 virtual users." output/gatling/max-limit/raw/max-limit-discovery.log; then
  printf '%s\n' "expected per-level progress in discovery log" >&2
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
if [ "$GATLING_RUN_TYPE" = max-limit ] && [ "${GATLING_MAX_USERS:-}" = 20 ]; then
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
  GATLING_MAX_USERS=20 \
  GATLING_MAX_DURATION_SECONDS=5 \
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
  GATLING_MAX_USERS=10 \
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

if printf '%s\n' "$PASSING_MAX_OUTPUT" | grep -Fq -- "---- Global Information"; then
  printf '%s\n' "$PASSING_MAX_OUTPUT"
  printf '%s\n' "expected passing max-limit step summary to stay out of the console" >&2
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
