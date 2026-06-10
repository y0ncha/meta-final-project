---
goal: Separate Jenkins Availability Monitoring Job
version: 1.0
date_created: 2026-06-10
last_updated: 2026-06-10
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

This plan implements the instructor-confirmed Jenkins job split for availability monitoring. The existing Jenkins CI/CD job `meta-container-ci-cd` remains responsible for build, deployment, Tomcat verification, Playwright, Gatling, and reports. A separate Jenkins Pipeline job `meta-availability-monitor` runs every 5 minutes from `Jenkinsfile.availability` and performs only the application availability check.

## 1. Requirements & Constraints

- **REQ-001**: Keep CI/CD job name `meta-container-ci-cd`.
- **REQ-002**: Keep CI/CD job script path `Jenkinsfile`.
- **REQ-003**: Add monitoring job name `meta-availability-monitor`.
- **REQ-004**: Add monitoring job script path `Jenkinsfile.availability`.
- **REQ-005**: Configure the monitoring job schedule as `H/5 * * * *`.
- **REQ-006**: Configure the monitoring target as `http://tomcat:8080/meta/` for local Jenkins evidence.
- **REQ-007**: Remove the `H/5 * * * *` cron trigger from `Jenkinsfile`.
- **REQ-008**: Remove all `TimerTrigger` gating from `Jenkinsfile`.
- **REQ-009**: Rename CI/CD stage `Availability Check` back to `Verify Tomcat`.
- **REQ-010**: Ensure `Jenkinsfile.availability` does not run Maven, `scripts/deploy-war`, Playwright, Gatling, or Gatling environment variables.
- **REQ-011**: Write monitoring evidence to `output/monitoring/latest-check.txt`.
- **REQ-012**: Archive monitoring evidence with artifact pattern `output/monitoring/**/*`.
- **REQ-013**: Keep UptimeRobot as the official external monitor evidence unless explicitly replaced by the instructor.
- **REQ-014**: Update project documentation so two Jenkins jobs are defensible during live review.
- **CON-001**: Read `contribution.md` and `rules/compliance.md` before implementation.
- **CON-002**: Do not run Gatling directly while implementing or validating this plan.
- **CON-003**: Do not introduce Jenkins Job DSL, Jenkins Configuration as Code, freestyle jobs, or UI-only shell scripts.
- **SEC-001**: Do not commit Jenkins credentials, GitHub tokens, UptimeRobot credentials, cookies, API keys, or private keys.
- **PAT-001**: Source-controlled Jenkins behavior belongs in root Jenkinsfiles; defense documentation belongs under `docs/`; implementation closeout belongs in `docs/changelog/`.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Prepare the branch and confirm the plan does not conflict with project policy.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Read `contribution.md` and `rules/compliance.md`; confirm the instructor-approved separate monitoring job does not conflict with compliance policy after updating the policy text. | ✅ | 2026-06-10 |
| TASK-002 | Run `rtk git status`; confirm the working tree is clean before branching. | ✅ | 2026-06-10 |
| TASK-003 | Create and switch to branch `feature/09-monitoring-and-jenkins-schedule`. | ✅ | 2026-06-10 |
| TASK-004 | Rewrite `docs/plans/09-monitoring-and-jenkins-schedule.md` in the required structured template. | ✅ | 2026-06-10 |

### Implementation Phase 2

- GOAL-002: Split Jenkins availability monitoring from the CI/CD job.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-005 | Update `Jenkinsfile` to remove `cron('H/5 * * * *')` and keep only `pollSCM('H/2 * * * *')` as the source-controlled CI/CD trigger. | ✅ | 2026-06-10 |
| TASK-006 | Update `Jenkinsfile` to remove every `triggeredBy 'TimerTrigger'` condition. | ✅ | 2026-06-10 |
| TASK-007 | Update `Jenkinsfile` to rename stage `Availability Check` to `Verify Tomcat`. | ✅ | 2026-06-10 |
| TASK-008 | Add `Jenkinsfile.availability` with schedule `H/5 * * * *`, target `http://tomcat:8080/meta/`, artifact output `output/monitoring/latest-check.txt`, and archive pattern `output/monitoring/**/*`. | ✅ | 2026-06-10 |
| TASK-009 | Verify `Jenkinsfile.availability` contains no Maven build, deploy, Playwright, Gatling, or Gatling environment-variable commands. | ✅ | 2026-06-10 |

