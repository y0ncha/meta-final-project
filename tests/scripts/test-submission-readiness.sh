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

assert_contains 'Max-limit note: the local max-limit evidence uses users/sec arrival-rate levels from Jenkins build `#12`.'
assert_contains '| g | Browser automation passed-run screenshot and validation explanation | `submission/local/g-browser-test-passed-run/` | ready for screenshot/PDF capture |'
assert_contains '- Native Playwright HTML report: `submission/local/g-browser-test-passed-run/playwright-run-report.html`'
assert_contains '- Jenkins-safe Playwright HTML report: `submission/local/g-browser-test-passed-run/index.html`'
assert_contains '| Public Playwright | `submission/public/public-browser-test-passed-run/` | Public-target Jenkins artifacts | ready for screenshot/PDF capture |'
assert_contains '- Tested range: `250` to `550 users/sec`, step `25 users/sec`, `10s/level`, `1s` ramp'
assert_contains '- Result: `475 users/sec` is the highest tested level with `KO=0`'
assert_contains '- Boundary: `500 users/sec` is the first tested level with `KO>0`'
assert_contains '- Public max-limit: build `#13` found `525 users/sec` as the highest passing tested level and `550 users/sec` as the first failing tested level.'
assert_contains '- Public load 5m: refresh after the users/sec load-profile change before claiming current public evidence.'
assert_contains '- Public stress 5m: refresh after the users/sec stress-profile change before claiming current public evidence.'
assert_contains '| Public Gatling load 5m | `submission/public/public-gatling-load-5m/` | Public-target Jenkins artifacts | stale after profile change |'
assert_contains '| Public Gatling stress 5m | `submission/public/public-gatling-stress-5m/` | Public-target Jenkins artifacts | stale after profile change |'
assert_not_contains 'Local Jenkins build `#224`'
assert_not_contains 'Jenkins public build `#225`'

printf '%s\n' 'submission readiness checks passed'
