#!/usr/bin/env sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd -P)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/pipeline-report-test.XXXXXX")
REPORT_FILE="$TEST_ROOT/output/reports/pipeline-report.html"
CSS_FILE="$TEST_ROOT/output/reports/pipeline-report.css"

mkdir -p "$TEST_ROOT/output/gatling/load-5m"
printf '%s\n' 'load log' > "$TEST_ROOT/output/gatling/load-5m/load-5m-run.log"
printf '%s\n' '<!doctype html><title>load</title>' > "$TEST_ROOT/output/gatling/load-5m/index.html"
printf '%s\n' '%PDF-1.4' > "$TEST_ROOT/output/gatling/load-5m/load-5m-report.pdf"

JOB_NAME="meta-ci-cd" \
BUILD_NUMBER="164" \
BUILD_URL="http://localhost:8081/job/meta-ci-cd/164/" \
BRANCH_NAME="main" \
  sh -c 'cd "$1" && "$2/scripts/generate-pipeline-report"' sh "$TEST_ROOT" "$PROJECT_ROOT" >/tmp/generate-pipeline-report-test.log

assert_contains() {
  pattern="$1"
  if ! grep -Fq "$pattern" "$REPORT_FILE"; then
    printf 'Expected report to contain: %s\n' "$pattern" >&2
    exit 1
  fi
}

assert_not_contains() {
  pattern="$1"
  if grep -Fq "$pattern" "$REPORT_FILE"; then
    printf 'Expected report not to contain: %s\n' "$pattern" >&2
    exit 1
  fi
}

assert_file_contains() {
  file="$1"
  pattern="$2"
  if ! grep -Fq "$pattern" "$file"; then
    printf 'Expected %s to contain: %s\n' "$file" "$pattern" >&2
    exit 1
  fi
}

test -s "$CSS_FILE"
assert_contains '<link rel="stylesheet" href="pipeline-report.css">'
assert_contains '<dl class="meta-grid">'
assert_contains '<th>Evidence State</th>'
assert_contains 'Build WAR</td><td>Archived target/yonatan-csasznik-yoed-halberstam-niv-levin.war</td><td><span class="status status-missing">Missing</span>'
assert_contains 'Pre Actions</td><td>Jenkins console log</td><td><span class="status status-log">Console log</span>'
assert_contains 'Gatling Load Test</td><td>HTML, PDF, raw report, log</td><td><span class="status status-ok">Available</span>'
assert_contains 'Gatling Stress Test</td><td>HTML, PDF, raw report, log</td><td><span class="status status-opt-in">Opt-in / not run</span>'
assert_contains '<span class="status status-ok">Available</span>'
assert_contains '<span class="status status-opt-in">Opt-in'
assert_contains 'Requires <code>RUN_GATLING_TESTS=true</code>'
assert_contains '<th>References</th>'
assert_contains 'href="http://localhost:8081/job/meta-ci-cd/164/artifact/output/gatling/load-5m/index.html">HTML</a>'
assert_contains 'href="http://localhost:8081/job/meta-ci-cd/164/artifact/output/gatling/load-5m/load-5m-report.pdf">PDF</a>'
assert_not_contains '<th>Path</th>'
assert_not_contains '>output/gatling/load-5m/index.html</a>'
assert_not_contains '>output/gatling/load-5m/load-5m-report.pdf</a>'
assert_not_contains '<td>Load HTML</td>'
assert_not_contains '<td>Load PDF</td>'
assert_not_contains 'Playwright Functional Test</td><td>HTML, JUnit XML, screenshots, log</td><td><span class="status status-ok">Available</span>'
assert_not_contains 'Gatling Stress Test</td><td>HTML, PDF, raw report, log</td><td><span class="status status-ok">Available</span>'
assert_not_contains 'RUN_GATLING_MAX_LIMIT=true'
assert_not_contains 'http://localhost:8081/job/meta-container-ci-cd/164/artifact/'
assert_file_contains "$CSS_FILE" '.status-ok'
assert_file_contains "$CSS_FILE" '.status-log'
assert_file_contains "$CSS_FILE" '.artifact-table'

printf '%s\n' 'generate-pipeline-report rendering checks passed'
