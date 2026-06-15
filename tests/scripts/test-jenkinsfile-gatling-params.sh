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

assert_contains "choice(name: 'APP_BASE_URL', choices: ['http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/', 'http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/']"
assert_contains "string(name: 'GATLING_MAX_BASE_USERS', defaultValue: '8000'"
assert_contains "string(name: 'GATLING_MAX_STEP_USERS', defaultValue: '20'"
assert_contains "string(name: 'GATLING_MAX_DURATION_SECONDS', defaultValue: '10'"
assert_contains "string(name: 'GATLING_MAX_LIMIT_USERS', defaultValue: '12000'"
assert_contains "choice(name: 'GATLING_CONSOLE_MODE', choices: ['summary', 'full']"

assert_contains 'GATLING_MAX_BASE_USERS = "${params.GATLING_MAX_BASE_USERS}"'
assert_contains 'GATLING_MAX_STEP_USERS = "${params.GATLING_MAX_STEP_USERS}"'
assert_contains 'GATLING_MAX_DURATION_SECONDS = "${params.GATLING_MAX_DURATION_SECONDS}"'
assert_contains 'GATLING_MAX_LIMIT_USERS = "${params.GATLING_MAX_LIMIT_USERS}"'
assert_contains 'GATLING_CONSOLE_MODE = "${params.GATLING_CONSOLE_MODE}"'

assert_not_contains "string(name: 'GATLING_MAX_BASE_USERS_PER_SEC'"
assert_not_contains "string(name: 'GATLING_MAX_STEP_USERS_PER_SEC'"
assert_not_contains "string(name: 'GATLING_MAX_LIMIT_USERS_PER_SEC'"
assert_not_contains "string(name: 'GATLING_MAX_START_USERS_PER_SEC'"
assert_not_contains "string(name: 'GATLING_MAX_LEVEL_COUNT'"
assert_not_contains "string(name: 'GATLING_MAX_DISCOVERY_ATTEMPTS'"
assert_not_contains "booleanParam(name: 'GATLING_MAX_SINGLE_LEVEL_MODE'"
assert_not_contains '-e GATLING_MAX_START_USERS_PER_SEC=${env.GATLING_MAX_START_USERS_PER_SEC}'
assert_not_contains '-e GATLING_MAX_LEVEL_COUNT=${env.GATLING_MAX_LEVEL_COUNT}'
assert_not_contains '-e GATLING_MAX_LEVEL_SECONDS=${env.GATLING_MAX_LEVEL_SECONDS}'
assert_not_contains '-e GATLING_MAX_DISCOVERY_ATTEMPTS=${env.GATLING_MAX_DISCOVERY_ATTEMPTS}'
assert_not_contains '-e GATLING_MAX_SINGLE_LEVEL_MODE=${env.GATLING_MAX_SINGLE_LEVEL_MODE}'
assert_not_contains 'GATLING_LOAD_USERS_PER_SEC'
assert_not_contains 'GATLING_STRESS_START_USERS_PER_SEC'
assert_not_contains 'GATLING_STRESS_TARGET_USERS_PER_SEC'
assert_contains '-e GATLING_CONSOLE_MODE=${env.GATLING_CONSOLE_MODE}'

assert_contains "booleanParam(name: 'RUN_GATLING_MAX_LIMIT', defaultValue: false"
assert_contains "booleanParam(name: 'RUN_GATLING_LOAD_TEST', defaultValue: false"
assert_contains "booleanParam(name: 'RUN_GATLING_STRESS_TEST', defaultValue: false"
assert_contains "expression { params.RUN_GATLING_MAX_LIMIT }"
assert_contains "expression { params.RUN_GATLING_LOAD_TEST }"
assert_contains "expression { params.RUN_GATLING_STRESS_TEST }"
assert_not_contains "RUN_GATLING_TESTS"
assert_not_contains "defaultValue: '200'"
assert_not_contains "defaultValue: '1050'"

run_max_limit_count=$(grep -F "expression { params.RUN_GATLING_MAX_LIMIT }" "$JENKINSFILE" | wc -l | tr -d ' ')
if [ "$run_max_limit_count" != "1" ]; then
  printf 'Expected 1 RUN_GATLING_MAX_LIMIT stage gate, got %s\n' "$run_max_limit_count" >&2
  exit 1
fi

run_load_count=$(grep -F "expression { params.RUN_GATLING_LOAD_TEST }" "$JENKINSFILE" | wc -l | tr -d ' ')
if [ "$run_load_count" != "1" ]; then
  printf 'Expected 1 RUN_GATLING_LOAD_TEST stage gate, got %s\n' "$run_load_count" >&2
  exit 1
fi

run_stress_count=$(grep -F "expression { params.RUN_GATLING_STRESS_TEST }" "$JENKINSFILE" | wc -l | tr -d ' ')
if [ "$run_stress_count" != "1" ]; then
  printf 'Expected 1 RUN_GATLING_STRESS_TEST stage gate, got %s\n' "$run_stress_count" >&2
  exit 1
fi

printf '%s\n' 'Jenkinsfile Gatling parameter checks passed'
