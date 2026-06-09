---
goal: Tomcat Container Deployment for the Meta WAR
version: 1.0
date_created: 2026-06-10
last_updated: 2026-06-10
owner: Project team
status: "Completed"
tags:
  - infrastructure
  - deployment
  - docker
  - tomcat
  - war
  - devops-final-project
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

This plan deploys the Maven-built JSP WAR `target/meta.war` into the containerized Apache Tomcat 8.5.x runtime defined in `docker-compose.yml`. The deployment must copy the WAR into the Docker-managed Tomcat `webapps` volume through the running `tomcat` Compose service, serve the application at `http://localhost:8080/meta/`, and produce repeatable local evidence without using host Tomcat.

## 1. Requirements & Constraints

- **REQ-001**: Deploy `target/meta.war` into the Docker Compose service named `tomcat`.
- **REQ-002**: The deployed WAR filename inside the container must be `/usr/local/tomcat/webapps/meta.war`.
- **REQ-003**: The expanded Tomcat application directory inside the container must be `/usr/local/tomcat/webapps/meta`.
- **REQ-004**: The local application URL must be `http://localhost:8080/meta/`.
- **REQ-005**: The deployment entrypoint must be an executable repository script at `scripts/deploy-war`.
- **REQ-006**: `scripts/deploy-war` must build the WAR with `mvn clean package` before copying it into Tomcat.
- **REQ-007**: `scripts/deploy-war` must start or ensure the `tomcat` Compose service is running before deployment.
- **REQ-008**: `scripts/deploy-war` must remove stale `/usr/local/tomcat/webapps/meta` and `/usr/local/tomcat/webapps/meta.war` inside the Tomcat container before copying the new WAR.
- **REQ-009**: `scripts/deploy-war` must wait until `curl -fsS http://localhost:${TOMCAT_HOST_PORT:-8080}/meta/` succeeds or fail with a non-zero exit status after a bounded timeout.
- **REQ-010**: Deployment evidence must include the deployed WAR path, the expanded application directory, a successful HTTP check, and a browser-visible local URL.
- **CON-001**: Read `contribution.md` from the repository root before implementation and stop if any task conflicts with it.
- **CON-002**: Create or switch to branch `feature/plan-04-tomcat-container-deployment` before mutating tracked files for this plan.
- **CON-003**: Use the containerized runtime defined by `contribution.md`; do not use host Tomcat, `/usr/local/tomcat8`, host Catalina scripts, or `/Users/yonatan/devops/tools/tomcat8`.
- **CON-004**: Do not change the Maven coordinate `mta.devops:meta:1.0.0` or the Maven `<finalName>meta</finalName>` value created by Plan 03.
- **CON-005**: Do not change the Tomcat host port from `8080` unless implementation is blocked by a real port conflict and the conflict is documented.
- **CON-006**: Do not commit generated `target/` output, generated `*.war` files, Tomcat expanded webapps output, screenshots, logs, or Docker volume state.
- **CON-007**: Do not install, upgrade, reinstall, or replace Docker, Tomcat, Java, Maven, Playwright, Gatling, Jenkins, Node, Bun, or other tools while executing this plan.
- **SEC-001**: Do not write credentials, tokens, Jenkins secrets, cookies, private keys, passwords, or personally sensitive data to deployment scripts, documentation, logs, or evidence files.
- **SEC-002**: Do not expose Tomcat publicly in this plan; bind only the local Docker Compose port mapping already defined by `docker-compose.yml`.
- **GUD-001**: Prefer `docker compose` v2 commands over legacy `docker-compose` commands.
- **GUD-002**: Use `rtk read`, `rtk grep`, `rtk find`, `rtk diff`, and `rtk docker` for noisy reads, searches, diffs, and Docker output when they preserve required detail.
- **PAT-001**: Follow the existing repository pattern: tracked automation in `scripts/`, generated validation evidence under ignored `output/`, and implementation closeout in `docs/changelog/`.
- **PAT-002**: Keep deployment idempotent so repeated executions of `scripts/deploy-war` replace the previously deployed `meta` application without requiring manual Docker volume cleanup.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Verify the execution context, branch, tool versions, and existing deployment targets before editing files.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Run `rtk read contribution.md` from the repository root and confirm Plan 04 uses containerized Tomcat 8.5.x in Docker, deploys the app under `/meta/`, and does not depend on host Tomcat or host Jenkins. | ✅ | 2026-06-10 |
| TASK-002 | Run `git status --short --branch` from the repository root. If unrelated uncommitted changes exist, stop and report the exact output before switching branches or editing files. | ✅ | 2026-06-10 |
| TASK-003 | Create or switch to branch `feature/plan-04-tomcat-container-deployment`. If branch creation is blocked by uncommitted work, stop and report the exact `git status --short --branch` output. | ✅ | 2026-06-10 |
| TASK-004 | Run `docker --version`, `docker compose version`, `mvn --version`, and `java -version`; record the exact observed versions in `docs/changelog/04-tomcat-container-deployment.changelog.md` during closeout. | ✅ | 2026-06-10 |
| TASK-005 | Run `rtk read docker-compose.yml` and confirm service `tomcat` uses image `${TOMCAT_IMAGE:-tomcat:8.5.100-jdk17-temurin}`, publishes `${TOMCAT_HOST_PORT:-8080}:8080`, and mounts volume `tomcat_webapps` at `/usr/local/tomcat/webapps`. | ✅ | 2026-06-10 |
| TASK-006 | Run `rtk read pom.xml` and confirm `<packaging>war</packaging>` and `<finalName>meta</finalName>` are present. If either value is missing, stop and report that Plan 03 is incomplete. | ✅ | 2026-06-10 |
| TASK-007 | Run `rtk read scripts/README.md` and confirm repository scripts must run from the project root and document required environment variables. | ✅ | 2026-06-10 |

