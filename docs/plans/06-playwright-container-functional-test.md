---
goal: Containerized Playwright functional test for the JSP app
version: 1.0
date_created: 2026-06-10
last_updated: 2026-06-10
owner: Yonatan
status: 'Completed'
tags:
  - devops
  - playwright
  - browser-automation
  - jenkins
  - evidence
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

This plan implements the browser automation deliverable required by `final-project.pdf` using the approved Playwright override documented in `rules/compliance.md`. The result must provide a source-controlled Playwright functional test with exactly five assignment-facing validations, a repeatable local container runner, a Jenkins-triggered execution path, and ignored evidence under `output/playwright/`.

Follow-up update on 2026-06-10: Jenkins now starts the official Playwright container through Docker socket access instead of running Node, npm, and Chromium directly inside the Jenkins image. This is an enhancement to this plan, not a separate deliverable.

Follow-up update on 2026-06-10: Jenkins now publishes Playwright JUnit and HTML evidence through Jenkins report plugins when the generated files exist. Playwright execution remains containerized.

Follow-up update on 2026-06-10: `scripts/run-playwright-container` now uses direct `docker run` for local execution and `PLAYWRIGHT_DOCKER_PIPELINE=1` as the command body inside Jenkins Docker Pipeline. The Playwright functional test remains isolated from HAR capture; those validations use separate disposable containers.

Follow-up update on 2026-06-11: Jenkins now publishes a static Playwright evidence report from `output/playwright/jenkins-report/index.html` instead of publishing the native Playwright HTML app directly. The native report remains archived under `output/playwright/playwright-report/index.html`, but it is not linked from the Jenkins-safe report because Jenkins HTML Publisher can render it as a blank page when JavaScript is blocked.

Follow-up update on 2026-06-11: The Playwright functional test now uses both hard `expect(...)` assertions and verify-style `expect.soft(...)` assertions. Hard assertions guard flow prerequisites and final outcomes; soft assertions report independent validation failures without stopping the rest of the five-validation flow immediately.

Follow-up update on 2026-06-13: The Playwright functional test and Jenkins-safe evidence report now keep the JSP app's own flow while explaining the Lecture 8 assert/verify rationale for each validation.

## 1. Requirements & Constraints

