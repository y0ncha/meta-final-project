---
goal: Jenkins Freestyle Monitoring Job With UptimeRobot Evidence
version: 2.0
date_created: 2026-06-10
last_updated: 2026-06-11
owner: Project team
status: "Completed"
tags:
  - infrastructure
  - jenkins
  - monitoring
  - devops-final-project
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

This plan implements the instructor-confirmed monitoring split. The Jenkins CI/CD Pipeline job `meta-ci-cd` remains responsible for build, deployment, Tomcat verification, Playwright, Gatling, and reports. The separate Jenkins Freestyle job `meta-monitoring` runs every 5 minutes and calls source-controlled script `scripts/run-monitoring-check`. Official monitor evidence must come from UptimeRobot by default, with SiteMonitorLite allowed only when documented.

## 1. Requirements & Constraints

- **REQ-001**: Keep CI/CD job name `meta-ci-cd`.
- **REQ-002**: Keep CI/CD job script path `Jenkinsfile`.
- **REQ-003**: Use monitoring job name `meta-monitoring`.
- **REQ-004**: Configure `meta-monitoring` as Jenkins job type `Freestyle project`.
- **REQ-005**: Configure `meta-monitoring` trigger `Build periodically` with schedule `H/5 * * * *`.
- **REQ-006**: Configure `meta-monitoring` build step `Execute shell` with command `./scripts/run-monitoring-check`.
- **REQ-007**: Configure `meta-monitoring` post-build action to archive artifact pattern `output/monitoring/**/*`.
- **REQ-008**: Remove the old monitoring Pipeline file; Freestyle jobs do not execute Jenkinsfiles.
- **REQ-009**: Add `scripts/run-monitoring-check` with default `APP_BASE_URL=http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`, default `JOB_NAME=meta-monitoring`, and default `BUILD_NUMBER=local`.
- **REQ-010**: Ensure `scripts/run-monitoring-check` runs only a bounded HTTP monitoring check with `curl --connect-timeout 5 --max-time 15 -fsS "$APP_BASE_URL" >/dev/null`.
- **REQ-011**: Ensure `scripts/run-monitoring-check` writes monitoring evidence to `output/monitoring/latest-check.txt`.
- **REQ-012**: Keep UptimeRobot as the preferred official external monitor evidence.
- **REQ-013**: Allow SiteMonitorLite only as a documented fallback monitor tool.
- **REQ-014**: Use “monitoring” for the feature and Jenkins job naming; use “availability monitor” only when describing the assignment wording or app availability semantics.
- **CON-001**: Stay on the current branch `feature/09-monitoring-and-jenkins-schedule`.
- **CON-002**: Read `contribution.md` and `rules/compliance.md` before implementation.
- **CON-003**: Do not run Gatling directly while implementing or validating this plan.
- **CON-004**: Do not introduce Jenkins Job DSL or Jenkins Configuration as Code.
- **SEC-001**: Do not commit Jenkins credentials, GitHub tokens, UptimeRobot credentials, SiteMonitorLite credentials, cookies, API keys, or private keys.
- **PAT-001**: Source-controlled reusable shell commands belong in `scripts/`; defense documentation belongs under `docs/`; implementation closeout belongs in `docs/changelog/`.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Prepare the current branch and remove the misleading Pipeline monitoring file.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Run `rtk git status` and confirm the current branch is `feature/09-monitoring-and-jenkins-schedule`. | ✅ | 2026-06-11 |
| TASK-002 | Read `contribution.md`, `rules/compliance.md`, `docs/plans/09-monitoring-and-jenkins-schedule.md`, and `docs/changelog/09-monitoring-and-jenkins-schedule.changelog.md`. | ✅ | 2026-06-11 |
| TASK-003 | Delete the old monitoring Pipeline file because a Jenkins Freestyle job does not load Jenkinsfiles. | ✅ | 2026-06-11 |
| TASK-004 | Add executable script `scripts/run-monitoring-check`. | ✅ | 2026-06-11 |

### Implementation Phase 2

