#!/usr/bin/env sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd -P)
JENKINSFILE="$PROJECT_ROOT/Jenkinsfile"

assert_contains() {
  pattern="$1"
  if ! grep -Fq "$pattern" "$JENKINSFILE"; then
    printf 'Expected Jenkinsfile to contain: %s\n' "$pattern" >&2
    exit 1
  fi
}

assert_contains "string(name: 'GATLING_MAX_START_USERS_PER_SEC', defaultValue: '200'"
assert_contains "string(name: 'GATLING_MAX_STEP_USERS_PER_SEC', defaultValue: '50'"
assert_contains "string(name: 'GATLING_MAX_LEVEL_COUNT', defaultValue: '6'"
assert_contains "string(name: 'GATLING_MAX_DISCOVERY_ATTEMPTS', defaultValue: '3'"

assert_contains 'GATLING_MAX_START_USERS_PER_SEC = "${params.GATLING_MAX_START_USERS_PER_SEC}"'
assert_contains 'GATLING_MAX_STEP_USERS_PER_SEC = "${params.GATLING_MAX_STEP_USERS_PER_SEC}"'
assert_contains 'GATLING_MAX_LEVEL_COUNT = "${params.GATLING_MAX_LEVEL_COUNT}"'
assert_contains 'GATLING_MAX_DISCOVERY_ATTEMPTS = "${params.GATLING_MAX_DISCOVERY_ATTEMPTS}"'

printf '%s\n' 'Jenkinsfile Gatling max-limit parameter checks passed'