- **REQ-001**: Implement browser automation for the JSP app served at `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` from the host and `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` from Docker network `meta`.
- **REQ-002**: Use Playwright as the accepted project substitute for the PDF's Selenium IDE requirement; do not create or rely on a Selenium `.side` file in this plan.
- **REQ-003**: Add exactly five documented validation steps in `tests/playwright/meta-functional.spec.js`: page shell visibility, link navigation to the about section, text input entry, valid submit success message, and empty submit validation message.
- **REQ-004**: Use selectors already present in `src/main/webapp/index.jsp`: `#pageTitle`, `#aboutLink`, `#nameInput`, `#submitButton`, `#resultMessage`, `#validationMessage`, and `#about`.
- **REQ-005**: Keep the application base URL configurable through environment variable `APP_BASE_URL`; default Playwright runner execution to `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` because both local and Jenkins runs execute inside Docker network `meta`.
- **REQ-006**: Save generated Playwright evidence under `output/playwright/`, including a passed-run log, an HTML report, JUnit XML, and at least two deterministic screenshots from the functional flow.
- **REQ-007**: Keep generated evidence ignored by Git according to `.gitignore`; commit only source files, scripts, documentation, and plan/changelog files.
- **REQ-008**: Preserve the existing `Jenkinsfile` stage named `Playwright Functional Test`; make that stage pass by adding `scripts/run-playwright-container`.
- **REQ-009**: Ensure Jenkins-triggered browser automation runs inside Docker by having Jenkins start the official Playwright container through Docker Pipeline.
- **REQ-010**: Keep local developer execution in the official Playwright container image `mcr.microsoft.com/playwright:v1.60.0-noble` unless `PLAYWRIGHT_IMAGE` overrides it.
- **REQ-011**: Publish `output/playwright/junit.xml` through Jenkins JUnit reporting and publish Jenkins-safe static HTML at `output/playwright/jenkins-report/index.html` through HTML Publisher when those files exist. Keep the native Playwright report archived at `output/playwright/playwright-report/index.html`.
- **REQ-012**: Keep the Playwright test explanation aligned with Lecture 8 Selenium IDE rationale: use fail-fast `expect(...)` for critical gates and final outcomes, and use verify-style `expect.soft(...)` for independent evidence that should be collected without stopping immediately.
- **SEC-001**: Do not commit Jenkins credentials, API tokens, browser cookies, HAR content, private keys, `.env`, or generated traces containing sensitive values.
- **SEC-002**: Mount `/var/run/docker.sock` into Jenkins for this coursework stack only so Jenkins can run disposable test containers. Do not use Docker socket access to deploy Tomcat artifacts.
- **CON-001**: Read and obey `contribution.md` before implementation; keep this work on branch `feature/06-playwright-container-functional-test`.
- **CON-002**: Keep the Tomcat context path aligned with the canonical group-member slug used by Maven and deployment.
- **CON-003**: Do not modify Gatling, HAR, monitoring, public-IP bonus, or submission-package implementation in this plan except for links or references needed by Plan 06.
- **CON-004**: Do not install Playwright, Node packages, or browsers on the host machine. Use Dockerized execution only.
- **CON-005**: Use `npm` only inside Docker images for Playwright package installation because the official Playwright container does not include `bun` by default.
- **GUD-001**: Prefer stable IDs and accessible role/text assertions over brittle CSS or visual-only assertions, while still using the existing assignment selectors where required.
- **GUD-002**: Keep screenshots deterministic by capturing after the valid submit state and after the empty submit validation state.
- **PAT-001**: Follow the existing script pattern from `scripts/deploy-war`: executable from the project root, explicit environment variables, deterministic defaults, and clear failure messages.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Add source-controlled Playwright project files and the five-validation functional test.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Create `package.json` with `private: true`, script `"test:playwright": "playwright test"`, and dev dependency `"@playwright/test": "1.60.0"`. | ✅ | 2026-06-10 |
| TASK-002 | Create `package-lock.json` by running package resolution inside Docker, not on the host: `docker run --rm -v "$PWD:/work" -w /work node:22-bookworm npm install --package-lock-only`. | ✅ | 2026-06-10 |
| TASK-003 | Create `playwright.config.js` with `testDir: './tests/playwright'`, `timeout: 30000`, one Chromium project, `baseURL: process.env.APP_BASE_URL || 'http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/'`, `outputDir: 'output/playwright/test-results'`, reporter list `[['list'], ['html', { outputFolder: 'output/playwright/playwright-report', open: 'never' }], ['junit', { outputFile: 'output/playwright/junit.xml' }]]`, `trace: 'retain-on-failure'`, `screenshot: 'only-on-failure'`, `video: 'off'`, and optional `PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH` launch option handling. | ✅ | 2026-06-10 |
| TASK-004 | Create directory `tests/playwright/` and file `tests/playwright/meta-functional.spec.js`. | ✅ | 2026-06-10 |
| TASK-005 | In `tests/playwright/meta-functional.spec.js`, add one test named `JSP app supports the required functional flow` with five `test.step` blocks. | ✅ | 2026-06-10 |
| TASK-006 | In step 1 of `tests/playwright/meta-functional.spec.js`, load the configured app root with `page.goto('./')`, assert `#pageTitle` has exact text `MeTA`, soft-verify the supporting page copy, assert `#submitButton` is visible, and assert `#nameInput` is visible. | ✅ | 2026-06-10 |
| TASK-007 | In step 2 of `tests/playwright/meta-functional.spec.js`, click `#aboutLink`, soft-verify the URL contains `#about`, and soft-verify locator `#about` contains heading text `About`. | ✅ | 2026-06-10 |
| TASK-008 | In step 3 of `tests/playwright/meta-functional.spec.js`, reload the app root, fill `#nameInput` with `Yonatan`, then assert `#nameInput` has value `Yonatan`. | ✅ | 2026-06-10 |
| TASK-009 | In step 4 of `tests/playwright/meta-functional.spec.js`, click `#submitButton`, assert `#resultMessage` has exact text `Hello, Yonatan. MeTA Corporate reviewed your form, opened a committee, and somehow approved it.`, and write screenshot `output/playwright/screenshots/valid-submit.png`. | ✅ | 2026-06-10 |
| TASK-010 | In step 5 of `tests/playwright/meta-functional.spec.js`, reload the configured app root with `page.goto('./')`, click `#submitButton` with an empty input, assert `#validationMessage` has exact text `Please enter a name before MeTA Corporate schedules a meeting about the empty box.`, and write screenshot `output/playwright/screenshots/empty-submit.png`. | ✅ | 2026-06-10 |

### Implementation Phase 2

