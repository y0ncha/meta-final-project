---
goal: Jenkins Container CI/CD Pipeline for the Meta WAR
version: 1.0
date_created: 2026-06-10
last_updated: 2026-06-10
owner: Project team
status: "Completed"
tags:
  - infrastructure
  - ci-cd
  - jenkins
  - docker
  - deployment
  - devops-final-project
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

This plan implements the containerized Jenkins CI/CD path for the MTA DevOps final project. Jenkins must run at `http://localhost:8081/`, check out the GitHub repository, build `target/meta.war`, deploy it into Tomcat through the shared Docker volume mounted at `/tomcat-webapps`, verify `http://tomcat:8080/meta/` from inside Docker, and provide a source-controlled `Jenkinsfile` that later Playwright, Gatling, and monitoring plans can extend without changing the runtime topology.

The 2026-06-10 Plan 06 follow-up supersedes this plan's original no-Docker-socket decision for browser-test execution only. Tomcat deployment through the shared `tomcat_webapps` volume remains unchanged.

The 2026-06-10 Jenkins tooling follow-up upgrades the custom Jenkins image to install Docker CLI and Docker Compose from Docker's official Debian apt repository and preinstall Jenkins plugins `docker-workflow`, `htmlpublisher`, and `gatling`. Jenkins still deploys Tomcat through `/tomcat-webapps`; Docker tooling is for diagnostics and disposable test-container orchestration.

## 1. Requirements & Constraints

