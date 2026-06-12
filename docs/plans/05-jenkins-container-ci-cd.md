---
goal: Jenkins Docker Pipeline execution for Playwright and Gatling containers
version: 2.0
date_created: 2026-06-10
last_updated: 2026-06-11
owner: Project team
status: "Completed"
tags:
  - infrastructure
  - ci-cd
  - jenkins
  - docker
  - docker-pipeline
  - devops-final-project
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

This follow-up refactors the completed Jenkins container CI/CD plan so Jenkins runs Playwright, HAR/PDF export, and Gatling test containers through Jenkins Docker Pipeline (`docker-workflow`) instead of Compose profiled one-shot services. The Compose runtime must keep only long-running coursework services `tomcat` and `jenkins`. Tomcat deployment remains shared-volume based through `/tomcat-webapps`; Jenkins must not deploy `target/yonatan-csasznik-yoed-halberstam-niv-levin.war` by controlling Docker.

## 1. Requirements & Constraints

- **REQ-001**: Keep follow-up changes on the current working branch unless the user explicitly asks for branch movement; this closeout runs from `feature/05-jenkins-container-ci-cd` before merging back to `main`.
- **REQ-002**: Keep Compose project name `meta`, service `tomcat`, service `jenkins`, network `meta`, volume `tomcat_webapps`, and volume `jenkins_home`.
- **REQ-003**: Keep Tomcat exposed at `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` and Jenkins exposed at `http://localhost:8081/`.
- **REQ-004**: Keep Jenkins deployment through `target/yonatan-csasznik-yoed-halberstam-niv-levin.war` copied to the shared Tomcat webapps volume mounted at `/tomcat-webapps`.
- **REQ-005**: Keep Jenkins plugins `docker-workflow`, `htmlpublisher`, and `gatling` installed by `ops/jenkins/Dockerfile`.
- **REQ-006**: Keep pre-test validation under the stage that owns the relevant check: `Pre Actions` runs `docker --version`, `docker compose version`, and `docker info`; `Playwright Functional Test` validates the Playwright container workspace, checked-out commit identity, and Tomcat reachability; each Gatling stage validates its container workspace and runner script before execution.
- **REQ-007**: Run Playwright from `Jenkinsfile` with `docker.image(env.PLAYWRIGHT_IMAGE).inside(...)`.
- **REQ-008**: Run bounded full Gatling max-limit discovery from `Jenkinsfile` with `docker.image(env.GATLING_IMAGE).inside(...)` only when `RUN_GATLING_TESTS=true`.
- **REQ-009**: Run Gatling load and stress from `Jenkinsfile` with `docker.image(env.GATLING_IMAGE).inside(...)` only when `RUN_GATLING_TESTS=true`.
- **REQ-010**: Run Gatling PDF export from `Jenkinsfile` with `docker.image(env.PLAYWRIGHT_IMAGE).inside(...)` when Gatling HTML reports exist.
- **REQ-011**: Pass Docker Pipeline args that preserve Jenkins-in-Docker SCM workspace behavior: `--network meta`, `--volumes-from meta-jenkins`, working directory `env.WORKSPACE`, and explicit environment values including `APP_BASE_URL=http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **REQ-012**: Preserve local manual commands `./scripts/run-playwright-container`, `./scripts/run-gatling-max-limit`, `./scripts/run-gatling-load-5m`, `./scripts/run-gatling-stress-5m`, and `./scripts/export-gatling-pdfs`.
- **REQ-013**: Rewrite local runner scripts away from profiled Compose one-shot execution; local scripts must use direct disposable `docker run` wrappers.
- **REQ-014**: Remove the legacy Compose runner services for Playwright, HAR, Gatling, and their Jenkins workspace variants.
- **REQ-015**: Keep `docker-compose.yml` limited to regular services `tomcat` and `jenkins`; no `tools` profile services may remain.
- **REQ-016**: Keep generated evidence under ignored `output/` paths and do not delete required evidence unless regenerated.
- **REQ-017**: Keep the Jenkins job name `meta-container-ci-cd` and root `Jenkinsfile` as the source-controlled Pipeline entrypoint.
- **REQ-018**: Keep the Docker Pipeline preflight HTTP probe immune to Groovy and shell quote stripping; do not embed JavaScript string literals inside a nested `sh 'node -e "..."'` command.
- **REQ-019**: Superseded on 2026-06-10 by Plan 09. Keep `meta-container-ci-cd` focused on SCM/manual CI/CD work only; monitoring must run in separate Jenkins Freestyle job `meta-monitoring` using `scripts/run-monitoring-check`.
- **CON-001**: Read `contribution.md` and `rules/compliance.md` before mutating files.
- **CON-002**: Stop before editing if this plan conflicts with `rules/compliance.md`; no conflict was found because the rules prefer containerized Jenkins, Playwright, and Gatling.
- **CON-003**: Do not add Jenkins Docker Cloud agents or dynamic agent configuration.
- **CON-004**: Do not rely on host Jenkins, host Tomcat, `/Users/yonatan/.jenkins`, `/usr/local/tomcat8`, generated WAR files, Docker volume state, screenshots, logs, or secrets as tracked source.
- **SEC-001**: Do not write GitHub tokens, Jenkins admin passwords, API keys, cookies, private keys, or other secrets into tracked files.
- **SEC-002**: Do not use Docker control for Tomcat deployment; Docker access is only for Jenkins diagnostics and disposable test/report containers.
- **PAT-001**: Source plans live in `docs/plans/`, implementation closeout lives in `docs/changelog/`, automation lives in `scripts/`, and generated evidence lives under ignored `output/`.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Confirm execution context and rewrite the plan before implementation changes.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Read `contribution.md` and `rules/compliance.md`; confirm this follow-up does not conflict with project constraints. | ✅ | 2026-06-10 |
| TASK-002 | Run `git status --short --branch`; confirm the current branch and working tree state, and report unrelated work if present. | ✅ | 2026-06-10 |
| TASK-003 | Read current `docs/plans/05-jenkins-container-ci-cd.md`, `docs/changelog/05-jenkins-container-ci-cd.changelog.md`, `Jenkinsfile`, `docker-compose.yml`, and runner scripts before editing. | ✅ | 2026-06-10 |
| TASK-004 | Rewrite `docs/plans/05-jenkins-container-ci-cd.md` in place for this Docker Pipeline follow-up and set status to `In progress`. | ✅ | 2026-06-10 |

### Implementation Phase 2

- GOAL-002: Remove the obsolete Compose runner-service model.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-005 | In `docker-compose.yml`, delete the legacy Playwright, HAR, Gatling, and Jenkins-workspace runner services. | ✅ | 2026-06-10 |
| TASK-006 | Confirm `docker-compose.yml` keeps only services `tomcat` and `jenkins`. | ✅ | 2026-06-10 |
| TASK-007 | Keep Jenkins Docker socket mount and Docker CLI support because Docker Pipeline requires Jenkins to start disposable containers. | ✅ | 2026-06-10 |

### Implementation Phase 3

- GOAL-003: Make local scripts direct Docker wrappers and reusable Jenkins Docker Pipeline command bodies.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-008 | Update `scripts/run-playwright-container` so local execution uses `docker run --rm --network meta -v "$PROJECT_ROOT:/work" -w /work ... "$PLAYWRIGHT_IMAGE" /bin/bash -lc 'npm ci && npx playwright test'`. | ✅ | 2026-06-10 |
| TASK-009 | Update `scripts/run-playwright-container` so `PLAYWRIGHT_DOCKER_PIPELINE=1` runs `npm ci && npx playwright test` directly inside the Docker Pipeline container without launching Docker again. | ✅ | 2026-06-10 |
| TASK-010 | Update `scripts/run-gatling-container` so local execution uses `docker run --rm --platform "$GATLING_PLATFORM" --network meta -v "$PROJECT_ROOT:/work" -w /work ... "$GATLING_IMAGE"` with the existing Gatling arguments. | ✅ | 2026-06-10 |
| TASK-011 | Update `scripts/run-gatling-container` so `GATLING_DOCKER_PIPELINE=1` runs Gatling directly inside the Docker Pipeline container and preserves existing report normalization. | ✅ | 2026-06-10 |
| TASK-012 | Update `scripts/export-gatling-pdfs` so local execution uses direct `docker run` with the Playwright image and `GATLING_PDF_DOCKER_PIPELINE=1` runs the Node PDF exporter directly inside Docker Pipeline. | ✅ | 2026-06-10 |
| TASK-013 | Update `scripts/capture-har` away from Compose runner services so HAR capture remains a working manual helper after the legacy HAR runner service is removed. | ✅ | 2026-06-10 |
| TASK-014 | Preserve wrapper scripts `scripts/run-gatling-max-limit`, `scripts/run-gatling-load-5m`, and `scripts/run-gatling-stress-5m` as run-type entrypoints. | ✅ | 2026-06-10 |

### Implementation Phase 4

- GOAL-004: Move Jenkins test/report execution to Docker Pipeline.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-015 | Add Jenkins environment defaults for `PLAYWRIGHT_IMAGE`, `GATLING_IMAGE`, `GATLING_PLATFORM`, and Gatling load/stress/max settings. | ✅ | 2026-06-10 |
| TASK-016 | Add Jenkins container-readiness checks under the owning stages: Docker CLI/daemon checks in `Pre Actions`, Playwright workspace/commit/Tomcat checks in `Playwright Functional Test`, and Gatling workspace/runner checks in each Gatling stage. | ✅ | 2026-06-11 |
| TASK-017 | Update stage `Playwright Functional Test` to call `docker.image(env.PLAYWRIGHT_IMAGE).inside(...) { sh 'PLAYWRIGHT_DOCKER_PIPELINE=1 ./scripts/run-playwright-container' }`. | ✅ | 2026-06-10 |
| TASK-018 | Update stage `Gatling Max Limit` to call `docker.image(env.GATLING_IMAGE).inside(...) { sh 'GATLING_DOCKER_PIPELINE=1 GATLING_RUN_TYPE=max-limit ./scripts/run-gatling-max-limit' }`. | ✅ | 2026-06-11 |
| TASK-019 | Update stage `Gatling Load Test` to call `docker.image(env.GATLING_IMAGE).inside(...) { sh 'GATLING_DOCKER_PIPELINE=1 GATLING_RUN_TYPE=load-5m ./scripts/run-gatling-container' }`. | ✅ | 2026-06-10 |
| TASK-020 | Update stage `Gatling Stress Test` to call `docker.image(env.GATLING_IMAGE).inside(...) { sh 'GATLING_DOCKER_PIPELINE=1 GATLING_RUN_TYPE=stress-5m ./scripts/run-gatling-container' }`. | ✅ | 2026-06-10 |
| TASK-021 | Update the `post` Gatling PDF export to run `scripts/export-gatling-pdfs` inside a Playwright Docker Pipeline container with `GATLING_PDF_DOCKER_PIPELINE=1`. | ✅ | 2026-06-10 |

### Implementation Phase 5

- GOAL-005: Update documentation and closeout evidence.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-022 | Update `docs/jenkins.md` so Jenkins test/report stages describe Docker Pipeline, not Compose one-shot services. | ✅ | 2026-06-10 |
| TASK-023 | Update `docs/playwright.md`, `docs/gatling.md`, `docs/har-scenario.md`, `docs/plans/06-playwright-container-functional-test.md`, `docs/plans/07-har-capture.md`, and `docs/plans/08-gatling-container-tests.md` only where needed to remove current-runner references to Compose profiled services. | ✅ | 2026-06-10 |
| TASK-024 | Update `docs/changelog/05-jenkins-container-ci-cd.changelog.md` with implementation summary, exact validation commands, evidence paths, and remaining risks. | ✅ | 2026-06-10 |
| TASK-025 | After validation, set this plan status to `Completed` and mark completed tasks with date `2026-06-10`. | ✅ | 2026-06-10 |

## 3. Alternatives

- **ALT-001**: Keep Compose profiled one-shot runner services. Rejected because the requested follow-up explicitly moves Jenkins execution to Docker Pipeline and keeps Compose limited to regular services.
- **ALT-002**: Add Jenkins Docker Cloud agents. Rejected because the project only needs Docker Pipeline containers and the user explicitly excluded Docker Cloud agents.
- **ALT-003**: Install Playwright, Node, Gatling, and browser dependencies directly in the Jenkins image. Rejected because it weakens reproducibility and duplicates what the official Playwright and Gatling containers already provide.
- **ALT-004**: Use Docker Pipeline for Tomcat deployment. Rejected because the project already has a simpler shared-volume deployment path and the follow-up explicitly preserves it.

## 4. Dependencies

- **DEP-001**: Docker Engine must be running on the host and reachable through `/var/run/docker.sock` from Jenkins.
- **DEP-002**: Jenkins plugin `docker-workflow` must be installed and loaded for `docker.image(...).inside(...)`.
- **DEP-003**: Jenkins plugins `htmlpublisher` and `gatling` must remain installed for reporting support.
- **DEP-004**: Playwright image `mcr.microsoft.com/playwright:v1.60.0-noble` must be pullable or cached locally.
- **DEP-005**: Gatling image `denvazh/gatling:3.2.1` must be pullable or cached locally.
- **DEP-006**: Compose network `meta` must exist before Docker Pipeline smoke/test containers run.
- **DEP-007**: Jenkins container name must remain `meta-jenkins` because Docker Pipeline args use `--volumes-from meta-jenkins`.

## 5. Files

- **FILE-001**: `docs/plans/05-jenkins-container-ci-cd.md` is rewritten for this follow-up and updated at closeout.
- **FILE-002**: `docker-compose.yml` removes profiled runner services and keeps `tomcat` plus `jenkins`.
- **FILE-003**: `Jenkinsfile` moves Playwright, Gatling, and PDF export to Docker Pipeline containers.
- **FILE-004**: `scripts/run-playwright-container` becomes a direct Docker local runner plus Docker Pipeline command body.
- **FILE-005**: `scripts/run-gatling-container` becomes a direct Docker local runner plus Docker Pipeline command body.
- **FILE-006**: `scripts/export-gatling-pdfs` becomes a direct Docker local runner plus Docker Pipeline command body.
- **FILE-007**: `scripts/capture-har` becomes a direct Docker local runner plus Docker Pipeline-compatible command body.
- **FILE-008**: `docs/jenkins.md`, `docs/playwright.md`, `docs/gatling.md`, `docs/har-scenario.md`, `docs/plans/06-playwright-container-functional-test.md`, `docs/plans/07-har-capture.md`, and `docs/plans/08-gatling-container-tests.md` are updated where they describe the removed runner services.
- **FILE-009**: `docs/changelog/05-jenkins-container-ci-cd.changelog.md` records the follow-up implementation and validation evidence.

## 6. Testing

- **TEST-001**: `docker compose config --quiet` must pass.
- **TEST-002**: `sh -n scripts/run-playwright-container` must pass.
- **TEST-003**: `sh -n scripts/run-gatling-container` must pass.
- **TEST-004**: `sh -n scripts/run-gatling-load-5m` must pass.
- **TEST-005**: `sh -n scripts/run-gatling-stress-5m` must pass.
- **TEST-006**: `sh -n scripts/export-gatling-pdfs` must pass.
- **TEST-007**: `sh -n scripts/capture-har` must pass.
- **TEST-008**: `docker compose build jenkins` must pass or any Docker/network blocker must be recorded exactly.
- **TEST-009**: `docker compose up -d tomcat jenkins` must pass or any Docker/runtime blocker must be recorded exactly.
- **TEST-010**: `docker compose exec -T jenkins docker --version` must pass.
- **TEST-011**: `docker compose exec -T jenkins docker compose version` must pass.
- **TEST-012**: Plugin-file checks for `docker-workflow`, `htmlpublisher`, and `gatling` inside `/var/jenkins_home/plugins` must pass.
- **TEST-013**: A Jenkins Docker Pipeline smoke run using the Playwright image must prove the container runs from `env.WORKSPACE`, sees the same Git commit captured by `checkout scm`, and reaches `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **TEST-014**: Jenkins Pipeline validation must prove Playwright, Gatling load, and Gatling stress execute through Docker Pipeline; if the SCM-backed job cannot run uncommitted local edits, validate the Jenkinsfile with the declarative linter and record the limitation.
- **TEST-015**: `git diff --check` must pass.
- **TEST-016**: A stale-reference scan of changed docs and scripts must find no current references to removed Jenkins runner service names or profiled Compose one-shot commands.
- **TEST-017**: `git status --short --branch` must show no tracked generated secrets, Docker volume state, `target/`, or `.war` files.
- **TEST-018**: The local compliance validator against `rules/compliance.md` must pass with no failures.

