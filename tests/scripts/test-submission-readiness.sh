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

assert_contains 'The local Gatling max-limit evidence must be refreshed after the users/sec refactor.'
assert_contains '| g | Browser automation passed-run screenshot and validation explanation | `submission/local/g-browser-test-passed-run/` | ready for screenshot/PDF capture |'
assert_contains '- Native Playwright HTML report: `submission/local/g-browser-test-passed-run/playwright-run-report.html`'
assert_contains '- Jenkins-safe Playwright HTML report: `submission/local/g-browser-test-passed-run/index.html`'
assert_contains '| Public Playwright | `submission/public/public-browser-test-passed-run/` | Public-target Jenkins artifacts | ready for screenshot/PDF capture |'
assert_contains '- Required result after refresh: highest tested users/sec level with `KO=0`'
assert_contains '- Required boundary after refresh: first tested users/sec level with `KO>0`'
assert_contains '- Public max-limit: refresh separately before claiming a public users/sec max-limit value.'
assert_contains '- Public load 5m: `1900 OK`, `0 KO`.'
assert_contains '- Public stress 5m: `15368 OK`, `0 KO`.'
assert_contains 'Public HTML/log artifacts were intentionally removed.'
assert_not_contains 'Local Jenkins build `#224`'
assert_not_contains 'Jenkins public build `#225`'

printf '%s\n' 'submission readiness checks passed'