### Implementation Phase 2

- GOAL-002: Add the repeatable Tomcat WAR deployment script.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-008 | Create executable file `scripts/deploy-war` with shebang `#!/usr/bin/env sh` and shell options `set -eu`. | ✅ | 2026-06-10 |
| TASK-009 | In `scripts/deploy-war`, compute `PROJECT_ROOT` by resolving the parent directory of the script directory and run `cd "$PROJECT_ROOT"` before executing Maven or Docker commands. | ✅ | 2026-06-10 |
| TASK-010 | In `scripts/deploy-war`, define `TOMCAT_SERVICE="${TOMCAT_SERVICE:-tomcat}"`, `TOMCAT_CONTEXT="${TOMCAT_CONTEXT:-meta}"`, `TOMCAT_WEBAPPS_DIR="${TOMCAT_WEBAPPS_DIR:-/usr/local/tomcat/webapps}"`, `TOMCAT_HOST_PORT="${TOMCAT_HOST_PORT:-8080}"`, `DEPLOY_TIMEOUT_SECONDS="${DEPLOY_TIMEOUT_SECONDS:-60}"`, and `WAR_SOURCE="${WAR_SOURCE:-target/meta.war}"`. | ✅ | 2026-06-10 |
| TASK-011 | In `scripts/deploy-war`, validate `TOMCAT_CONTEXT` equals `meta`; if it differs, print `TOMCAT_CONTEXT must remain meta for this coursework plan` to stderr and exit with status `2`. | ✅ | 2026-06-10 |
| TASK-012 | In `scripts/deploy-war`, run `mvn clean package` from the repository root and then verify `test -f "$WAR_SOURCE"` succeeds before starting deployment. | ✅ | 2026-06-10 |
| TASK-013 | In `scripts/deploy-war`, run `docker compose up -d "$TOMCAT_SERVICE"` to create or start the Tomcat container. | ✅ | 2026-06-10 |
| TASK-014 | In `scripts/deploy-war`, run `docker compose exec -T "$TOMCAT_SERVICE" sh -c 'rm -rf "$1/$2" "$1/$2.war"' sh "$TOMCAT_WEBAPPS_DIR" "$TOMCAT_CONTEXT"` to remove stale deployment artifacts from the container without interpolating environment-derived paths into the inner shell source. | ✅ | 2026-06-10 |
| TASK-015 | In `scripts/deploy-war`, run `docker compose cp "$WAR_SOURCE" "$TOMCAT_SERVICE:$TOMCAT_WEBAPPS_DIR/$TOMCAT_CONTEXT.war"` to copy the WAR into the Docker-managed Tomcat webapps volume. | ✅ | 2026-06-10 |
| TASK-016 | In `scripts/deploy-war`, poll `http://localhost:$TOMCAT_HOST_PORT/$TOMCAT_CONTEXT/` once per second until `curl -fsS` succeeds or `DEPLOY_TIMEOUT_SECONDS` is reached; on timeout, print the last `docker compose logs --tail=80 "$TOMCAT_SERVICE"` output and exit with status `1`. | ✅ | 2026-06-10 |
| TASK-017 | In `scripts/deploy-war`, print the final deployed URL exactly as `Deployed URL: http://localhost:$TOMCAT_HOST_PORT/$TOMCAT_CONTEXT/` after successful validation. | ✅ | 2026-06-10 |
| TASK-018 | Run `chmod +x scripts/deploy-war` and confirm `test -x scripts/deploy-war` exits with status `0`. | ✅ | 2026-06-10 |

