#!/usr/bin/env sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd -P)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/gatling-max-limit-test.XXXXXX")
SCRIPT_DIR="$TEST_ROOT/scripts"
CALL_LOG="$TEST_ROOT/calls.log"

mkdir -p "$SCRIPT_DIR"
cp "$PROJECT_ROOT/scripts/run-gatling-max-limit" "$SCRIPT_DIR/run-gatling-max-limit"

cat > "$SCRIPT_DIR/run-gatling-container" <<'SH'
#!/usr/bin/env sh
set -eu

: "${CALL_LOG:?}"
: "${GATLING_RUN_TYPE:?}"
: "${GATLING_MAX_START_USERS_PER_SEC:?}"
: "${GATLING_MAX_STEP_USERS_PER_SEC:?}"
: "${GATLING_MAX_LEVEL_COUNT:?}"
: "${GATLING_MAX_LEVEL_SECONDS:?}"
: "${GATLING_MAX_RAMP_SECONDS:?}"

if [ "$GATLING_RUN_TYPE" != "max-limit" ]; then
  printf 'expected max-limit run type, got %s\n' "$GATLING_RUN_TYPE" >&2
  exit 1
fi

line_count=0
if [ -f "$CALL_LOG" ]; then
  line_count=$(wc -l < "$CALL_LOG" | tr -d ' ')
fi
attempt=$((line_count + 1))

printf '%s|%s|%s|%s|%s\n' \
  "$GATLING_MAX_START_USERS_PER_SEC" \
  "$GATLING_MAX_STEP_USERS_PER_SEC" \
  "$GATLING_MAX_LEVEL_COUNT" \
  "$GATLING_MAX_LEVEL_SECONDS" \
  "$GATLING_MAX_RAMP_SECONDS" >> "$CALL_LOG"

mkdir -p output/gatling/max-limit
printf '<!doctype html><title>attempt %s</title>\n' "$attempt" > output/gatling/max-limit/index.html
printf 'attempt=%s\n' "$attempt" > output/gatling/max-limit/max-limit-run.log

if [ "${FAIL_ON_ATTEMPT:-}" = "$attempt" ]; then
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
  GATLING_MAX_SINGLE_LEVEL_MODE=false \
  GATLING_MAX_DISCOVERY_ATTEMPTS=3 \
  GATLING_MAX_START_USERS_PER_SEC=10 \
  GATLING_MAX_STEP_USERS_PER_SEC=10 \
  GATLING_MAX_LEVEL_COUNT=3 \
  GATLING_MAX_LEVEL_SECONDS=1 \
  GATLING_MAX_RAMP_SECONDS=1 \
    "$SCRIPT_DIR/run-gatling-max-limit" >/dev/null
)

assert_file_equals "10|10|3|1|1
40|10|3|1|1
70|10|3|1|1" "$CALL_LOG"

: > "$CALL_LOG"
(
  cd "$TEST_ROOT"
  CALL_LOG="$CALL_LOG" \
  FAIL_ON_ATTEMPT=2 \
  GATLING_MAX_SINGLE_LEVEL_MODE=false \
  GATLING_MAX_DISCOVERY_ATTEMPTS=4 \
  GATLING_MAX_START_USERS_PER_SEC=5 \
  GATLING_MAX_STEP_USERS_PER_SEC=5 \
  GATLING_MAX_LEVEL_COUNT=2 \
  GATLING_MAX_LEVEL_SECONDS=1 \
  GATLING_MAX_RAMP_SECONDS=1 \
    "$SCRIPT_DIR/run-gatling-max-limit" >/dev/null
)

assert_file_equals "5|5|2|1|1
15|5|2|1|1" "$CALL_LOG"

: > "$CALL_LOG"
(
  cd "$TEST_ROOT"
  CALL_LOG="$CALL_LOG" \
  FAIL_ON_ATTEMPT=3 \
  GATLING_MAX_SINGLE_LEVEL_MODE=true \
  GATLING_MAX_BASE_USERS_PER_SEC=100 \
  GATLING_MAX_STEP_USERS_PER_SEC=25 \
  GATLING_MAX_DURATION_SECONDS=7 \
  GATLING_MAX_LIMIT_USERS_PER_SEC=175 \
  GATLING_MAX_RAMP_SECONDS=1 \
    "$SCRIPT_DIR/run-gatling-max-limit" > "$TEST_ROOT/single-level.log"
)

assert_file_equals "100|25|1|7|1
125|25|1|7|1
150|25|1|7|1" "$CALL_LOG"

grep -Fq 'Max-limit level 100 users/sec passed.' "$TEST_ROOT/single-level.log"
grep -Fq 'Max-limit level 125 users/sec passed.' "$TEST_ROOT/single-level.log"
grep -Fq 'Max-limit first failing tested level: 150 users/sec.' "$TEST_ROOT/single-level.log"
grep -Fq 'Max-limit highest passing tested level: 125 users/sec.' "$TEST_ROOT/single-level.log"

printf '%s\n' 'run-gatling-max-limit discovery checks passed'