- GOAL-002: Add repeatable Dockerized execution for local and Jenkins contexts.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-011 | Create executable script `scripts/run-playwright-container` with shebang `#!/usr/bin/env sh` and `set -eu`. | ✅ | 2026-06-10 |
| TASK-012 | In `scripts/run-playwright-container`, define `PROJECT_ROOT`, `PLAYWRIGHT_IMAGE="${PLAYWRIGHT_IMAGE:-mcr.microsoft.com/playwright:v1.60.0-noble}"`, `PLAYWRIGHT_NETWORK="${PLAYWRIGHT_NETWORK:-meta}"`, `HOST_APP_BASE_URL="${APP_BASE_URL:-http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/}"`, `JENKINS_CONTAINER="${JENKINS_CONTAINER:-meta-jenkins}"`, `PLAYWRIGHT_CONTAINER_NAME="${PLAYWRIGHT_CONTAINER_NAME:-meta-playwright-${BUILD_NUMBER:-local}}"`, `OUTPUT_DIR="output/playwright"`, and `LOG_FILE="$OUTPUT_DIR/playwright-run.log"`. | ✅ | 2026-06-10 |
| TASK-013 | In `scripts/run-playwright-container`, create `output/playwright/`, `output/playwright/screenshots/`, `output/playwright/test-results/`, and `output/playwright/playwright-report/` before running tests. | ✅ | 2026-06-10 |
| TASK-014 | In `scripts/run-playwright-container`, when `PLAYWRIGHT_DOCKER_PIPELINE=1`, export `APP_BASE_URL` and `CI=true`, then run `/bin/bash -lc 'npm ci && npx playwright test'`; capture all output to `output/playwright/playwright-run.log` while preserving the test exit code. | ✅ | 2026-06-10 |
| TASK-015 | In `scripts/run-playwright-container`, when not inside Jenkins, require Docker and run `docker run --rm --name "$PLAYWRIGHT_CONTAINER_NAME" --network "$PLAYWRIGHT_NETWORK" -v "$PROJECT_ROOT:/work" -w /work -e APP_BASE_URL="$HOST_APP_BASE_URL" -e CI=true "$PLAYWRIGHT_IMAGE" /bin/bash -lc 'npm ci && npx playwright test'`; capture all output to `output/playwright/playwright-run.log` while preserving the test exit code. | ✅ | 2026-06-10 |
| TASK-016 | In `scripts/run-playwright-container`, print the final evidence paths after a successful run: `output/playwright/playwright-run.log`, `output/playwright/junit.xml`, `output/playwright/playwright-report/index.html`, `output/playwright/screenshots/valid-submit.png`, and `output/playwright/screenshots/empty-submit.png`. | ✅ | 2026-06-10 |
| TASK-017 | Mark `scripts/run-playwright-container` executable with `chmod +x scripts/run-playwright-container`. | ✅ | 2026-06-10 |
| TASK-018 | Update `ops/jenkins/Dockerfile` so Jenkins includes Docker CLI support in addition to `ca-certificates`, `curl`, and `maven`; do not install Jenkins-image `chromium`, `nodejs`, or `npm`. The 2026-06-10 Jenkins tooling follow-up moves this from Debian `docker-cli` to Docker's official `docker-ce-cli` plus `docker-compose-plugin`. | ✅ | 2026-06-10 |
| TASK-019 | Add a Docker socket mount to `docker-compose.yml` so Jenkins can start the official Playwright container. | ✅ | 2026-06-10 |

### Implementation Phase 3