- **REQ-001**: Jenkins must run as Docker Compose service `jenkins` and be exposed on host URL `http://localhost:8081/`.
- **REQ-002**: Tomcat must remain Docker Compose service `tomcat` and serve the application at host URL `http://localhost:8080/meta/`.
- **REQ-003**: Jenkins must deploy to Tomcat by running repository automation from the checked-out source tree, not by manual copy through the Jenkins UI.
- **REQ-004**: The pipeline definition must be a root-level source-controlled file named `Jenkinsfile`.
- **REQ-005**: `Jenkinsfile` must use Declarative Pipeline syntax with a top-level `pipeline { agent any ... }` structure.
- **REQ-006**: `Jenkinsfile` must include stages named exactly `Checkout`, `Build WAR`, `Deploy Tomcat`, `Verify Tomcat`, `Availability Check`, `Playwright Functional Test`, `Gatling Load Test`, and `Gatling Stress Test`.
- **REQ-007**: `Jenkinsfile` must archive `target/meta.war` with fingerprinting after the build stage succeeds.
- **REQ-008**: `Jenkinsfile` must run the availability check on a five-minute timer using Jenkins cron expression `H/5 * * * *`, without rebuilding or redeploying on timer-triggered runs.
- **REQ-008A**: `Jenkinsfile` must support SCM-change detection for the CI/CD path. For the local defense setup, use `pollSCM('H/2 * * * *')`; if Jenkins is exposed through a stable public URL, a GitHub webhook may trigger the same job instead.
- **REQ-009**: `Jenkinsfile` must prevent overlapping builds with `disableConcurrentBuilds()`.
- **REQ-010**: `Jenkinsfile` must enforce a bounded pipeline runtime with `timeout(time: 30, unit: 'MINUTES')`.
- **REQ-011**: `Jenkinsfile` must set `APP_BASE_URL` to `http://tomcat:8080/meta/` for Jenkins-container internal checks.
- **REQ-012**: `Jenkinsfile` must run `./scripts/deploy-war` with `DEPLOY_CHECK_URL=http://tomcat:8080/meta/`.
- **REQ-013**: `scripts/deploy-war` must keep its existing local default behavior for Plan 04 while accepting `DEPLOY_CHECK_URL` for Jenkins-container health checks.
- **REQ-014**: `scripts/deploy-war` must accept `SKIP_BUILD=1` so Jenkins can avoid building the same WAR twice after the `Build WAR` stage.
- **REQ-015**: Jenkins must have the command-line tools required by the pipeline: `mvn`, `curl`, `git`, and `sh`.
- **REQ-016**: The final Jenkins job must build from the SCM workspace checked out from `https://github.com/y0ncha/meta-final-project.git`; `/workspace/final-project` remains only the legacy local validation mount.
- **REQ-017**: `docker-compose.yml` must persist Jenkins state in Docker volume `jenkins_home`.
- **REQ-017A**: `docker-compose.yml` must mount Docker volume `tomcat_webapps` into Jenkins at `/tomcat-webapps` so Jenkins can deploy the WAR without controlling the host Docker daemon.
- **REQ-018**: Jenkins setup documentation must define the final Pipeline job name as `meta-container-ci-cd`.
- **REQ-019**: Jenkins setup documentation must define the Pipeline job script path as `Jenkinsfile`.
- **REQ-020**: Jenkins setup documentation must record manual UI steps needed to unlock Jenkins, create the admin user, install plugins, create the Pipeline job, and configure `Pipeline script from SCM` against `https://github.com/y0ncha/meta-final-project.git`.
- **REQ-021**: Jenkins evidence must include a successful manual or SCM-triggered CI/CD build log and a successful scheduled availability build log or screenshot.
- **REQ-022**: Later plans must be able to activate Playwright and Gatling stages by adding the scripts those stages check for; Plan 05 must not hard-fail while those later plan files do not exist.
- **REQ-023**: Non-timer CI/CD builds must fail if `Deploy Tomcat` or `Verify Tomcat` cannot reach `http://tomcat:8080/meta/`; timer-triggered availability builds must fail if `Availability Check` cannot reach the same target.
- **REQ-024**: The custom Jenkins image must provide `docker` and `docker compose` inside the Jenkins container.
- **REQ-025**: The custom Jenkins image must preinstall Jenkins plugins `docker-workflow`, `htmlpublisher`, and `gatling`.
- **REQ-026**: `Jenkinsfile` must publish Playwright JUnit/HTML reports and Gatling HTML/PDF reports when those files exist, while keeping raw `output/**/*` archival.
- **CON-001**: Read `contribution.md` and `rules/compliance.md` from the repository root before implementation and stop if any task conflicts with the compliance rules.
- **CON-002**: Create or switch to branch `feature/plan-05-jenkins-container-ci-cd` before mutating tracked files for this plan.
- **CON-003**: Do not use host Jenkins, `/Users/yonatan/.jenkins`, host Tomcat, `/usr/local/tomcat8`, host Catalina scripts, or non-containerized project runtime services.
- **CON-004**: Do not change the Maven coordinate `mta.devops:meta:1.0.0` or the Maven `<finalName>meta</finalName>` value.
- **CON-005**: Do not change the required public local URLs `http://localhost:8080/meta/` and `http://localhost:8081/` unless a real port conflict blocks execution and the conflict is documented.
- **CON-006**: Do not commit Jenkins home data, Docker volume state, generated `target/` output, generated `*.war` files, screenshots, logs, Playwright reports, Gatling reports, or secrets.
- **CON-007**: Do not install, upgrade, reinstall, or replace host tools while executing this plan.
- **SEC-001**: Do not write GitHub tokens, Jenkins admin passwords, API keys, cookies, private keys, or other secrets into `Jenkinsfile`, `docker-compose.yml`, `ops/jenkins/Dockerfile`, scripts, documentation, logs, or screenshots.
- **SEC-002**: Jenkins deployment must continue writing to the shared `tomcat_webapps` volume instead of using Docker control to deploy Tomcat artifacts. The later Plan 06 follow-up allows `/var/run/docker.sock` only so Jenkins can run disposable test containers such as Playwright.
- **SEC-003**: Use public GitHub repository checkout without credentials when the repository is public; if credentials are required, store them only in Jenkins credentials and reference only the credential ID in documentation.
- **GUD-001**: Prefer a source-controlled `Jenkinsfile` over UI-only freestyle commands because Jenkins documents it as the auditable, reviewable Pipeline source of truth.
- **GUD-002**: Use Declarative Pipeline stages and `sh` steps for this Linux-based Jenkins container runtime.
- **GUD-003**: Use Jenkins hashed schedules such as `H/5 * * * *` and `H/2 * * * *` instead of fixed-minute schedules so Jenkins can spread scheduling load.
- **GUD-004**: Prefer `docker compose` v2 commands over legacy `docker-compose` commands.
- **GUD-005**: Use `rtk read`, `rtk grep`, `rtk find`, `rtk diff`, and `rtk docker` for noisy reads, searches, diffs, and Docker output when they preserve required detail.
- **PAT-001**: Follow the repository pattern of tracked automation in `scripts/`, source plans in `docs/plans/`, implementation closeout in `docs/changelog/`, and generated evidence under ignored `output/`.
- **PAT-002**: Keep Jenkins pipeline behavior idempotent for CI/CD builds, and keep timer-triggered availability checks read-only so repeated scheduled executions do not rebuild or replace the deployed `meta` WAR.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Verify the execution context, branch, current runtime topology, and Jenkins convention source before editing files.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Run `rtk read contribution.md` and `rtk read rules/compliance.md` from the repository root and confirm Plan 05 uses containerized Jenkins on `http://localhost:8081/`, containerized Tomcat on `http://localhost:8080/meta/`, and no host Jenkins or host Tomcat runtime. | ✅ | 2026-06-10 |
| TASK-002 | Run `git status --short --branch` from the repository root. If unrelated uncommitted changes exist, stop and report the exact output before switching branches or editing files. | ✅ | 2026-06-10 |
| TASK-003 | Create or switch to branch `feature/plan-05-jenkins-container-ci-cd`. If branch creation is blocked by uncommitted work, stop and report the exact `git status --short --branch` output. | ✅ | 2026-06-10 |
| TASK-004 | Run `docker --version`, `docker compose version`, `mvn --version`, `java -version`, `git --version`, and `curl --version`; record exact observed versions in `docs/changelog/05-jenkins-container-ci-cd.changelog.md` during closeout. | ✅ | 2026-06-10 |
| TASK-005 | Run `rtk read docker-compose.yml` and confirm service `jenkins` uses host port `8081`, volume `jenkins_home`, repository bind mount target `/workspace/final-project`, and network `meta`. | ✅ | 2026-06-10 |
| TASK-006 | Run `rtk read scripts/deploy-war` and confirm the current script builds `target/meta.war`, starts service `tomcat`, copies the WAR to `/usr/local/tomcat/webapps/meta.war`, and defaults to checking `http://localhost:8080/meta/`. | ✅ | 2026-06-10 |
| TASK-007 | Validate Jenkins conventions against the Jenkins documentation links in Section 8 before writing `Jenkinsfile`; confirm the selected conventions are source-controlled Jenkinsfile, Declarative Pipeline, explicit stages, `agent any`, `sh` steps, artifact archiving, `post` behavior, and `H/5` scheduling. | ✅ | 2026-06-10 |

