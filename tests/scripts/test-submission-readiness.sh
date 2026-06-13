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

assert_contains '| j | Written max-limit result and explanation | Max-limit number, how it was found, and why it is the limit | `docs/gatling.md`, `output/gatling/max-limit/max-limit-run.log`, `output/gatling/max-limit/index.html` | Partial; refresh after the HAR-derived simulation update and report highest virtual-user level with `KO=0` plus first KO level |'
assert_contains '| l | Three Gatling result PDFs with graph explanations | Max-limit, load, and stress PDF reports plus written graph explanations | `output/gatling/max-limit/max-limit-report.pdf`, `output/gatling/load-5m/load-5m-report.pdf`, `output/gatling/stress-5m/stress-5m-report.pdf`, `docs/gatling.md` | Partial; refresh all three PDFs after the HAR-derived simulation update, then attach all three freshly validated PDFs |'
assert_not_contains '| l | Three Gatling result PDFs with graph explanations | Max-limit, load, and stress PDF reports plus written graph explanations | `output/gatling/max-limit/max-limit-report.pdf`, `output/gatling/load-5m/load-5m-report.pdf`, `output/gatling/stress-5m/stress-5m-report.pdf`, `docs/gatling.md` | Ready |'

printf '%s\n' 'submission readiness checks passed'