- GOAL-003: Document the Playwright evidence and keep Jenkins documentation accurate.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-020 | Create `docs/playwright.md` with sections `Runtime`, `Functional Validations`, `Local Execution`, `Jenkins Execution`, `Evidence Files`, and `Known Assignment Override`. | ✅ | 2026-06-10 |
| TASK-021 | In `docs/playwright.md` section `Runtime`, document local default `APP_BASE_URL=http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` for the Playwright container and Jenkins default `APP_BASE_URL=http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` inside the Docker network. | ✅ | 2026-06-10 |
| TASK-022 | In `docs/playwright.md` section `Functional Validations`, list the exact five validation names and the assertion target for each validation. | ✅ | 2026-06-10 |
| TASK-023 | In `docs/playwright.md` section `Evidence Files`, list `output/playwright/playwright-run.log`, `output/playwright/junit.xml`, `output/playwright/playwright-report/index.html`, `output/playwright/screenshots/valid-submit.png`, and `output/playwright/screenshots/empty-submit.png`. | ✅ | 2026-06-10 |
| TASK-024 | In `docs/playwright.md` section `Known Assignment Override`, state that `final-project.pdf` names Selenium IDE `.side`, but this project uses Playwright under the accepted override in `rules/compliance.md`. | ✅ | 2026-06-10 |
| TASK-025 | Update `docs/jenkins.md` section `Pipeline Stages` item `Playwright Functional Test` so it states that `./scripts/run-playwright-container` now runs the Playwright functional test and writes ignored evidence under `output/playwright/`. | ✅ | 2026-06-10 |
| TASK-026 | Update `docs/jenkins.md` section `Security Notes` so it states Jenkins mounts the Docker socket for disposable test containers and Playwright runs in the official Playwright image. | ✅ | 2026-06-10 |
| TASK-027 | Update `docs/jenkins.md` section `Evidence To Capture` to include the Plan 06 Playwright run log, JUnit XML, HTML report, and two screenshots. | ✅ | 2026-06-10 |
| TASK-027A | Update Jenkins post-build behavior so `output/playwright/junit.xml` is published with Jenkins JUnit and Playwright HTML evidence is available from archived artifacts. | ✅ | 2026-06-10 |

### Implementation Phase 4

- GOAL-004: Validate local execution, Jenkins execution, evidence generation, and compliance.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-028 | Run `sh -n scripts/run-playwright-container` and fix any shell syntax errors before running Docker commands. | ✅ | 2026-06-10 |
| TASK-029 | Run `docker compose build jenkins` and verify the Jenkins image builds with Docker CLI support, `maven`, and `curl`, without direct Jenkins-image `nodejs`, `npm`, or `chromium`. | ✅ | 2026-06-10 |
| TASK-030 | Run `docker compose up -d tomcat jenkins` and verify both services are up with `docker compose ps`. | ✅ | 2026-06-10 |
| TASK-031 | Run `./scripts/deploy-war` and verify it prints `Deployed URL: http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`. | ✅ | 2026-06-10 |
| TASK-032 | Run local containerized Playwright with `./scripts/run-playwright-container`; verify the command exits `0`. | ✅ | 2026-06-10 |
| TASK-033 | Run Jenkins-container execution with `docker compose exec -T jenkins sh -lc 'cd /workspace/final-project && APP_BASE_URL=http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ ./scripts/run-playwright-container'`; verify the command exits `0`. | ✅ | 2026-06-10 |
| TASK-034 | Verify evidence files exist with `test -s output/playwright/playwright-run.log`, `test -s output/playwright/junit.xml`, `test -s output/playwright/playwright-report/index.html`, `test -s output/playwright/screenshots/valid-submit.png`, and `test -s output/playwright/screenshots/empty-submit.png`. | ✅ | 2026-06-10 |
| TASK-035 | Run `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md` and manually inspect all `manual` items before marking the plan complete. | ✅ | 2026-06-10 |
| TASK-036 | Create `docs/changelog/06-playwright-container-functional-test.changelog.md` with what changed, why it changed, exact validation commands, generated evidence paths, and remaining risks. | ✅ | 2026-06-10 |
| TASK-037 | Update this plan's front matter status to `Completed`, update the badge color to `brightgreen`, and mark completed tasks with date `2026-06-10` only after TASK-028 through TASK-036 pass. | ✅ | 2026-06-10 |

### Implementation Phase 5

- GOAL-005: Convert Jenkins Playwright execution from nested Docker launch to Jenkins Docker Pipeline while keeping the public script command.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-038 | Remove the Playwright Compose runner service model from `docker-compose.yml`. | ✅ | 2026-06-10 |
| TASK-039 | Update Jenkins stage `Playwright Functional Test` to start `mcr.microsoft.com/playwright:v1.60.0-noble` with `docker.image(env.PLAYWRIGHT_IMAGE).inside(...)`. | ✅ | 2026-06-10 |
| TASK-040 | Update `scripts/run-playwright-container` to use direct local `docker run` and `PLAYWRIGHT_DOCKER_PIPELINE=1` for Jenkins Docker Pipeline execution while preserving evidence paths. | ✅ | 2026-06-10 |

### Implementation Phase 6

