#!/usr/bin/env sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd -P)
JENKINSFILE="$PROJECT_ROOT/Jenkinsfile"

assert_contains() {
  pattern="$1"
  if ! grep -Fq -- "$pattern" "$JENKINSFILE"; then
    printf 'Expected Jenkinsfile to contain: %s\n' "$pattern" >&2
    exit 1
  fi
}

assert_not_contains() {
  pattern="$1"
  if grep -Fq -- "$pattern" "$JENKINSFILE"; then
    printf 'Expected Jenkinsfile not to contain: %s\n' "$pattern" >&2
    exit 1
  fi
}

assert_contains "string(name: 'GATLING_MAX_BASE_USERS_PER_SEC', defaultValue: '200'"
assert_contains "string(name: 'GATLING_MAX_STEP_USERS_PER_SEC', defaultValue: '50'"
assert_contains "string(name: 'GATLING_MAX_DURATION_SECONDS', defaultValue: '30'"
assert_contains "string(name: 'GATLING_MAX_LIMIT_USERS_PER_SEC', defaultValue: '1050'"

assert_contains 'GATLING_MAX_BASE_USERS_PER_SEC = "${params.GATLING_MAX_BASE_USERS_PER_SEC}"'
assert_contains 'GATLING_MAX_STEP_USERS_PER_SEC = "${params.GATLING_MAX_STEP_USERS_PER_SEC}"'
assert_contains 'GATLING_MAX_DURATION_SECONDS = "${params.GATLING_MAX_DURATION_SECONDS}"'
assert_contains 'GATLING_MAX_LIMIT_USERS_PER_SEC = "${params.GATLING_MAX_LIMIT_USERS_PER_SEC}"'

assert_not_contains "string(name: 'GATLING_MAX_START_USERS_PER_SEC'"
assert_not_contains "string(name: 'GATLING_MAX_LEVEL_COUNT'"
assert_not_contains "string(name: 'GATLING_MAX_DISCOVERY_ATTEMPTS'"
assert_not_contains "booleanParam(name: 'GATLING_MAX_SINGLE_LEVEL_MODE'"
assert_not_contains '-e GATLING_MAX_START_USERS_PER_SEC=${env.GATLING_MAX_START_USERS_PER_SEC}'
assert_not_contains '-e GATLING_MAX_LEVEL_COUNT=${env.GATLING_MAX_LEVEL_COUNT}'
assert_not_contains '-e GATLING_MAX_LEVEL_SECONDS=${env.GATLING_MAX_LEVEL_SECONDS}'
assert_not_contains '-e GATLING_MAX_DISCOVERY_ATTEMPTS=${env.GATLING_MAX_DISCOVERY_ATTEMPTS}'
assert_not_contains '-e GATLING_MAX_SINGLE_LEVEL_MODE=${env.GATLING_MAX_SINGLE_LEVEL_MODE}'

printf '%s\n' 'Jenkinsfile Gatling max-limit parameter checks passed'