### Implementation Phase 2

- GOAL-002: Make the Jenkins container capable of running the Maven and HTTP commands required by the pipeline without host Docker daemon access.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-008 | Create directory `ops/jenkins/` if it does not exist. | ✅ | 2026-06-10 |
| TASK-009 | Create `ops/jenkins/Dockerfile` with `ARG JENKINS_BASE_IMAGE=jenkins/jenkins:2.528.1-lts-jdk21`, `FROM ${JENKINS_BASE_IMAGE}`, `USER root`, package installation for `ca-certificates`, `curl`, and `maven`, cleanup of `/var/lib/apt/lists/*`, and final `USER jenkins`. | ✅ | 2026-06-10 |
| TASK-010 | In `docker-compose.yml`, change service `jenkins` from direct image-only runtime to a custom build using `build.context: .`, `build.dockerfile: ops/jenkins/Dockerfile`, and build arg `JENKINS_BASE_IMAGE: ${JENKINS_IMAGE:-jenkins/jenkins:2.528.1-lts-jdk21}`. | ✅ | 2026-06-10 |
| TASK-011 | In `docker-compose.yml`, set service `jenkins` image to `${META_JENKINS_IMAGE:-meta-jenkins:2.528.1-lts-jdk21}` so the custom local image has a deterministic name. | ✅ | 2026-06-10 |
| TASK-012 | In `docker-compose.yml`, mount volume `tomcat_webapps` into service `jenkins` at `/tomcat-webapps` so Jenkins can replace `/tomcat-webapps/meta.war` directly. | ✅ | 2026-06-10 |
| TASK-013 | In `docker-compose.yml`, set `user: root` on service `jenkins` only if the default `jenkins` user cannot write to `/tomcat-webapps`; document the local-coursework tradeoff in `docs/jenkins.md`. | ✅ | 2026-06-10 |
| TASK-014 | Run `docker compose config` and confirm it exits with status `0` after the Compose edits. | ✅ | 2026-06-10 |
| TASK-015 | Run `docker compose build jenkins` and confirm the custom Jenkins image builds without host tool installation. | ✅ | 2026-06-10 |

### Implementation Phase 3