### Implementation Phase 3

- GOAL-003: Validate container deployment, Tomcat expansion, and local HTTP reachability.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-019 | Run `docker compose config` from the repository root and confirm it exits with status `0`. | ✅ | 2026-06-10 |
| TASK-020 | Run `./scripts/deploy-war` from the repository root and confirm it exits with status `0`. | ✅ | 2026-06-10 |
| TASK-021 | Run `docker compose ps tomcat` and confirm the `tomcat` service is running and publishes host port `8080` to container port `8080`, or the configured `TOMCAT_HOST_PORT` if explicitly set. | ✅ | 2026-06-10 |
| TASK-022 | Run `docker compose exec -T tomcat sh -lc 'test -f /usr/local/tomcat/webapps/meta.war'` and confirm it exits with status `0`. | ✅ | 2026-06-10 |
| TASK-023 | Run `docker compose exec -T tomcat sh -lc 'test -d /usr/local/tomcat/webapps/meta'` and confirm it exits with status `0`; if expansion is delayed, wait up to `60` seconds before failing. | ✅ | 2026-06-10 |
| TASK-024 | Run `curl -f http://localhost:8080/meta/` from the repository root and confirm it exits with status `0`. | ✅ | 2026-06-10 |
| TASK-025 | Run `curl -s http://localhost:8080/meta/` and confirm the response contains `DevOps Final Project`, `About this app`, `nameInput`, and `submitButton`. | ✅ | 2026-06-10 |
| TASK-026 | Capture browser evidence after TASK-024 passes and save it under ignored path `output/screenshots/04-tomcat-meta-local.png`; verify browser URL state as `http://localhost:8080/meta/` and document any browser-chrome screenshot limitation in `docs/changelog/04-tomcat-container-deployment.changelog.md`. | ✅ | 2026-06-10 |

### Implementation Phase 4