### Implementation Phase 3

- GOAL-003: Update documentation and project policy.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-010 | Update `rules/compliance.md` to record the instructor-confirmed separate monitoring job requirement. | ✅ | 2026-06-10 |
| TASK-011 | Update `docs/jenkins.md` to document jobs `meta-container-ci-cd` and `meta-availability-monitor`, script paths `Jenkinsfile` and `Jenkinsfile.availability`, and their schedules. | ✅ | 2026-06-10 |
| TASK-012 | Update `docs/architecture.md` to show the CI/CD job and availability monitoring job as separate Jenkins Pipeline jobs. | ✅ | 2026-06-10 |
| TASK-013 | Update `docs/submission.md` so final evidence expects both Jenkins jobs and no longer expects timer-only evidence from `meta-container-ci-cd`. | ✅ | 2026-06-10 |
| TASK-014 | Update `docs/gatling.md` so Gatling documentation references the separate monitoring job instead of timer-triggered CI/CD builds. | ✅ | 2026-06-10 |
| TASK-015 | Add `docs/monitoring.md` with monitoring job setup, behavior, evidence, and defense checklist. | ✅ | 2026-06-10 |
| TASK-016 | Update `scripts/generate-pipeline-report` so the CI/CD report does not list `Availability Check` as a CI/CD stage. | ✅ | 2026-06-10 |
| TASK-017 | Update `docs/plans/05-jenkins-container-ci-cd.md` to supersede the old timer-triggered availability wording. | ✅ | 2026-06-10 |

### Implementation Phase 4

- GOAL-004: Validate the implementation without running Gatling.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-018 | Run `docker compose config --quiet`. | ✅ | 2026-06-10 |
| TASK-019 | Run `sh -n scripts/generate-pipeline-report`. | ✅ | 2026-06-10 |
| TASK-020 | Run `if rg -n "cron\\('H/5|TimerTrigger" Jenkinsfile; then exit 1; fi`. | ✅ | 2026-06-10 |
| TASK-021 | Run `rg -n "cron\\('H/5 \\* \\* \\* \\*'\\)" Jenkinsfile.availability`. | ✅ | 2026-06-10 |
| TASK-022 | Run `if rg -n "mvn -B clean package|scripts/deploy-war|run-playwright|run-gatling|RUN_GATLING" Jenkinsfile.availability; then exit 1; fi`. | ✅ | 2026-06-10 |
| TASK-023 | Validate both Jenkinsfiles with Jenkins declarative linter when Jenkins is running; otherwise document the runtime blocker. | ✅ | 2026-06-10 |
| TASK-024 | Run the local compliance validator against `rules/compliance.md`. | ✅ | 2026-06-10 |
| TASK-025 | Create `docs/changelog/09-monitoring-and-jenkins-schedule.changelog.md` with implementation summary, validation commands, evidence, and remaining risks. | ✅ | 2026-06-10 |

## 3. Alternatives

- **ALT-001**: Keep one trigger-aware Jenkins job with timer-gated stages. Rejected because the instructor confirmed monitoring should be a separate Jenkins job.
- **ALT-002**: Create a Jenkins freestyle monitoring job through the UI. Rejected because source-controlled Pipeline jobs are easier to reproduce, review, and defend.
- **ALT-003**: Introduce Jenkins Job DSL or Jenkins Configuration as Code. Rejected because it is unnecessary scope this late in the coursework project.
- **ALT-004**: Use UptimeRobot only and remove Jenkins-side monitoring. Rejected because the assignment requires Jenkins to trigger monitoring every 5 minutes.

## 4. Dependencies

