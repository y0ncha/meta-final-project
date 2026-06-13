#!/usr/bin/env sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd -P)
SUBMISSION_DOC="$PROJECT_ROOT/docs/submission.md"

assert_contains() {
  pattern="$1"
  if ! grep -Fq -- "$pattern" "$SUBMISSION_DOC"; then
    printf 'Expected submission guide to contain: %s\n' "$pattern" >&2
    exit 1
  fi
}

assert_not_contains() {
  pattern="$1"
  if grep -Fq -- "$pattern" "$SUBMISSION_DOC"; then
    printf 'Expected submission guide not to contain: %s\n' "$pattern" >&2
    exit 1
  fi
}

assert_contains 'Local Jenkins build `#248` is the base submission evidence.'
assert_contains '| g | Browser automation passed-run screenshot and validation explanation | `submission/local/g-browser-test-passed-run/` | ready for screenshot/PDF capture |'
assert_contains '- Native Playwright HTML report: `submission/local/g-browser-test-passed-run/playwright-run-report.html`'
assert_contains '- Jenkins-safe Playwright HTML report: `submission/local/g-browser-test-passed-run/index.html`'
assert_contains '| Public Playwright | `submission/public/public-browser-test-passed-run/` | Jenkins public build `#249` | ready for screenshot/PDF capture |'
assert_contains '- Highest passing tested level: `8440` virtual users'
assert_contains '- First failing tested level: `8460` virtual users'
assert_contains '- Public max-limit: `8280` virtual users passed with `KO=0`; `8300` was the first failing tested level with `KO=47`.'
assert_contains '- Public load 5m: `2252 OK`, `0 KO`.'
assert_contains '- Public stress 5m: `15624 OK`, `0 KO`.'
assert_contains 'Public HTML/log artifacts were intentionally removed.'
assert_not_contains 'Local Jenkins build `#224`'
assert_not_contains 'Jenkins public build `#225`'

printf '%s\n' 'submission readiness checks passed'
