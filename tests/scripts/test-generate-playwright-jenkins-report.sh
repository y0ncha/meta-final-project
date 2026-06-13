#!/usr/bin/env sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd -P)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/playwright-report-test.XXXXXX")
REPORT_FILE="$TEST_ROOT/output/playwright/jenkins-report/index.html"
CSS_FILE="$TEST_ROOT/output/playwright/jenkins-report/playwright-jenkins-report.css"

mkdir -p \
  "$TEST_ROOT/output/playwright" \
  "$TEST_ROOT/output/playwright/playwright-report" \
  "$TEST_ROOT/output/playwright/screenshots"

cat > "$TEST_ROOT/output/playwright/junit.xml" <<'XML'
<testsuites tests="1" failures="0" skipped="0" errors="0" time="3.3">
  <testsuite name="meta-functional.spec.js" tests="1" failures="0" skipped="0" errors="0" time="0.9">
    <testcase name="JSP app supports the required functional flow" classname="meta-functional.spec.js" time="0.9"></testcase>
  </testsuite>
</testsuites>
XML

printf '%s\n' 'playwright log' > "$TEST_ROOT/output/playwright/playwright-run.log"
printf '%s\n' '<!doctype html><title>native</title><script type="module"></script>' > "$TEST_ROOT/output/playwright/playwright-report/index.html"
printf '%s\n' 'png' > "$TEST_ROOT/output/playwright/screenshots/valid-submit.png"
printf '%s\n' 'png' > "$TEST_ROOT/output/playwright/screenshots/empty-submit.png"

JOB_NAME="meta-ci-cd" \
BUILD_NUMBER="164" \
BUILD_URL="http://localhost:8081/job/meta-ci-cd/164/" \
BRANCH_NAME="main" \
  sh -c 'cd "$1" && "$2/scripts/generate-playwright-jenkins-report"' sh "$TEST_ROOT" "$PROJECT_ROOT" >/tmp/generate-playwright-jenkins-report-test.log

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

test -s "$REPORT_FILE"
test -s "$CSS_FILE"
assert_contains '<link rel="stylesheet" href="playwright-jenkins-report.css">'
assert_contains '<td>Tests</td><td>1</td>'
assert_contains '<td>Failures</td><td>0</td>'
assert_contains '<td>Errors</td><td>0</td>'
assert_contains '>JUnit</a>'
assert_contains '>Run log</a>'
assert_contains '>Valid submit</a>'
assert_contains 'Course Rationale Map'
assert_contains 'Assert the app identity before trusting later evidence.'
assert_contains '<code>verifyElementPresent</code>'
assert_contains 'Negative scenario: submit empty input and verify the error text'
assert_not_contains '>Native HTML</a>'
assert_not_contains 'href="http://localhost:8081/job/meta-ci-cd/164/artifact/output/playwright/playwright-report/index.html"'
assert_contains 'native Playwright HTML report is archived under build artifacts but is not linked here'
assert_not_contains '<script'
assert_not_contains '>output/playwright/playwright-report/index.html</a>'

printf '%s\n' 'generate-playwright-jenkins-report checks passed'