- GOAL-003: Adapt deployment automation and add the source-controlled Jenkins pipeline.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-016 | In `scripts/deploy-war`, add environment variable `SKIP_BUILD="${SKIP_BUILD:-0}"` after the existing variable definitions. | ✅ | 2026-06-10 |
| TASK-017 | In `scripts/deploy-war`, validate `SKIP_BUILD` so only `0` and `1` are accepted; on any other value, print `SKIP_BUILD must be 0 or 1` to stderr and exit with status `2`. | ✅ | 2026-06-10 |
| TASK-018 | In `scripts/deploy-war`, replace unconditional `mvn clean package` with a conditional block that runs `mvn clean package` only when `SKIP_BUILD` equals `0`. | ✅ | 2026-06-10 |
| TASK-019 | In `scripts/deploy-war`, add environment variable `DEPLOY_CHECK_URL="${DEPLOY_CHECK_URL:-http://localhost:$TOMCAT_HOST_PORT/$TOMCAT_CONTEXT/}"` after `TOMCAT_HOST_PORT` validation and before the polling loop. | ✅ | 2026-06-10 |
| TASK-020 | In `scripts/deploy-war`, change the polling loop to run `curl -fsS "$DEPLOY_CHECK_URL"` instead of constructing a local-only URL inside the loop. | ✅ | 2026-06-10 |
| TASK-021 | In `scripts/deploy-war`, keep default local output compatible with Plan 04 by printing `Deployed URL: $DEPLOY_CHECK_URL` after successful validation. | ✅ | 2026-06-10 |
| TASK-022 | Create root-level `Jenkinsfile` using Declarative Pipeline syntax with `agent any`, `options { timestamps(); disableConcurrentBuilds(); timeout(time: 30, unit: 'MINUTES'); buildDiscarder(logRotator(numToKeepStr: '20', artifactNumToKeepStr: '10')) }`, `triggers { cron('H/5 * * * *'); pollSCM('H/2 * * * *') }`, and environment values `APP_BASE_URL = 'http://tomcat:8080/meta/'`, `DEPLOY_CHECK_URL = 'http://tomcat:8080/meta/'`, and `TOMCAT_CONTEXT = 'meta'`. | ✅ | 2026-06-10 |
| TASK-023 | In `Jenkinsfile`, implement stage `Checkout` with `checkout scm` and skip it for timer-triggered availability builds. | ✅ | 2026-06-10 |
| TASK-024 | In `Jenkinsfile`, implement stage `Build WAR` with `sh 'mvn -B clean package'` and `archiveArtifacts artifacts: 'target/meta.war', fingerprint: true`, and skip it for timer-triggered availability builds. | ✅ | 2026-06-10 |
| TASK-025 | In `Jenkinsfile`, implement stage `Deploy Tomcat` with `sh 'SKIP_BUILD=1 TOMCAT_SHARED_WEBAPPS_DIR=/tomcat-webapps DEPLOY_CHECK_URL="$DEPLOY_CHECK_URL" ./scripts/deploy-war'`, and skip it for timer-triggered availability builds. | ✅ | 2026-06-10 |
| TASK-026 | In `Jenkinsfile`, implement stage `Verify Tomcat` with `sh 'curl -fsS "$APP_BASE_URL" >/dev/null'`, and skip it for timer-triggered availability builds. | ✅ | 2026-06-10 |
| TASK-027 | In `Jenkinsfile`, implement stage `Availability Check` with `sh 'curl -fsS "$APP_BASE_URL" >/dev/null'` and `triggeredBy 'TimerTrigger'` gating so the five-minute scheduled run produces Jenkins evidence for the availability check without running build, deploy, Playwright, or Gatling stages. | ✅ | 2026-06-10 |
| TASK-028 | In `Jenkinsfile`, implement stage `Playwright Functional Test` with script-existence and non-timer gating, then `steps { sh './scripts/run-playwright-container' }`. | ✅ | 2026-06-10 |
| TASK-029 | In `Jenkinsfile`, implement stage `Gatling Load Test` with script-existence and non-timer gating, then `steps { sh './scripts/run-gatling-load-5m' }`. | ✅ | 2026-06-10 |
| TASK-030 | In `Jenkinsfile`, implement stage `Gatling Stress Test` with script-existence and non-timer gating, then `steps { sh './scripts/run-gatling-stress-5m' }`. | ✅ | 2026-06-10 |
| TASK-031 | In `Jenkinsfile`, add `post { always { archiveArtifacts artifacts: 'output/**/*', allowEmptyArchive: true } }` so later Playwright and Gatling evidence can be archived when present. | ✅ | 2026-06-10 |

### Implementation Phase 4