- GOAL-006: Replace the Jenkins-published Playwright SPA with a static Jenkins-safe evidence report.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-041 | Document that Playwright functional validation and HAR capture use separate fresh one-shot containers. | ✅ | 2026-06-10 |
| TASK-042 | Add a regression test for the static Jenkins-safe Playwright report. | ✅ | 2026-06-11 |
| TASK-043 | Add `scripts/generate-playwright-jenkins-report` to summarize JUnit results and link Jenkins-safe evidence without inline JavaScript. | ✅ | 2026-06-11 |
| TASK-044 | Update `scripts/run-playwright-container` to generate the static report after a successful Playwright run. | ✅ | 2026-06-11 |
| TASK-045 | Update Jenkins post-build publishing to publish `output/playwright/jenkins-report/index.html` as `Playwright Report`. | ✅ | 2026-06-11 |

### Implementation Phase 7

- GOAL-007: Align Playwright evidence wording and validation order with Lecture 7 and Lecture 8 course material.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-046 | Review `classes/DevOps_Lecture7_Automation_dev.pdf` and `classes/DevOps_Lecture8_seleniumIDE_loginTest_MTA.pdf` before changing Playwright evidence. | ✅ | 2026-06-13 |
| TASK-047 | Rename and reorder the five Playwright steps to keep the app-specific flow while explaining the class assert/verify rationale. | ✅ | 2026-06-13 |
| TASK-048 | Add a course rationale map to the Jenkins-safe Playwright evidence report. | ✅ | 2026-06-13 |
| TASK-049 | Update `docs/playwright.md` so the defense explanation prioritizes the instructor's Selenium IDE terminology over generic Playwright best practices. | ✅ | 2026-06-13 |

## 3. Alternatives

- **ALT-001**: Use Selenium IDE and commit a `.side` file. Rejected because `rules/compliance.md` records the accepted project override to use Playwright, while preserving the PDF mismatch as a grading risk.
- **ALT-002**: Run Playwright directly on the host. Rejected because `rules/compliance.md` requires Dockerized, repeatable browser automation and the project must not install browser tooling on the host.
- **ALT-003**: Run Playwright directly inside Jenkins with Jenkins-installed Node, npm, and Chromium. Rejected by the 2026-06-10 follow-up because the user prioritized one official-container execution model for local and Jenkins runs.
- **ALT-004**: Add Playwright runner services to `docker-compose.yml`. Rejected because Compose should contain only regular services `tomcat` and `jenkins`; validation stages use disposable `docker run` or Jenkins Docker Pipeline containers instead.
- **ALT-005**: Use screenshots only without Playwright assertions. Rejected because the assignment requires functional browser automation with validations, not manual visual evidence.

## 4. Dependencies

- **DEP-001**: `final-project.pdf` remains the authoritative assignment source; `rules/compliance.md` is the active operational checklist derived from it.
- **DEP-002**: Docker Compose project `meta` must provide network `meta` and Tomcat service DNS name `tomcat`.
- **DEP-003**: `scripts/deploy-war` must deploy `target/yonatan-csasznik-yoed-halberstam-niv-levin.war` to the Tomcat container before Playwright tests run.
- **DEP-004**: `Jenkinsfile` must retain stage `Playwright Functional Test` that calls `./scripts/run-playwright-container` for non-timer builds.
- **DEP-005**: Jenkins image `meta-jenkins:2.528.1-lts-jdk21` must include Docker CLI support, Docker Compose, `maven`, and `curl` after the Jenkins tooling follow-up.
- **DEP-006**: Local Playwright container execution depends on Docker being able to pull `mcr.microsoft.com/playwright:v1.60.0-noble`.
- **DEP-007**: Browser selectors in `src/main/webapp/index.jsp` must remain stable: `#pageTitle`, `#aboutLink`, `#nameInput`, `#submitButton`, `#resultMessage`, `#validationMessage`, and `#about`.

## 5. Files