- **DEP-001**: Docker Compose service `tomcat` must be running on Docker network `meta`.
- **DEP-002**: Jenkins service `jenkins` must be running and able to resolve `tomcat`.
- **DEP-003**: Jenkins job `meta-container-ci-cd` must be configured as Pipeline script from SCM with script path `Jenkinsfile`.
- **DEP-004**: Jenkins job `meta-availability-monitor` must be configured as Pipeline script from SCM with script path `Jenkinsfile.availability`.
- **DEP-005**: The active branch configured in both Jenkins jobs must contain `Jenkinsfile` and `Jenkinsfile.availability`.
- **DEP-006**: UptimeRobot account access is required to capture official external monitor evidence.

## 5. Files

- **FILE-001**: `Jenkinsfile` - CI/CD Pipeline job definition with SCM/manual build, deploy, verify, Playwright, Gatling, and report stages.
- **FILE-002**: `Jenkinsfile.availability` - separate scheduled availability Pipeline job definition.
- **FILE-003**: `rules/compliance.md` - instructor-approved split recorded in compliance policy.
- **FILE-004**: `docs/jenkins.md` - Jenkins job setup, stages, schedule, and evidence documentation.
- **FILE-005**: `docs/architecture.md` - architecture diagrams and runtime notes updated for two Jenkins jobs.
- **FILE-006**: `docs/submission.md` - final evidence checklist updated for separate monitoring evidence.
- **FILE-007**: `docs/gatling.md` - Gatling integration notes updated so availability monitoring is not described as a timer-triggered CI/CD build.
- **FILE-008**: `docs/monitoring.md` - new monitoring setup and defense documentation.
- **FILE-009**: `scripts/generate-pipeline-report` - CI/CD report stage list updated.
- **FILE-010**: `docs/plans/05-jenkins-container-ci-cd.md` - old timer-triggered availability design superseded.
- **FILE-011**: `docs/plans/09-monitoring-and-jenkins-schedule.md` - this source implementation plan.
- **FILE-012**: `docs/changelog/09-monitoring-and-jenkins-schedule.changelog.md` - closeout changelog.

## 6. Testing

- **TEST-001**: `rtk git status` must show the current branch and tracked changes only for this plan.
- **TEST-002**: `docker compose config --quiet` must pass.
- **TEST-003**: `sh -n scripts/generate-pipeline-report` must pass.
- **TEST-004**: `if rg -n "cron\\('H/5|TimerTrigger" Jenkinsfile; then exit 1; fi` must pass.
- **TEST-005**: `rg -n "cron\\('H/5 \\* \\* \\* \\*'\\)" Jenkinsfile.availability` must find the monitoring schedule.
- **TEST-006**: `if rg -n "mvn -B clean package|scripts/deploy-war|run-playwright|run-gatling|RUN_GATLING" Jenkinsfile.availability; then exit 1; fi` must pass.
- **TEST-007**: Jenkins declarative linter must validate `Jenkinsfile` when Jenkins is running.
- **TEST-008**: Jenkins declarative linter must validate `Jenkinsfile.availability` when Jenkins is running.
- **TEST-009**: The local compliance validator must run against `rules/compliance.md`.
- **TEST-010**: No Gatling command may be run directly for this plan.

## 7. Risks & Assumptions

- **RISK-001**: Live Jenkins validation depends on the Jenkins container running and having automation credentials available in `/var/jenkins_home/codex-automation.env`.
- **RISK-002**: The SCM-backed Jenkins jobs validate committed branch content. Local uncommitted Jenkinsfile changes must be validated through the declarative linter before commit.
- **RISK-003**: UptimeRobot evidence still requires manual account access and screenshot capture before final submission.
- **RISK-004**: Jenkins UI configuration must point both jobs at the same branch during branch validation and at `main` after merge.
- **ASSUMPTION-001**: The instructor confirmation is the documented reason to split availability monitoring from the CI/CD job.
- **ASSUMPTION-002**: Local Jenkins monitoring target remains `http://tomcat:8080/meta/`.
- **ASSUMPTION-003**: Public-IP bonus work, if pursued later, will update monitoring target and evidence separately.

## 8. Related Specifications / Further Reading

- [Project contribution workflow](../../contribution.md)
- [Project compliance rules](../../rules/compliance.md)
- [Jenkins documentation](../jenkins.md)
- [Monitoring documentation](../monitoring.md)
- [Jenkins Pipeline syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