- GOAL-004: Document Jenkins setup, job configuration, security tradeoffs, and evidence requirements.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-032 | Create `docs/jenkins.md` with sections named exactly `Runtime`, `Manual Jenkins Setup`, `Pipeline Job`, `Schedule`, `Security Notes`, `Evidence To Capture`, and `Troubleshooting`. | ✅ | 2026-06-10 |
| TASK-033 | In `docs/jenkins.md` section `Runtime`, document Jenkins URL `http://localhost:8081/`, Tomcat host URL `http://localhost:8080/meta/`, internal Docker URL `http://tomcat:8080/meta/`, Compose service names `jenkins` and `tomcat`, and Jenkins home volume `jenkins_home`. | ✅ | 2026-06-10 |
| TASK-034 | In `docs/jenkins.md` section `Manual Jenkins Setup`, document unlocking Jenkins, creating the admin user, installing required plugins `Git`, `Pipeline`, `Pipeline: SCM Step`, `Pipeline: Declarative`, `Pipeline: Stage View`, and `HTML Publisher` if report archival is needed. | ✅ | 2026-06-10 |
| TASK-035 | In `docs/jenkins.md` section `Pipeline Job`, document creating a Pipeline job named `meta-container-ci-cd`, selecting `Pipeline script from SCM`, selecting Git, entering `https://github.com/y0ncha/meta-final-project.git`, setting script path `Jenkinsfile`, and leaving credentials empty for a public repository. Also document the previous local validation fallback separately so it is not used as final evidence. | ✅ | 2026-06-10 |
| TASK-036 | In `docs/jenkins.md` section `Schedule`, document that the source-controlled cron expression `H/5 * * * *` runs only the `Availability Check` stage every five minutes, while SCM/manual builds run the CI/CD stages. | ✅ | 2026-06-10 |
| TASK-037 | In `docs/jenkins.md` section `Security Notes`, document the Jenkins runtime tradeoff and the shared Tomcat webapps deployment mount. The 2026-06-10 Plan 06 follow-up later adds Docker socket access for disposable test containers. | ✅ | 2026-06-10 |
| TASK-038 | In `docs/jenkins.md` section `Evidence To Capture`, list required screenshots or logs: Jenkins dashboard with URL `localhost:8081`, successful manual or SCM-triggered `meta-container-ci-cd` build, successful scheduled availability build, console log showing `mvn -B clean package`, console log showing `./scripts/deploy-war`, console log showing `curl -fsS http://tomcat:8080/meta/`, and Tomcat app visible at `http://localhost:8080/meta/`. | ✅ | 2026-06-10 |
| TASK-039 | Create `docs/changelog/05-jenkins-container-ci-cd.changelog.md` during implementation closeout and record changed files, exact observed tool versions, Docker image names, Jenkins job name, schedule, validation commands, and evidence paths. | ✅ | 2026-06-10 |

### Implementation Phase 5

- GOAL-005: Validate Jenkins runtime capability, pipeline deployment commands, local Tomcat reachability, and repository cleanliness.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-040 | Run `docker compose up -d tomcat jenkins` from the repository root and confirm both services start. | ✅ | 2026-06-10 |
| TASK-041 | Run `docker compose exec -T jenkins sh -lc 'command -v mvn && command -v curl && command -v git'` and confirm it exits with status `0`. | ✅ | 2026-06-10 |
| TASK-042 | Run `docker compose exec -T jenkins sh -lc 'cd /workspace/final-project && mvn -B clean package'` and confirm it exits with status `0`. | ✅ | 2026-06-10 |
| TASK-043 | Run `docker compose exec -T jenkins sh -lc 'cd /workspace/final-project && SKIP_BUILD=1 TOMCAT_SHARED_WEBAPPS_DIR=/tomcat-webapps DEPLOY_CHECK_URL=http://tomcat:8080/meta/ ./scripts/deploy-war'` and confirm it exits with status `0`. | ✅ | 2026-06-10 |
| TASK-044 | Run `docker compose exec -T jenkins sh -lc 'curl -fsS http://tomcat:8080/meta/ >/dev/null'` and confirm it exits with status `0`. | ✅ | 2026-06-10 |
| TASK-045 | Run `curl -f http://localhost:8080/meta/` from the host repository root and confirm it exits with status `0`. | ✅ | 2026-06-10 |
| TASK-046 | In Jenkins at `http://localhost:8081/`, create or update Pipeline job `meta-container-ci-cd` using `docs/jenkins.md`, run a manual build, and confirm the build exits with status `SUCCESS`. Local validation may use the authenticated Jenkins API to avoid inventing a GitHub SCM URL before a remote exists. | ✅ | 2026-06-10 |
| TASK-047 | Wait for one scheduled run from cron `H/5 * * * *`; confirm Jenkins records a scheduled `SUCCESS` build that includes the `Availability Check` stage and skips build, deploy, Playwright, and Gatling stages. | ✅ | 2026-06-10 |
| TASK-048 | Save Jenkins and Tomcat evidence under ignored paths `output/jenkins/` and `output/screenshots/`; confirm generated evidence remains untracked. | ✅ | 2026-06-10 |
| TASK-049 | Run `git diff -- Jenkinsfile docker-compose.yml scripts/deploy-war ops/jenkins/Dockerfile docs/jenkins.md docs/changelog/05-jenkins-container-ci-cd.changelog.md docs/plans/05-jenkins-container-ci-cd.md | rtk diff -` and verify the diff contains no secrets, no generated WAR content, no screenshots, and no unrelated files. | ✅ | 2026-06-10 |
| TASK-050 | Run `git status --short --branch` and confirm Plan 05 tracked changes are limited to `Jenkinsfile`, `docker-compose.yml`, `scripts/deploy-war`, `ops/jenkins/Dockerfile`, `docs/jenkins.md`, `docs/changelog/05-jenkins-container-ci-cd.changelog.md`, and `docs/plans/05-jenkins-container-ci-cd.md`; document any unrelated pre-existing tracked diff separately instead of reverting it. | ✅ | 2026-06-10 |