## 7. Risks & Assumptions

- **RISK-001**: Docker Pipeline containers depend on host Docker socket access from the Jenkins container; this is acceptable for this coursework stack but not a production-hardening pattern.
- **RISK-002**: Docker image pulls or Jenkins image rebuilds may require network access; if unavailable, use cached images or record the exact blocker.
- **RISK-003**: The Jenkins SCM-backed job fetches committed GitHub content, so validating uncommitted Jenkinsfile edits may require declarative linter or a temporary local job before commit.
- **RISK-004**: `--volumes-from meta-jenkins` depends on the Jenkins container name staying stable.
- **RISK-005**: Removing Compose runner services requires documentation cleanup across earlier plan follow-ups so future commands do not point at removed services.
- **ASSUMPTION-001**: Current closeout branch is `feature/05-jenkins-container-ci-cd` before merge; after merge, `main` contains the committed change.
- **ASSUMPTION-002**: `meta-jenkins` and `meta-tomcat` are the active container names from `docker-compose.yml`.
- **ASSUMPTION-003**: Jenkins Docker Pipeline can start containers on network `meta` and those containers can resolve `tomcat`.

## 8. Related Specifications / Further Reading

- [Project contribution workflow](../../contribution.md)
- [Project compliance rules](../../rules/compliance.md)
- [Tomcat container deployment plan](./04-tomcat-container-deployment.md)
- [Playwright container functional test plan](./06-playwright-container-functional-test.md)
- [HAR capture plan](./07-har-capture.md)
- [Gatling container tests plan](./08-gatling-container-tests.md)
- [Monitoring and Jenkins schedule plan](./09-monitoring-and-jenkins-schedule.md)
- [Jenkins documentation: Using a Jenkinsfile](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/)
- [Jenkins documentation: Docker Pipeline](https://www.jenkins.io/doc/book/pipeline/docker/)

## 9. Follow-Up Notes

- 2026-06-10: Replaced the Docker Pipeline preflight `node -e` HTTP probe with a single-quoted heredoc. Jenkins had executed `require(http)` and `.on(error)` after Groovy and shell quote handling removed the JavaScript string quotes, causing `TypeError [ERR_INVALID_ARG_TYPE]` before the Tomcat reachability check could run.
- 2026-06-10: Superseded the trigger-aware availability design after instructor confirmation. Plan 09 separates monitoring into Jenkins Freestyle job `meta-monitoring` with shell command `./scripts/run-monitoring-check`. Plan 05 now keeps `meta-container-ci-cd` as the CI/CD build/deploy/test job only.
- 2026-06-11: Collapsed the old visible `Checkout` and `Prepare Evidence Workspace` stages into the beginning of `Build WAR`. The CI/CD graph then started with the assignment-facing build stage while still running explicit `checkout scm`, recording `CHECKED_OUT_COMMIT`, and cleaning old generated evidence before Maven built the WAR.
- 2026-06-11: Restored an explicit visible `Pre-build` stage after clarifying that pre-build and post-build should remain distinct Jenkins-managed blocks. `Pre-build` owns SCM checkout, `CHECKED_OUT_COMMIT`, and old evidence cleanup. Post-build remains the Declarative `post { always { ... } }` block so report generation and artifact publication still run after failures.
- 2026-06-11: Moved Docker CLI, Compose CLI, and Docker daemon readiness checks into `Pre-build`, then renamed `Docker Pipeline Preflight` to `Container Test Preflight`. The remaining container preflight stays after `Deploy Tomcat` and `Verify Tomcat` because it validates the disposable test container against the WAR deployed by the current pipeline run.
- 2026-06-11: Renamed `Pre-build` to `Pre Actions`, removed the standalone `Container Test Preflight` stage, and moved runner-specific validations into the stages that own those containers. Playwright now validates workspace mapping, checked-out commit identity, and Tomcat reachability inside `Playwright Functional Test`; Gatling stages validate their own workspace and runner script before running.