- **FILE-001**: `docs/plans/06-playwright-container-functional-test.md` - this executable implementation plan.
- **FILE-002**: `package.json` - Playwright package metadata and test script.
- **FILE-003**: `package-lock.json` - deterministic npm dependency lock for Dockerized Playwright execution.
- **FILE-004**: `playwright.config.js` - Playwright test configuration, reports, screenshots, base URL handling, and optional Jenkins Chromium executable path handling.
- **FILE-005**: `tests/playwright/meta-functional.spec.js` - five-validation functional browser test.
- **FILE-006**: `scripts/run-playwright-container` - local official-container runner and Jenkins Docker Pipeline command body.
- **FILE-007**: `ops/jenkins/Dockerfile` - Jenkins image dependencies for Docker Pipeline orchestration, Maven build, and Tomcat deployment.
- **FILE-008**: `docs/playwright.md` - Playwright runtime, validation, evidence, and override documentation.
- **FILE-009**: `docs/jenkins.md` - Jenkins stage, evidence, and security documentation updates.
- **FILE-010**: `docs/changelog/06-playwright-container-functional-test.changelog.md` - completion record created after validation.
- **FILE-011**: `output/playwright/playwright-run.log` - generated ignored passed-run evidence.
- **FILE-012**: `output/playwright/junit.xml` - generated ignored JUnit result evidence.
- **FILE-013**: `output/playwright/playwright-report/index.html` - generated ignored HTML report.
- **FILE-014**: `output/playwright/jenkins-report/index.html` - generated ignored Jenkins-safe static Playwright report.
- **FILE-015**: `scripts/generate-playwright-jenkins-report` - static Playwright report generator.
- **FILE-016**: `tests/scripts/test-generate-playwright-jenkins-report.sh` - regression test for the static report.
- **FILE-017**: `output/playwright/screenshots/valid-submit.png` - generated ignored valid-submit screenshot.
- **FILE-018**: `output/playwright/screenshots/empty-submit.png` - generated ignored empty-submit screenshot.

## 6. Testing

- **TEST-001**: `sh -n scripts/run-playwright-container` must pass.
- **TEST-002**: `docker compose build jenkins` must pass.
- **TEST-003**: `docker compose up -d tomcat jenkins` must start both services.
- **TEST-004**: `./scripts/deploy-war` must deploy the app and print `Deployed URL: http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **TEST-005**: `./scripts/run-playwright-container` must pass from the host and generate `output/playwright/playwright-run.log`.
- **TEST-006**: `docker compose exec -T jenkins sh -lc 'cd /workspace/final-project && APP_BASE_URL=http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ ./scripts/run-playwright-container'` must pass from inside Jenkins.
- **TEST-007**: `test -s output/playwright/junit.xml` must pass.
- **TEST-008**: `test -s output/playwright/playwright-report/index.html` must pass.
- **TEST-008A**: `sh tests/scripts/test-generate-playwright-jenkins-report.sh` must pass.
- **TEST-008B**: `test -s output/playwright/jenkins-report/index.html` must pass after report generation.
- **TEST-009**: `test -s output/playwright/screenshots/valid-submit.png` must pass.
- **TEST-010**: `test -s output/playwright/screenshots/empty-submit.png` must pass.
- **TEST-011**: `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md` must report no unreviewed failures before completion.
- **TEST-012**: `git diff --check` must pass before commit.
- **TEST-013**: A Jenkins non-timer build with Playwright evidence must publish the JUnit result and Playwright HTML report without replacing the raw archived `output/playwright/` artifacts.
- **TEST-014**: `npx playwright test` or `./scripts/run-playwright-container` must show the same five validation steps while preserving the hard-assert versus soft-verify reasoning documented in `docs/playwright.md`.

## 7. Risks & Assumptions

- **RISK-001**: The PDF names Selenium IDE `.side`; Playwright is an accepted project override but remains a grading risk if the lecturer requires Selenium IDE specifically.
- **RISK-002**: Mounting `/var/run/docker.sock` gives Jenkins broad Docker host control; this is accepted for local coursework simplicity and must not be described as production-secure.
- **RISK-003**: Docker image pull for `mcr.microsoft.com/playwright:v1.60.0-noble` can fail if the machine is offline or the registry is unavailable; rerun when network access is available and document the blocker if it persists.
- **RISK-004**: The Playwright test depends on stable JSP IDs; changing IDs in `src/main/webapp/index.jsp` requires updating the test and `docs/playwright.md`.
- **RISK-005**: Browser screenshots under `output/playwright/` are useful evidence but do not replace the final manual Tomcat screenshot with the address bar visible.
- **ASSUMPTION-001**: The Tomcat app remains deployed at context path `/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **ASSUMPTION-002**: Docker Compose project name remains `meta`, preserving Docker network name `meta`.
- **ASSUMPTION-003**: Jenkins non-timer builds continue to run the `Playwright Functional Test` stage after `scripts/run-playwright-container` exists.
- **ASSUMPTION-004**: Generated evidence remains ignored by `.gitignore` and is attached manually or archived by Jenkins rather than committed.

## 8. Related Specifications / Further Reading

- [Final project compliance rules](../../rules/compliance.md)
- [Contribution workflow](../../contribution.md)
- [Jenkins container CI/CD documentation](../jenkins.md)
- [Tomcat container deployment plan](./04-tomcat-container-deployment.md)
- [Jenkins container CI/CD plan](./05-jenkins-container-ci-cd.md)