### Implementation Phase 6

- GOAL-006: Add Jenkins Docker Compose tooling and Jenkins-native report publishing without changing the containerized test-runner model.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-051 | Update `ops/jenkins/Dockerfile` to add Docker's official Debian apt repository and install `docker-ce-cli` and `docker-compose-plugin` instead of the Debian `docker-cli` package. | ✅ | 2026-06-10 |
| TASK-052 | Update `ops/jenkins/Dockerfile` to preinstall Jenkins plugins `docker-workflow`, `htmlpublisher`, and `gatling` with `jenkins-plugin-cli`. | ✅ | 2026-06-10 |
| TASK-053 | Update `Jenkinsfile` post-build behavior to publish `output/playwright/junit.xml` through `junit` when present. | ✅ | 2026-06-10 |
| TASK-054 | Update `Jenkinsfile` post-build behavior to publish Playwright and Gatling HTML reports with `publishHTML` when each report `index.html` exists. | ✅ | 2026-06-10 |
| TASK-055 | Keep `gatlingArchive()` deferred until Plan 08 validates a real Gatling output shape compatible with the Jenkins Gatling plugin. | ✅ | 2026-06-10 |
| TASK-056 | Update `docs/jenkins.md`, `docs/playwright.md`, `docs/plans/06-playwright-container-functional-test.md`, and `docs/plans/08-gatling-container-tests.md` so the report publishing and plugin roles are explicit. | ✅ | 2026-06-10 |

## 3. Alternatives

- **ALT-001**: Configure a Jenkins freestyle job entirely through the UI. Rejected because the pipeline would not be source-controlled, reviewable, or reproducible from Git.
- **ALT-002**: Run Jenkins directly on the host at `/Users/yonatan/.jenkins`. Rejected because `rules/compliance.md` requires containerized Jenkins and forbids host Jenkins as a project runtime dependency.
- **ALT-003**: Use the stock `jenkins/jenkins:2.528.1-lts-jdk21` image without adding command-line tools. Rejected because the current pipeline requires `mvn` and `curl` inside the Jenkins runtime.
- **ALT-004**: Deploy by copying the WAR into a host Tomcat folder. Rejected because Tomcat must be containerized and deployed through Docker Compose service `tomcat`.
- **ALT-005**: Use a separate Jenkins job for each future Playwright, Gatling load, and Gatling stress action. Rejected for Plan 05 because one source-controlled Pipeline job can handle SCM/manual CI/CD builds and timer-triggered availability checks with explicit stage gating.
- **ALT-006**: Run Playwright and Gatling stages unconditionally before Plans 06 and 08 create their scripts. Rejected because Plan 05 must produce a Jenkins deployment pipeline that can pass before later plan files exist.
- **ALT-007**: Use `*/5 * * * *` for the Jenkins availability schedule. Rejected because Jenkins convention prefers hashed schedules such as `H/5 * * * *` to avoid synchronized load.
- **ALT-008**: Use Docker socket access for Tomcat deployment from Jenkins. Rejected because deployment by shared `tomcat_webapps` volume is simpler and more directly aligned with the existing Tomcat service. A later Plan 06 follow-up accepts Docker socket access only for disposable browser test containers.

## 4. Dependencies

- **DEP-001**: `docker-compose.yml` must define services `jenkins` and `tomcat` on network `meta`.
- **DEP-002**: Docker Engine must be installed and running before Jenkins can build or deploy through Docker Compose.
- **DEP-003**: Docker Compose v2 must be available through `docker compose`.
- **DEP-004**: Docker image `jenkins/jenkins:2.528.1-lts-jdk21` must be pullable or already cached locally.
- **DEP-005**: The custom Jenkins image build requires network access unless Debian and Docker package indexes are already cached.
- **DEP-006**: Maven must run inside the Jenkins container through the custom Jenkins image.
- **DEP-007**: Curl must run inside the Jenkins container through the custom Jenkins image.
- **DEP-008**: Docker volume `tomcat_webapps` must be mounted into Jenkins at `/tomcat-webapps`.
- **DEP-009**: `scripts/deploy-war` from Plan 04 must exist and remain executable.
- **DEP-010**: Plan 03 must have produced a valid Maven WAR project with `pom.xml` and `src/main/webapp/index.jsp`.
- **DEP-011**: Local host ports `8080` and `8081` must be free unless a documented port conflict requires a temporary override.
- **DEP-012**: The final GitHub repository URL must be public or Jenkins credentials must be configured manually in Jenkins.
- **DEP-013**: Jenkins plugins `Git`, `Pipeline`, `Pipeline: SCM Step`, `Pipeline: Declarative`, and `Pipeline: Stage View` must be installed before the Pipeline job can run from SCM.
- **DEP-014**: Plan 06 must create `scripts/run-playwright-container` before the `Playwright Functional Test` stage performs real browser automation.
- **DEP-015**: Plan 08 must create `scripts/run-gatling-load-5m` and `scripts/run-gatling-stress-5m` before the Gatling stages perform real load and stress tests.
- **DEP-016**: Docker's Debian apt repository must be reachable or cached when rebuilding the Jenkins image for Docker Compose support.
- **DEP-017**: Jenkins plugin update center must be reachable or cached when rebuilding the Jenkins image for `docker-workflow`, `htmlpublisher`, and `gatling`.