- GOAL-002: Define the Freestyle monitoring command and evidence contract.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-005 | Implement `scripts/run-monitoring-check` with `set -eu`, default `APP_BASE_URL=http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`, default `JOB_NAME=meta-monitoring`, and default `BUILD_NUMBER=local`. | ✅ | 2026-06-11 |
| TASK-006 | In `scripts/run-monitoring-check`, create `output/monitoring`, run bounded `curl --connect-timeout 5 --max-time 15 -fsS "$APP_BASE_URL" >/dev/null`, and write `output/monitoring/latest-check.txt`. | ✅ | 2026-06-11 |
| TASK-007 | Ensure `scripts/run-monitoring-check` does not invoke Maven, deployment, Playwright, Gatling, Docker, or Jenkins Pipeline syntax. | ✅ | 2026-06-11 |

### Implementation Phase 3

- GOAL-003: Update policy and documentation for Freestyle monitoring plus official monitor evidence.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-008 | Update `rules/compliance.md` to require separate Jenkins Freestyle monitoring job `meta-monitoring`. | ✅ | 2026-06-11 |
| TASK-009 | Update `docs/monitoring.md` with Freestyle setup, `./scripts/run-monitoring-check`, archive pattern `output/monitoring/**/*`, UptimeRobot preference, and SiteMonitorLite fallback. | ✅ | 2026-06-11 |
| TASK-010 | Update `docs/jenkins.md`, `docs/architecture.md`, `docs/submission.md`, and `docs/gatling.md` so current setup references Freestyle job `meta-monitoring`, not the old Pipeline monitoring contract. | ✅ | 2026-06-11 |
| TASK-011 | Update `docs/plans/05-jenkins-container-ci-cd.md` and `docs/changelog/05-jenkins-container-ci-cd.changelog.md` so Plan 05 points to Freestyle monitoring in Plan 09. | ✅ | 2026-06-11 |
| TASK-012 | Rewrite `docs/plans/09-monitoring-and-jenkins-schedule.md` in this required template for the Freestyle monitoring design. | ✅ | 2026-06-11 |
| TASK-013 | Update `docs/changelog/09-monitoring-and-jenkins-schedule.changelog.md` with a follow-up section explaining the Pipeline-to-Freestyle correction. | ✅ | 2026-06-11 |

### Implementation Phase 4

- GOAL-004: Validate the Freestyle monitoring update without running Gatling.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-014 | Run the removed-file check for the old monitoring Pipeline file. | ✅ | 2026-06-11 |
| TASK-015 | Run `test -x scripts/run-monitoring-check`. | ✅ | 2026-06-11 |
| TASK-016 | Run `sh -n scripts/run-monitoring-check`. | ✅ | 2026-06-11 |
| TASK-017 | Run stale-reference scan for the old monitoring Pipeline file, old monitor job name, and old Pipeline-monitoring setup. | ✅ | 2026-06-11 |
| TASK-018 | Run new-reference scan for `meta-monitoring`, `scripts/run-monitoring-check`, `Freestyle`, `UptimeRobot`, and `SiteMonitorLite`. | ✅ | 2026-06-11 |
| TASK-019 | Run `docker compose config --quiet`. | ✅ | 2026-06-11 |
| TASK-020 | Run local compliance validator against `rules/compliance.md`. | ✅ | 2026-06-11 |
| TASK-021 | If Tomcat is reachable at `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`, run `APP_BASE_URL=http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ ./scripts/run-monitoring-check`; otherwise document the blocker. | ✅ | 2026-06-11 |
| TASK-022 | Add and run `tests/scripts/test-run-monitoring-check.sh` to prove the Freestyle command uses bounded curl timeouts and still writes monitoring evidence. | ✅ | 2026-06-11 |

## 3. Alternatives

- **ALT-001**: Keep a second Jenkinsfile as a Pipeline job. Rejected because the user chose Freestyle for simpler instructor-facing monitoring evidence and Freestyle jobs do not consume Jenkinsfiles.
- **ALT-002**: Put the monitoring shell directly in the Jenkins Freestyle UI. Rejected because keeping the command in `scripts/run-monitoring-check` makes the check reviewable and reusable while still using a Freestyle job.
- **ALT-003**: Use UptimeRobot only and remove Jenkins-side monitoring. Rejected because the assignment requires Jenkins to trigger monitoring every 5 minutes.
- **ALT-004**: Use SiteMonitorLite as the default official monitor. Rejected because project policy prefers UptimeRobot; SiteMonitorLite remains an acceptable documented fallback.