- GOAL-004: Document implementation evidence and verify the repository contains only intentional tracked changes.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-027 | Create `docs/changelog/04-tomcat-container-deployment.changelog.md` after implementation and validation are complete. | ✅ | 2026-06-10 |
| TASK-028 | In `docs/changelog/04-tomcat-container-deployment.changelog.md`, document files changed, exact tool versions observed, Docker Compose service name `tomcat`, deployed container paths, local URL `http://localhost:8080/meta/`, and all validation commands from TASK-019 through TASK-025. | ✅ | 2026-06-10 |
| TASK-029 | In `docs/changelog/04-tomcat-container-deployment.changelog.md`, document the screenshot evidence path `output/screenshots/04-tomcat-meta-local.png` and state that generated evidence is ignored by Git. | ✅ | 2026-06-10 |
| TASK-030 | Run `git diff -- scripts/deploy-war docs/changelog/04-tomcat-container-deployment.changelog.md docs/plans/04-tomcat-container-deployment.md | rtk diff -` and verify the diff contains no secrets, no generated WAR content, no screenshots, and no unrelated files. | ✅ | 2026-06-10 |
| TASK-031 | Run `git status --short --branch` and confirm tracked changes are limited to `scripts/deploy-war`, `docs/changelog/04-tomcat-container-deployment.changelog.md`, and any intentional documentation-only updates required by this plan. | ✅ | 2026-06-10 |

## 3. Alternatives

- **ALT-001**: Copy `target/meta.war` into a host Tomcat installation under `/usr/local/tomcat8/webapps`. Rejected because `contribution.md` explicitly requires containerized Tomcat as the project runtime and forbids relying on host Tomcat.
- **ALT-002**: Replace the Docker-managed `tomcat_webapps` named volume with a bind mount to a repository directory. Rejected because Plan 02 already defines the Docker-managed volume and repository directories must not hold generated Tomcat runtime state.
- **ALT-003**: Build the WAR outside the deployment script and require a manual copy step. Rejected because the deployment must be repeatable from one repository command and defensible during the live project demo.
- **ALT-004**: Run Tomcat through Maven plugins such as Cargo or embedded Jetty. Rejected because the assignment evidence must show deployment into Apache Tomcat `webapps` and the project runtime is already Docker Compose Tomcat.
- **ALT-005**: Change the context path to include group member names. Rejected for this plan because `contribution.md` records the accepted override to use the Maven `meta` final name unless the lecturer later requires names specifically.

## 4. Dependencies

- **DEP-001**: `docker-compose.yml` must define service `tomcat` and named volume `tomcat_webapps`.
- **DEP-002**: Docker Engine must be installed and running before `docker compose up -d tomcat` can pass.
- **DEP-003**: Docker Compose v2 must be available through `docker compose`.
- **DEP-004**: Docker image `tomcat:8.5.100-jdk17-temurin` must be pullable or already present locally.
- **DEP-005**: Maven must be available through `mvn` and able to run `mvn clean package`.
- **DEP-006**: Java must be available for Maven execution.
- **DEP-007**: Plan 03 must have produced a valid Maven WAR project with `pom.xml` and `src/main/webapp/index.jsp`.
- **DEP-008**: Local port `8080` must be free unless `TOMCAT_HOST_PORT` is intentionally set to another value and documented.
- **DEP-009**: `curl` must be available locally for deployment readiness checks.

## 5. Files

- **FILE-001**: `scripts/deploy-war` will be created as the executable deployment entrypoint for building and copying `target/meta.war` into the Tomcat container.
- **FILE-002**: `docs/changelog/04-tomcat-container-deployment.changelog.md` will be created during closeout to record implementation details and validation evidence.
- **FILE-003**: `docs/plans/04-tomcat-container-deployment.md` is this source implementation plan and will be updated only to reflect the final executed state after implementation.
- **FILE-004**: `docker-compose.yml` will be read to confirm service, port, image, network, and volume settings; it will not be modified unless validation proves Plan 02 is incomplete.
- **FILE-005**: `pom.xml` will be read to confirm the Maven WAR final name; it will not be modified by this plan.
- **FILE-006**: `target/meta.war` will be generated by Maven and copied into Tomcat, but it must remain untracked.
- **FILE-007**: `output/screenshots/04-tomcat-meta-local.png` will be generated as ignored evidence and must remain untracked.
- **FILE-008**: `.gitignore` will be read to confirm `target/`, `*.war`, and `output/**` are ignored; it will be modified only if generated deployment artifacts are not ignored.