## 5. Files

- **FILE-001**: `docs/plans/05-jenkins-container-ci-cd.md` is this source implementation plan and will be updated in place.
- **FILE-002**: `docker-compose.yml` will be modified to build and run a Jenkins container capable of executing Maven and curl commands and writing to the shared Tomcat webapps volume.
- **FILE-003**: `ops/jenkins/Dockerfile` will be created as the custom Jenkins image definition.
- **FILE-004**: `Jenkinsfile` will be created as the source-controlled Declarative Pipeline definition.
- **FILE-005**: `scripts/deploy-war` will be modified to support `SKIP_BUILD` and `DEPLOY_CHECK_URL` while preserving local defaults.
- **FILE-006**: `docs/jenkins.md` will be created as the Jenkins setup, job, schedule, security, and evidence guide.
- **FILE-007**: `docs/changelog/05-jenkins-container-ci-cd.changelog.md` will be created during closeout to record implementation and validation evidence.
- **FILE-008**: `target/meta.war` will be generated during validation and archived by Jenkins, but it must remain untracked.
- **FILE-009**: `output/jenkins/` will hold ignored Jenkins evidence screenshots or exported logs.
- **FILE-010**: `output/screenshots/` will hold ignored Tomcat and Jenkins browser screenshots.
- **FILE-011**: `docs/plans/06-playwright-container-functional-test.md` will be read for future stage contract alignment and not modified by this plan.
- **FILE-012**: `docs/plans/08-gatling-container-tests.md` will be read for future stage contract alignment and not modified by this plan.
- **FILE-013**: `docs/plans/09-monitoring-and-jenkins-schedule.md` will be read for monitoring contract alignment and not modified by this plan.
- **FILE-014**: `docs/plans/08-gatling-container-tests.md` is updated by the 2026-06-10 tooling follow-up to document Jenkins HTML publishing and deferred `gatlingArchive()` use.

## 6. Testing

- **TEST-001**: `docker compose config` must exit with status `0`.
- **TEST-002**: `docker compose build jenkins` must exit with status `0`.
- **TEST-003**: `docker compose up -d tomcat jenkins` must exit with status `0`.
- **TEST-004**: `docker compose exec -T jenkins sh -lc 'command -v mvn && command -v curl && command -v git'` must exit with status `0`.
- **TEST-005**: `docker compose exec -T jenkins sh -lc 'cd /workspace/final-project && mvn -B clean package'` must exit with status `0`.
- **TEST-006**: `test -f target/meta.war` must exit with status `0` after the Jenkins-container Maven build.
- **TEST-007**: `docker compose exec -T jenkins sh -lc 'cd /workspace/final-project && SKIP_BUILD=1 TOMCAT_SHARED_WEBAPPS_DIR=/tomcat-webapps DEPLOY_CHECK_URL=http://tomcat:8080/meta/ ./scripts/deploy-war'` must exit with status `0`.
- **TEST-008**: `docker compose exec -T jenkins sh -lc 'curl -fsS http://tomcat:8080/meta/ >/dev/null'` must exit with status `0`.
- **TEST-009**: `curl -f http://localhost:8080/meta/` from the host repository root must exit with status `0`.
- **TEST-010**: Jenkins Pipeline job `meta-container-ci-cd` must complete a manual build with result `SUCCESS`.
- **TEST-011**: Jenkins Pipeline job `meta-container-ci-cd` must complete at least one timer-triggered availability build with result `SUCCESS`, and that build must skip CI/CD stages.
- **TEST-012**: Jenkins console output for a non-timer build must show stage names `Checkout`, `Build WAR`, `Deploy Tomcat`, and `Verify Tomcat`; timer build output must show `Availability Check`.
- **TEST-013**: Jenkins console output for a non-timer build must show `mvn -B clean package`, `./scripts/deploy-war`, and `curl -fsS http://tomcat:8080/meta/`.
- **TEST-014**: Jenkins archived artifacts must include `target/meta.war` for the successful build.
- **TEST-015**: `git diff -- Jenkinsfile docker-compose.yml scripts/deploy-war ops/jenkins/Dockerfile docs/jenkins.md docs/changelog/05-jenkins-container-ci-cd.changelog.md docs/plans/05-jenkins-container-ci-cd.md | rtk diff -` must show no secrets and no generated artifacts.
- **TEST-016**: `git status --short --branch` must show no tracked `target/`, `*.war`, Jenkins home data, Docker volume state, screenshots, logs, Playwright reports, Gatling reports, credentials, or `.env` files. Any unrelated tracked diff must be called out separately.
- **TEST-017**: `docker compose exec -T jenkins docker compose version` must exit with status `0` after rebuilding and recreating Jenkins.
- **TEST-018**: `docker compose exec -T jenkins sh -lc 'test -f /var/jenkins_home/plugins/docker-workflow.jpi || test -f /var/jenkins_home/plugins/docker-workflow.hpi'` must exit with status `0`.
- **TEST-019**: `docker compose exec -T jenkins sh -lc 'test -f /var/jenkins_home/plugins/htmlpublisher.jpi || test -f /var/jenkins_home/plugins/htmlpublisher.hpi'` must exit with status `0`.
- **TEST-020**: `docker compose exec -T jenkins sh -lc 'test -f /var/jenkins_home/plugins/gatling.jpi || test -f /var/jenkins_home/plugins/gatling.hpi'` must exit with status `0`.

