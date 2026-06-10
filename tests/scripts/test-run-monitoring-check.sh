#!/usr/bin/env sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd -P)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/monitoring-check-test.XXXXXX")
FAKE_BIN="$TEST_ROOT/bin"
CURL_ARGS_FILE="$TEST_ROOT/curl-args.txt"
OUTPUT_FILE="$TEST_ROOT/output/monitoring/latest-check.txt"

mkdir -p "$FAKE_BIN"

cat > "$FAKE_BIN/curl" <<'SH'
#!/usr/bin/env sh
printf '%s\n' "$*" > "$CURL_ARGS_FILE"
exit 0
SH
chmod +x "$FAKE_BIN/curl"

PATH="$FAKE_BIN:$PATH" \
CURL_ARGS_FILE="$CURL_ARGS_FILE" \
APP_BASE_URL="http://example.test/meta/" \
JOB_NAME="meta-monitoring-test" \
BUILD_NUMBER="42" \
  sh -c 'cd "$1" && "$2/scripts/run-monitoring-check"' sh "$TEST_ROOT" "$PROJECT_ROOT" >/tmp/run-monitoring-check-test.log

assert_contains() {
  file="$1"
  pattern="$2"
  if ! grep -Fq -- "$pattern" "$file"; then
    printf 'Expected %s to contain: %s\n' "$file" "$pattern" >&2
    exit 1
  fi
}

test -s "$OUTPUT_FILE"
test -s "$CURL_ARGS_FILE"
assert_contains "$CURL_ARGS_FILE" '--connect-timeout 5'
assert_contains "$CURL_ARGS_FILE" '--max-time 15'
assert_contains "$CURL_ARGS_FILE" '-fsS'
assert_contains "$CURL_ARGS_FILE" 'http://example.test/meta/'
assert_contains "$OUTPUT_FILE" 'status=up'
assert_contains "$OUTPUT_FILE" 'target=http://example.test/meta/'
assert_contains "$OUTPUT_FILE" 'job=meta-monitoring-test'
assert_contains "$OUTPUT_FILE" 'build=42'

printf '%s\n' 'run-monitoring-check timeout and evidence checks passed'
