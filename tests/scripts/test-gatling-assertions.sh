#!/usr/bin/env sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd -P)
SIMULATION="$PROJECT_ROOT/src/gatling/user-files/simulations/MetaSimulation.scala"

assert_contains() {
  pattern="$1"
  if ! grep -Fq -- "$pattern" "$SIMULATION"; then
    printf 'Expected Gatling simulation to contain: %s\n' "$pattern" >&2
    exit 1
  fi
}

assert_not_contains() {
  pattern="$1"
  if grep -Fq -- "$pattern" "$SIMULATION"; then
    printf 'Expected Gatling simulation not to contain: %s\n' "$pattern" >&2
    exit 1
  fi
}

assert_contains 'global.failedRequests.count.lt(1)'
assert_not_contains 'global.failedRequests.percent.lt(5)'
assert_not_contains 'global.responseTime.percentile3.lte(2000)'

printf '%s\n' 'Gatling assertion policy checks passed'
