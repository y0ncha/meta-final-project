#!/usr/bin/env sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd -P)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/gatling-max-limit-test.XXXXXX")
SCRIPT_DIR="$TEST_ROOT/scripts"
BIN_DIR="$TEST_ROOT/bin"
CALL_LOG="$TEST_ROOT/calls.log"
RESTART_LOG="$TEST_ROOT/restarts.log"

mkdir -p "$SCRIPT_DIR" "$BIN_DIR"
cp "$PROJECT_ROOT/scripts/run-gatling-max-limit" "$SCRIPT_DIR/run-gatling-max-limit"

cat > "$BIN_DIR/docker" <<'SH'
#!/usr/bin/env sh
set -eu

: "${RESTART_LOG:?}"
printf 'docker|%s\n' "$*" >> "$RESTART_LOG"
SH

chmod +x "$BIN_DIR/docker"

cat > "$SCRIPT_DIR/run-gatling-container" <<'SH'
#!/usr/bin/env sh
set -eu

: "${CALL_LOG:?}"
: "${GATLING_RUN_TYPE:?}"
: "${GATLING_MAX_BASE_USERS:?}"
: "${GATLING_MAX_STEP_USERS:?}"
: "${GATLING_MAX_LIMIT_USERS:?}"
: "${GATLING_MAX_DURATION_SECONDS:?}"
: "${GATLING_MAX_RAMP_SECONDS:?}"
: "${APP_BASE_URL:?}"

if [ "$GATLING_RUN_TYPE" != "max-limit" ]; then
  printf 'expected max-limit run type, got %s\n' "$GATLING_RUN_TYPE" >&2
  exit 1
fi

printf '%s|%s|%s|%s|%s|%s|%s\n' \
  "$GATLING_RUN_TYPE" \
  "$GATLING_MAX_BASE_USERS" \
  "$GATLING_MAX_STEP_USERS" \
  "$GATLING_MAX_LIMIT_USERS" \
  "$GATLING_MAX_DURATION_SECONDS" \
  "$GATLING_MAX_RAMP_SECONDS" \
  "$APP_BASE_URL" >> "$CALL_LOG"

mkdir -p output/gatling/max-limit
printf '<!doctype html><title>staircase</title>\n' > output/gatling/max-limit/index.html
printf 'staircase\n' > output/gatling/max-limit/max-limit-run.log

if [ "${FAIL_STAIRCASE:-}" = "1" ]; then
  exit 1
fi
SH
chmod +x "$SCRIPT_DIR/run-gatling-container" "$SCRIPT_DIR/run-gatling-max-limit"

assert_file_equals() {
  expected="$1"
  actual_file="$2"
  if ! diff -u - "$actual_file" <<EOF
$expected
EOF
  then
    printf 'Unexpected call log in %s\n' "$actual_file" >&2
    exit 1
  fi
}

(
  cd "$TEST_ROOT"
  CALL_LOG="$CALL_LOG" \
  APP_BASE_URL=http://example.test/meta/ \
  GATLING_MAX_START_USERS_PER_SEC=10 \
  GATLING_MAX_STEP_USERS_PER_SEC=10 \
  GATLING_MAX_DURATION_SECONDS=1 \
  GATLING_MAX_RAMP_SECONDS=0 \
  GATLING_MAX_END_USERS_PER_SEC=30 \
    "$SCRIPT_DIR/run-gatling-max-limit" >/dev/null
)

assert_file_equals "max-limit|10|10|30|1|0|http://example.test/meta/" "$CALL_LOG"

: > "$CALL_LOG"
: > "$RESTART_LOG"
(
  cd "$TEST_ROOT"
  PATH="$BIN_DIR:$PATH" \
  CALL_LOG="$CALL_LOG" \
  RESTART_LOG="$RESTART_LOG" \
  APP_BASE_URL=http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ \
  GATLING_RESTART_TOMCAT_BEFORE_RUN=true \
  GATLING_MAX_START_USERS=10 \
  GATLING_MAX_STEP_USERS=10 \
  GATLING_MAX_DURATION_SECONDS=1 \
  GATLING_MAX_RAMP_SECONDS=0 \
  GATLING_MAX_LIMIT_USERS=30 \
    "$SCRIPT_DIR/run-gatling-max-limit" > "$TEST_ROOT/local-restart.log"
)

assert_file_equals "docker|compose restart tomcat" "$RESTART_LOG"
assert_file_equals "max-limit|10|10|30|1|0|http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/" "$CALL_LOG"
grep -Fq 'Tomcat restart requested before Gatling: local Compose target from APP_BASE_URL=http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/' "$TEST_ROOT/local-restart.log"
grep -Fq 'Tomcat restart completed before Gatling.' "$TEST_ROOT/local-restart.log"

: > "$CALL_LOG"
: > "$RESTART_LOG"
set +e
(
  cd "$TEST_ROOT"
  PATH="$BIN_DIR:$PATH" \
  CALL_LOG="$CALL_LOG" \
  RESTART_LOG="$RESTART_LOG" \
  APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ \
  GATLING_RESTART_TOMCAT_BEFORE_RUN=true \
  GATLING_MAX_START_USERS=10 \
  GATLING_MAX_STEP_USERS=10 \
  GATLING_MAX_DURATION_SECONDS=1 \
  GATLING_MAX_RAMP_SECONDS=0 \
  GATLING_MAX_LIMIT_USERS=30 \
    "$SCRIPT_DIR/run-gatling-max-limit" > "$TEST_ROOT/public-restart.log" 2>&1
)
public_restart_status=$?
set -e
if [ "$public_restart_status" -ne 2 ]; then
  printf 'expected public restart to exit 2, got %s\n' "$public_restart_status" >&2
  exit 1
