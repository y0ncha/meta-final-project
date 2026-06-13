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
: "${GATLING_MAX_BASE_USERS:?}"
: "${GATLING_MAX_STEP_USERS:?}"
: "${GATLING_MAX_LIMIT_USERS:?}"
: "${GATLING_MAX_DURATION_SECONDS:?}"

if [ "$GATLING_RUN_TYPE" != "max-limit" ]; then
  printf 'expected max-limit run type, got %s\n' "$GATLING_RUN_TYPE" >&2
  exit 1
fi

printf '%s|%s|%s|%s|%s\n' \
  "$GATLING_RUN_TYPE" \
  "$GATLING_MAX_BASE_USERS" \
  "$GATLING_MAX_STEP_USERS" \
  "$GATLING_MAX_LIMIT_USERS" \
  "$GATLING_MAX_DURATION_SECONDS" >> "$CALL_LOG"

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
  GATLING_MAX_BASE_USERS=10 \
  GATLING_MAX_STEP_USERS=10 \
  GATLING_MAX_DURATION_SECONDS=1 \
  GATLING_MAX_LIMIT_USERS=30 \
    "$SCRIPT_DIR/run-gatling-max-limit" >/dev/null
)

assert_file_equals "max-limit|10|10|30|1" "$CALL_LOG"

: > "$CALL_LOG"
(
  cd "$TEST_ROOT"
  CALL_LOG="$CALL_LOG" \
  FAIL_STAIRCASE=1 \
  GATLING_MAX_BASE_USERS=5 \
  GATLING_MAX_STEP_USERS=5 \
  GATLING_MAX_DURATION_SECONDS=1 \
  GATLING_MAX_LIMIT_USERS=20 \
    "$SCRIPT_DIR/run-gatling-max-limit" >/dev/null
)

assert_file_equals "max-limit|5|5|20|1" "$CALL_LOG"

: > "$CALL_LOG"
(
  cd "$TEST_ROOT"
  CALL_LOG="$CALL_LOG" \
  FAIL_STAIRCASE=1 \
  GATLING_MAX_BASE_USERS=100 \
  GATLING_MAX_STEP_USERS=25 \
  GATLING_MAX_DURATION_SECONDS=7 \
  GATLING_CONSOLE_MODE=summary \
  GATLING_MAX_LIMIT_USERS=175 \
    "$SCRIPT_DIR/run-gatling-max-limit" > "$TEST_ROOT/single-level.log"
)

assert_file_equals "max-limit|100|25|175|7" "$CALL_LOG"

if ! grep -Fq 'Max-limit test summary:' "$TEST_ROOT/single-level.log"; then
  printf '%s\n' 'wrapper summary should print to stdout' >&2
  exit 1
fi
if ! grep -Fq '  staircase Gatling report: output/gatling/max-limit/index.html' "$TEST_ROOT/single-level.log"; then
  printf '%s\n' 'staircase report should print to stdout' >&2
  exit 1
fi
if ! grep -Fq '  highest passing tested level: inspect staircase report' "$TEST_ROOT/single-level.log"; then
  printf '%s\n' 'honest fallback highest passing summary should print to stdout' >&2
  exit 1
fi
if ! grep -Fq '  first failing tested level: inspect staircase report' "$TEST_ROOT/single-level.log"; then
  printf '%s\n' 'honest fallback first failing summary should print to stdout' >&2
  exit 1
fi
if grep -Fq 'max limit level finished :' "$TEST_ROOT/single-level.log"; then
  printf '%s\n' 'passing-level progress should not print to summary stdout' >&2
  exit 1
fi
grep -Fq 'max limit staircase started : 100-175 virtual users | step: 25 virtual users | duration: 7s per level' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'command parameters: GATLING_RUN_TYPE=max-limit GATLING_MAX_BASE_USERS=100 GATLING_MAX_STEP_USERS=25 GATLING_MAX_LIMIT_USERS=175 GATLING_MAX_DURATION_SECONDS=7' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'level schedule: 100 virtual users | report time window: 0-7s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'level schedule: 125 virtual users | report time window: 7-14s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'level schedule: 150 virtual users | report time window: 14-21s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'level schedule: 175 virtual users | report time window: 21-28s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq '  first failing tested level: inspect staircase report' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq '  highest passing tested level: inspect staircase report' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
if grep -Fq 'Max-limit testing level' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"; then
  printf '%s\n' 'single-level discovery progress should not be logged' >&2
  exit 1
fi

: > "$CALL_LOG"
(
  cd "$TEST_ROOT"
  CALL_LOG="$CALL_LOG" \
  GATLING_MAX_BASE_USERS=10 \
  GATLING_MAX_STEP_USERS=6 \
  GATLING_MAX_DURATION_SECONDS=2 \
  GATLING_MAX_LIMIT_USERS=25 \
    "$SCRIPT_DIR/run-gatling-max-limit" >/dev/null
)

grep -Fq 'level schedule: 10 virtual users | report time window: 0-2s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'level schedule: 16 virtual users | report time window: 2-4s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'level schedule: 22 virtual users | report time window: 4-6s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"
grep -Fq 'level schedule: 25 virtual users | report time window: 6-8s' "$TEST_ROOT/output/gatling/max-limit/raw/max-limit-discovery.log"

printf '%s\n' 'run-gatling-max-limit discovery checks passed'
