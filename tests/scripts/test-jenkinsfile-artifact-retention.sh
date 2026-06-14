#!/usr/bin/env sh
set -eu

PROJECT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd -P)
JENKINSFILE="$PROJECT_ROOT/Jenkinsfile"

assert_contains() {
  pattern=$1
  if ! grep -Fq "$pattern" "$JENKINSFILE"; then
    printf 'Expected Jenkinsfile to contain: %s\n' "$pattern" >&2
    exit 1
  fi
}

assert_not_contains() {
  pattern=$1
  if grep -Fq "$pattern" "$JENKINSFILE"; then
    printf 'Expected Jenkinsfile not to contain: %s\n' "$pattern" >&2
    exit 1
  fi
}

assert_contains "buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '5'))"
assert_contains "archiveArtifacts artifacts: 'output/**/*', excludes: 'output/gatling/**/raw/**,output/gatling/**/*-run.log,output/gatling/**/simulation.log', allowEmptyArchive: true"
assert_contains "publishDir: 'output/jenkins-html/gatling/max-limit'"
assert_contains "publishDir: 'output/jenkins-html/gatling/load-5m'"
assert_contains "publishDir: 'output/jenkins-html/gatling/stress-5m'"
assert_contains "reportDir: report.publishDir"
assert_contains "keepAll: false"

assert_not_contains "archiveArtifacts artifacts: 'output/**/*', allowEmptyArchive: true"
assert_not_contains "reportDir: report.dir,"

printf '%s\n' 'Jenkinsfile artifact retention checks passed'