fi
if [ -s "$CALL_LOG" ]; then
  printf '%s\n' 'Gatling should not run when public restart is requested' >&2
  exit 1
fi
if [ -s "$RESTART_LOG" ]; then
  printf '%s\n' 'restart command should not run when public restart is requested' >&2
  exit 1
fi
grep -Fq 'Remote Tomcat restart before Gatling is intentionally unsupported.' "$TEST_ROOT/public-restart.log"

: > "$CALL_LOG"
(
  cd "$TEST_ROOT"
  CALL_LOG="$CALL_LOG" \
    "$SCRIPT_DIR/run-gatling-max-limit" >/dev/null
)

assert_file_equals "max-limit|0|25|550|10|1|http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/" "$CALL_LOG"

: > "$CALL_LOG"
(
  cd "$TEST_ROOT"
  CALL_LOG="$CALL_LOG" \
  APP_BASE_URL=http://example.test/meta/ \
  FAIL_STAIRCASE=1 \
  GATLING_MAX_START_USERS=5 \
  GATLING_MAX_STEP_USERS=5 \
  GATLING_MAX_DURATION_SECONDS=1 \
  GATLING_MAX_RAMP_SECONDS=0 \
  GATLING_MAX_LIMIT_USERS=20 \
    "$SCRIPT_DIR/run-gatling-max-limit" >/dev/null
)

assert_file_equals "max-limit|5|5|20|1|0|http://example.test/meta/" "$CALL_LOG"

: > "$CALL_LOG"
(
  cd "$TEST_ROOT"
  CALL_LOG="$CALL_LOG" \
  APP_BASE_URL=http://example.test/meta/ \
  FAIL_STAIRCASE=1 \
  GATLING_MAX_START_USERS=100 \
  GATLING_MAX_STEP_USERS=25 \
  GATLING_MAX_DURATION_SECONDS=7 \
  GATLING_MAX_RAMP_SECONDS=2 \
  GATLING_CONSOLE_MODE=summary \
  GATLING_MAX_LIMIT_USERS=175 \
    "$SCRIPT_DIR/run-gatling-max-limit" > "$TEST_ROOT/single-level.log"
)

assert_file_equals "max-limit|100|25|175|7|2|http://example.test/meta/" "$CALL_LOG"

if ! grep -Fq 'URL: http://example.test/meta/ | range: 100-175 users/sec | step: 25 users/sec | duration: 7s per level | ramp: 2s between levels' "$TEST_ROOT/single-level.log"; then
  printf '%s\n' 'concise parameter summary should print to stdout' >&2
  exit 1
fi
if grep -Fq 'Max-limit test summary:' "$TEST_ROOT/single-level.log"; then
  printf '%s\n' 'wrapper summary should not print the old verbose header' >&2
  exit 1
fi
if grep -Fq '  highest passing tested level:' "$TEST_ROOT/single-level.log"; then
  printf '%s\n' 'wrapper summary should not print boundary lines' >&2
  exit 1
fi
if grep -Fq '  first failing tested level:' "$TEST_ROOT/single-level.log"; then
  printf '%s\n' 'wrapper summary should not print boundary lines' >&2
  exit 1
fi
if grep -Fq '  result:' "$TEST_ROOT/single-level.log"; then
  printf '%s\n' 'wrapper summary should not print result lines' >&2
  exit 1
fi
if grep -Fq '  key result:' "$TEST_ROOT/single-level.log"; then
  printf '%s\n' 'max-limit wrapper summary should not print a key result' >&2
  exit 1
fi
if grep -Fq 'max limit level finished :' "$TEST_ROOT/single-level.log"; then
  printf '%s\n' 'passing-level progress should not print to summary stdout' >&2
  exit 1
fi
grep -Fq 'max limit staircase started : 100-175 users/sec | step: 25 users/sec | duration: 7s per level | ramp: 2s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'command parameters: GATLING_RUN_TYPE=max-limit APP_BASE_URL=http://example.test/meta/ GATLING_MAX_START_USERS=100 GATLING_MAX_STEP_USERS=25 GATLING_MAX_END_USERS=175 GATLING_MAX_DURATION_SECONDS=7 GATLING_MAX_RAMP_SECONDS=2' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'ramp schedule: 0-100 users/sec | report time window: 0-2s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'level schedule: 100 users/sec | report time window: 2-9s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'ramp schedule: 100-125 users/sec | report time window: 9-11s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'level schedule: 125 users/sec | report time window: 11-18s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'level schedule: 150 users/sec | report time window: 20-27s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'level schedule: 175 users/sec | report time window: 29-36s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
if grep -Fq '  key result:' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"; then
  printf '%s\n' 'max-limit discovery log should not print a wrapper key result' >&2
  exit 1
fi
if grep -Fq 'Max-limit testing level' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"; then
  printf '%s\n' 'single-level discovery progress should not be logged' >&2
  exit 1
fi

: > "$CALL_LOG"
(
  cd "$TEST_ROOT"
  CALL_LOG="$CALL_LOG" \
  APP_BASE_URL=http://example.test/meta/ \
  GATLING_MAX_START_USERS=10 \
  GATLING_MAX_STEP_USERS=6 \
  GATLING_MAX_DURATION_SECONDS=2 \
  GATLING_MAX_RAMP_SECONDS=0 \
  GATLING_MAX_LIMIT_USERS=25 \
    "$SCRIPT_DIR/run-gatling-max-limit" >/dev/null
)

grep -Fq 'level schedule: 10 users/sec | report time window: 0-2s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'level schedule: 16 users/sec | report time window: 2-4s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'level schedule: 22 users/sec | report time window: 4-6s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'level schedule: 25 users/sec | report time window: 6-8s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"

printf '%s\n' 'run-gatling-max-limit discovery checks passed'