## 6. Testing

- **TEST-001**: `docker compose config` must exit with status `0`.
- **TEST-002**: `./scripts/deploy-war` must exit with status `0`.
- **TEST-003**: `test -x scripts/deploy-war` must exit with status `0`.
- **TEST-004**: `test -f target/meta.war` must exit with status `0` after `./scripts/deploy-war` runs.
- **TEST-005**: `docker compose ps tomcat` must show the Tomcat service running with port `8080` published to container port `8080`, unless `TOMCAT_HOST_PORT` is explicitly set and documented.
- **TEST-006**: `docker compose exec -T tomcat sh -lc 'test -f /usr/local/tomcat/webapps/meta.war'` must exit with status `0`.
- **TEST-007**: `docker compose exec -T tomcat sh -lc 'test -d /usr/local/tomcat/webapps/meta'` must exit with status `0`.
- **TEST-008**: `curl -f http://localhost:8080/meta/` must exit with status `0`.
- **TEST-009**: `curl -s http://localhost:8080/meta/` must contain `DevOps Final Project`, `About this app`, `nameInput`, and `submitButton`.
- **TEST-010**: Browser evidence must be saved at `output/screenshots/04-tomcat-meta-local.png`, and browser URL state must be verified as `http://localhost:8080/meta/`; if the screenshot API cannot include browser chrome, the limitation must be documented in `docs/changelog/04-tomcat-container-deployment.changelog.md`.
- **TEST-011**: `git diff -- scripts/deploy-war docs/changelog/04-tomcat-container-deployment.changelog.md docs/plans/04-tomcat-container-deployment.md | rtk diff -` must show no secrets and no generated artifact content.
- **TEST-012**: `git status --short --branch` must show no tracked `target/`, `*.war`, Tomcat webapps output, Docker volume state, or screenshot evidence files.

## 7. Risks & Assumptions

- **RISK-001**: Docker may require network access to pull `tomcat:8.5.100-jdk17-temurin` if the image is not cached locally.
- **RISK-002**: Maven may require network access to resolve plugins or dependencies if they are not cached locally.
- **RISK-003**: Local port `8080` may already be occupied by another process; do not silently change the port because grading evidence expects `http://localhost:8080/meta/`.
- **RISK-004**: Tomcat may need several seconds to expand `meta.war`; the deployment script must wait before failing.
- **RISK-005**: The `meta` context path remains an accepted assignment compliance risk because the original PDF asked for a folder or context containing group member names.
- **RISK-006**: Docker-managed volumes can retain stale exploded webapps; the script must remove the stale WAR and directory before copying the new WAR.
- **RISK-007**: Browser automation screenshots may capture the rendered page viewport without browser chrome; final manual submission evidence may still require a separate human-captured screenshot with the address bar visible.
- **ASSUMPTION-001**: Plan 03 has already created a valid JSP Maven WAR project that builds `target/meta.war`.
- **ASSUMPTION-002**: The Compose service name remains `tomcat` and the container webapps path remains `/usr/local/tomcat/webapps`.
- **ASSUMPTION-003**: `output/**` remains ignored by Git, so screenshot evidence can be generated locally without becoming a tracked source artifact.

## 8. Related Specifications / Further Reading

- [Project contribution and compliance guide](../../contribution.md)
- [Docker Compose foundation plan](./02-docker-compose-foundation.md)
- [JSP Maven WAR application plan](./03-jsp-maven-war-app.md)
- [Jenkins container CI/CD plan](./05-jenkins-container-ci-cd.md)
- [Playwright container functional test plan](./06-playwright-container-functional-test.md)
- [Repository baseline](../repository-baseline.md)