## 4. Dependencies

- **DEP-001**: Docker Compose service `tomcat` must be running on Docker network `meta` for Jenkins-side `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` checks.
- **DEP-002**: Jenkins service `jenkins` must be running for the Freestyle job to execute.
- **DEP-003**: Jenkins job `meta-monitoring` must checkout or otherwise run from a workspace containing `scripts/run-monitoring-check`.
- **DEP-004**: UptimeRobot account access is required to capture preferred official external monitor evidence.
- **DEP-005**: SiteMonitorLite is acceptable only when documented as the monitor tool used.

## 5. Files

- **FILE-001**: Old monitoring Pipeline file - deleted because Freestyle jobs do not execute Jenkinsfiles.
- **FILE-002**: `scripts/run-monitoring-check` - source-controlled Freestyle Execute shell command.
- **FILE-003**: `rules/compliance.md` - monitoring job requirement changed from Pipeline to Freestyle.
- **FILE-004**: `docs/monitoring.md`, `docs/jenkins.md`, `docs/architecture.md`, `docs/submission.md`, and `docs/gatling.md` - current monitoring setup documentation.
- **FILE-005**: `docs/plans/05-jenkins-container-ci-cd.md` and `docs/changelog/05-jenkins-container-ci-cd.changelog.md` - cross-plan references to Plan 09.
- **FILE-006**: `docs/plans/09-monitoring-and-jenkins-schedule.md` - this source implementation plan.
- **FILE-007**: `docs/changelog/09-monitoring-and-jenkins-schedule.changelog.md` - closeout changelog.
- **FILE-008**: `tests/scripts/test-run-monitoring-check.sh` - shell regression test for bounded monitoring curl behavior and evidence output.

## 6. Testing

- **TEST-001**: `rtk git status` must show branch `feature/09-monitoring-and-jenkins-schedule` and only scoped Plan 09 changes.
- **TEST-002**: The removed-file check for the old monitoring Pipeline file must pass.
- **TEST-003**: `test -x scripts/run-monitoring-check` must pass.
- **TEST-004**: `sh -n scripts/run-monitoring-check` must pass.
- **TEST-005**: Stale-reference scan for the old monitoring Pipeline file, old monitor job name, and old Pipeline-monitoring setup must return no current required setup references.
- **TEST-006**: `rg -n "meta-monitoring|scripts/run-monitoring-check|Freestyle|UptimeRobot|SiteMonitorLite" docs rules scripts` must show the new monitoring setup.
- **TEST-007**: `docker compose config --quiet` must pass.
- **TEST-008**: `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md` must pass with zero failures.
- **TEST-009**: If Tomcat is reachable locally, `APP_BASE_URL=http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ ./scripts/run-monitoring-check` must pass.
- **TEST-010**: No Gatling command may be run directly for this plan.
- **TEST-011**: `sh tests/scripts/test-run-monitoring-check.sh` must pass and prove `scripts/run-monitoring-check` calls curl with `--connect-timeout 5` and `--max-time 15`.

## 7. Risks & Assumptions

- **RISK-001**: Jenkins Freestyle job configuration lives in Jenkins UI/config, not in Git; documentation must be clear enough to reproduce it during defense.
- **RISK-002**: Final submission still needs a real UptimeRobot or documented SiteMonitorLite passed screenshot.
- **RISK-003**: Local runtime validation depends on Tomcat being reachable at `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **ASSUMPTION-001**: The instructor accepts a separate Freestyle Jenkins job for the Jenkins-triggered monitoring requirement.
- **ASSUMPTION-002**: UptimeRobot remains the preferred official monitor evidence source.
- **ASSUMPTION-003**: SiteMonitorLite is used only if the project documents why it replaced UptimeRobot.

## 8. Related Specifications / Further Reading

- [Project contribution workflow](../../contribution.md)
- [Project compliance rules](../../rules/compliance.md)
- [Jenkins documentation](../jenkins.md)
- [Monitoring documentation](../monitoring.md)
- [Jenkins Freestyle project documentation](https://www.jenkins.io/doc/book/pipeline/getting-started/#freestyle-projects)
