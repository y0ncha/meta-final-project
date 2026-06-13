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
: "${GATLING_MAX_USERS:?}"
: "${GATLING_MAX_DURATION_SECONDS:?}"

if [ "$GATLING_RUN_TYPE" != "max-limit" ]; then
  printf 'expected max-limit run type, got %s\n' "$GATLING_RUN_TYPE" >&2
  exit 1
fi

line_count=0
if [ -f "$CALL_LOG" ]; then
  line_count=$(wc -l < "$CALL_LOG" | tr -d ' ')
fi
attempt=$((line_count + 1))

printf '%s|%s|%s|%s|%s|%s\n' \
  "$GATLING_MAX_USERS" \
  "$GATLING_MAX_DURATION_SECONDS" \
  "$GATLING_RUN_TYPE" \
  "${GATLING_MAX_BASE_USERS:-unset}" \
  "${GATLING_MAX_STEP_USERS:-unset}" \
  "${GATLING_MAX_LEVEL_COUNT:-unset}" >> "$CALL_LOG"

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
  GATLING_MAX_DISCOVERY_ATTEMPTS=3 \
  GATLING_MAX_BASE_USERS=10 \
  GATLING_MAX_STEP_USERS=10 \
  GATLING_MAX_DURATION_SECONDS=1 \
  GATLING_MAX_LIMIT_USERS=30 \
    "$SCRIPT_DIR/run-gatling-max-limit" >/dev/null
)

assert_file_equals "10|1|max-limit|10|10|unset
20|1|max-limit|10|10|unset
30|1|max-limit|10|10|unset" "$CALL_LOG"

: > "$CALL_LOG"
(
  cd "$TEST_ROOT"
  CALL_LOG="$CALL_LOG" \
  FAIL_ON_ATTEMPT=2 \
  GATLING_MAX_BASE_USERS=5 \
  GATLING_MAX_STEP_USERS=5 \
  GATLING_MAX_DURATION_SECONDS=1 \
  GATLING_MAX_LIMIT_USERS=20 \
    "$SCRIPT_DIR/run-gatling-max-limit" >/dev/null
)

assert_file_equals "5|1|max-limit|5|5|unset
10|1|max-limit|5|5|unset" "$CALL_LOG"

: > "$CALL_LOG"
(
  cd "$TEST_ROOT"
  CALL_LOG="$CALL_LOG" \
  FAIL_ON_ATTEMPT=3 \
  GATLING_MAX_BASE_USERS=100 \
  GATLING_MAX_STEP_USERS=25 \
  GATLING_MAX_DURATION_SECONDS=7 \
  GATLING_MAX_LIMIT_USERS=175 \
    "$SCRIPT_DIR/run-gatling-max-limit" > "$TEST_ROOT/single-level.log"
)

assert_file_equals "100|7|max-limit|100|25|unset
125|7|max-limit|100|25|unset
150|7|max-limit|100|25|unset" "$CALL_LOG"

grep -Fq 'max limit tests started : 100-175 virtual users | step: 25 virtual users | duration: 7s per level' "$TEST_ROOT/single-level.log"
grep -Fq 'max limit level finished : 100 virtual users | duration: 7s | passed' "$TEST_ROOT/single-level.log"
grep -Fq 'max limit level finished : 125 virtual users | duration: 7s | passed' "$TEST_ROOT/single-level.log"
grep -Fq '  first failing tested level: 150 virtual users' "$TEST_ROOT/single-level.log"
grep -Fq '  highest passing tested level: 125 virtual users' "$TEST_ROOT/single-level.log"
if grep -Fq 'max limit visual report started' "$TEST_ROOT/single-level.log"; then
  printf '%s\n' 'visual report phase should not run during max-limit discovery' >&2
  exit 1
fi

printf '%s\n' 'run-gatling-max-limit discovery checks passed'