## 7. Risks & Assumptions

- **RISK-001**: Building the custom Jenkins image may require network access to Debian and Docker package repositories.
- **RISK-002**: Running Jenkins as `root` inside the container may be required for write access to the shared Tomcat webapps volume; if required, document the reason and do not generalize it as a best practice.
- **RISK-003**: Direct shared-volume deployment bypasses `docker compose cp` inside Jenkins, so `scripts/deploy-war` must preserve the Plan 04 Docker Compose path for local host execution.
- **RISK-004**: The Jenkins first-run unlock, admin setup, plugin installation, and Pipeline job creation require screenshots or logs for evidence. Historical local validation used the authenticated Jenkins API before a GitHub remote existed; final evidence should use the SCM-backed job.
- **RISK-005**: Local ports `8080` or `8081` may already be occupied; do not silently change ports because assignment evidence expects those URLs.
- **RISK-006**: The scheduled availability check runs every five minutes and may create noisy Jenkins history; use `buildDiscarder` to bound retained build records.
- **RISK-007**: Later Playwright and Gatling stages are gated by script existence, so Plan 05 alone proves Jenkins deployment and availability checks but not final browser or performance compliance.
- **RISK-008**: Tomcat may need several seconds to expand `meta.war` after Jenkins replaces it in the shared volume; the deployment script must wait on `http://tomcat:8080/meta/`.
- **RISK-009**: Existing `jenkins_home` volume contents can hide image reference-plugin changes until Jenkins is rebuilt and restarted; verify plugin files inside `/var/jenkins_home/plugins`.
- **RISK-010**: The Jenkins Gatling plugin is used only for future report/trend visibility. If Plan 08 output is not compatible, keep `archiveArtifacts` and `htmlpublisher` as the authoritative evidence path.
- **ASSUMPTION-001**: The GitHub repository `https://github.com/y0ncha/meta-final-project.git` is public by the time the final Jenkins Pipeline job is configured from SCM. During earlier local Plan 05 validation, the repository had no Git remote, so Jenkins read the mounted source-controlled `Jenkinsfile` directly.
- **ASSUMPTION-002**: The Compose service names remain `jenkins` and `tomcat`.
- **ASSUMPTION-003**: The Jenkins container can resolve `http://tomcat:8080/meta/` through the shared Compose network `meta`.
- **ASSUMPTION-004**: Plan 04's `scripts/deploy-war` remains the canonical deployment entrypoint and should be extended instead of replaced.
- **ASSUMPTION-005**: Generated Jenkins evidence under `output/jenkins/` and screenshot evidence under `output/screenshots/` remain ignored by Git.

## 8. Related Specifications / Further Reading

- [Project contribution workflow](../../contribution.md)
- [Project compliance rules](../../rules/compliance.md)
- [Docker Compose foundation plan](./02-docker-compose-foundation.md)
- [JSP Maven WAR application plan](./03-jsp-maven-war-app.md)
- [Tomcat container deployment plan](./04-tomcat-container-deployment.md)
- [Playwright container functional test plan](./06-playwright-container-functional-test.md)
- [Gatling container tests plan](./08-gatling-container-tests.md)
- [Monitoring and Jenkins schedule plan](./09-monitoring-and-jenkins-schedule.md)
- [Repository baseline](../repository-baseline.md)
- [Jenkins documentation: Using a Jenkinsfile](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/)
- [Jenkins documentation: Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Jenkins documentation: Installing Jenkins with Docker](https://www.jenkins.io/doc/book/installing/docker/)
