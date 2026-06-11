#!/usr/bin/env sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd -P)
EXPECTED_CONTEXT="yonatan-csasznik-yoed-halberstam-niv-levin"
EXPECTED_LOCAL_URL="http://localhost:8080/$EXPECTED_CONTEXT/"
EXPECTED_DOCKER_URL="http://tomcat:8080/$EXPECTED_CONTEXT/"

assert_file_contains() {
  file="$1"
  pattern="$2"
  if ! grep -Fq "$pattern" "$PROJECT_ROOT/$file"; then
    printf 'Expected %s to contain: %s\n' "$file" "$pattern" >&2
    exit 1
  fi
}

assert_file_not_contains() {
  file="$1"
  pattern="$2"
  if grep -Fq "$pattern" "$PROJECT_ROOT/$file"; then
    printf 'Expected %s not to contain: %s\n' "$file" "$pattern" >&2
    exit 1
  fi
}

assert_file_contains pom.xml "<finalName>$EXPECTED_CONTEXT</finalName>"
assert_file_contains scripts/deploy-war "TOMCAT_CONTEXT=\"\${TOMCAT_CONTEXT:-$EXPECTED_CONTEXT}\""
assert_file_contains scripts/deploy-war "WAR_SOURCE=\"\${WAR_SOURCE:-target/$EXPECTED_CONTEXT.war}\""
assert_file_contains scripts/deploy-war 'MeTA.war'
assert_file_contains scripts/deploy-war 'meta.war'
assert_file_contains Jenkinsfile "APP_BASE_URL = '$EXPECTED_DOCKER_URL'"
assert_file_contains Jenkinsfile "TOMCAT_CONTEXT = '$EXPECTED_CONTEXT'"
assert_file_contains Jenkinsfile "target/$EXPECTED_CONTEXT.war"
assert_file_contains playwright.config.js "$EXPECTED_LOCAL_URL"
assert_file_contains scripts/run-monitoring-check "$EXPECTED_DOCKER_URL"
assert_file_contains scripts/run-playwright-container "$EXPECTED_DOCKER_URL"
assert_file_contains scripts/capture-har "$EXPECTED_DOCKER_URL"
assert_file_contains scripts/run-gatling-container "$EXPECTED_DOCKER_URL"
assert_file_contains src/gatling/user-files/simulations/MetaSimulation.scala "$EXPECTED_DOCKER_URL"
assert_file_contains tests/playwright/capture-har.js "$EXPECTED_LOCAL_URL"
assert_file_contains scripts/validate-har "/$EXPECTED_CONTEXT/"

assert_file_not_contains scripts/deploy-war 'TOMCAT_CONTEXT must remain MeTA'
assert_file_not_contains Jenkinsfile 'target/MeTA.war'
assert_file_not_contains playwright.config.js 'http://localhost:8080/MeTA/'
assert_file_not_contains docs/submission.md 'http://localhost:8080/MeTA/'

printf '%s\n' 'context path default checks passed'
