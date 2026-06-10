---
goal: Docker Compose Foundation for Containerized Tomcat and Jenkins
version: 1.0
date_created: 2026-06-09
last_updated: 2026-06-09
owner: Project team
status: "Completed"
tags:
  - infrastructure
  - docker
  - tomcat
  - jenkins
  - devops-final-project
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

This plan defines and records the completed implementation steps for Plan 02: create the Docker Compose foundation for the MTA DevOps final project with containerized Apache Tomcat 8.5.x on `http://localhost:8080/` and containerized Jenkins on `http://localhost:8081/`. This plan intentionally excludes JSP application code, Playwright execution, Gatling execution, HAR capture, monitoring configuration, and public VM deployment.

## 1. Requirements & Constraints

- **REQ-001**: Create `docker-compose.yml` at the repository root with a `tomcat` service and a `jenkins` service.
- **REQ-002**: Configure the `tomcat` service to publish host port `8080` to container port `8080`.
- **REQ-003**: Configure the `jenkins` service to publish host port `8081` to container port `8080`.
- **REQ-004**: Configure a persistent Docker-managed named volume `tomcat_webapps` mounted at the container target path `/usr/local/tomcat/webapps` in the `tomcat` service without defining a host filesystem path.
- **REQ-005**: Configure a persistent Docker-managed named volume `jenkins_home` mounted at the container target path `/var/jenkins_home` in the `jenkins` service without defining a host filesystem path.
- **REQ-006**: Configure a shared Docker bridge network named `meta` and attach both services to it.
- **REQ-007**: Use Compose service names `tomcat` and `jenkins` exactly so later scripts and Jenkins jobs can target those names deterministically.
- **REQ-008**: Mount the repository root into the `jenkins` service at `/workspace/final-project` so later Jenkins jobs can access project scripts and source files.
- **REQ-009**: Add `.env.example` at the repository root with explicit default values for `COMPOSE_PROJECT_NAME=meta`, `TOMCAT_IMAGE`, `JENKINS_IMAGE`, `TOMCAT_HOST_PORT`, and `JENKINS_HOST_PORT`.
- **CON-001**: Read `contribution.md` from the repository root before executing this plan.
- **CON-002**: Create or switch to a scoped Git branch before mutating tracked files for this plan.
- **CON-003**: Do not install, upgrade, reinstall, or replace Docker, Tomcat, Jenkins, Java, Maven, Node, Bun, Playwright, or Gatling while executing this plan.
- **CON-004**: Use the containerized runtime path exclusively for Tomcat and Jenkins; do not depend on host Tomcat or host Jenkins installations for setup, commands, evidence, or fallback runtime behavior.
- **CON-005**: Do not add Gatling or Playwright long-running services to `docker-compose.yml`; those tools must run as one-shot containers in later plans.
- **CON-006**: Do not commit generated runtime state, Docker volumes, Jenkins home directories, Tomcat webapps output, logs, screenshots, reports, or secrets.
- **SEC-001**: Do not place credentials, Jenkins initial admin passwords, API tokens, private keys, cookies, or secrets in tracked files.
- **SEC-002**: Bind only local development ports `8080` and `8081`; do not expose public network ports in this plan.
- **GUD-001**: Prefer `docker compose` v2 commands over legacy `docker-compose` commands.
- **GUD-002**: Use `rtk docker` for noisy Docker output when it preserves the needed validation detail; use plain `docker compose` for exact command checks.
- **PAT-001**: Follow the existing repository evidence pattern: tracked configuration in the repository root and generated evidence under ignored `output/` paths only.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Verify the local execution context and prepare the branch without changing runtime configuration.

| Task     | Description                                                                                                                                                                                          | Completed | Date       |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ---------- |
| TASK-001 | Run `rtk read contribution.md` from the repository root and confirm no Plan 02 requirement conflicts with `contribution.md`.                                                                         | ✅        | 2026-06-09 |
| TASK-002 | Run `git status --short --branch` from the repository root and confirm the working tree is clean or contains only intentional Plan 02 changes.                                                       | ✅        | 2026-06-09 |
| TASK-003 | Create or switch to branch `feature/plan-02-docker-compose-foundation` before editing files. If uncommitted unrelated changes exist, stop and report the exact `git status --short --branch` output. | ✅        | 2026-06-09 |
| TASK-004 | Run `docker --version` and `docker compose version`; record the exact versions in `docs/changelog/02-docker-compose-foundation.changelog.md` when the plan is completed.                                       | ✅        | 2026-06-09 |
| TASK-005 | Run `docker info` or `rtk docker info` and confirm Docker Engine is running before attempting to start containers.                                                                                   | ✅        | 2026-06-09 |

### Implementation Phase 2

- GOAL-002: Add the Docker Compose foundation files with deterministic service names, ports, volumes, and network.

| Task     | Description                                                                                                                                                                                                                                                                                                           | Completed | Date       |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ---------- |
| TASK-006 | Create `docker-compose.yml` at the repository root with top-level keys `services`, `volumes`, and `networks`; do not include the obsolete Compose `version` key.                                                                                                                                                      | ✅        | 2026-06-09 |
| TASK-007 | In `docker-compose.yml`, define service `tomcat` with `image: ${TOMCAT_IMAGE:-tomcat:8.5.100-jdk17-temurin}`, `container_name: meta-tomcat`, `ports: ["${TOMCAT_HOST_PORT:-8080}:8080"]`, a long-syntax Docker volume mount with `source: tomcat_webapps` and `target: /usr/local/tomcat/webapps`, and network `meta`.                                  | ✅        | 2026-06-09 |
| TASK-008 | In `docker-compose.yml`, define service `jenkins` with `image: ${JENKINS_IMAGE:-jenkins/jenkins:2.528.1-lts-jdk21}`, `container_name: meta-jenkins`, `ports: ["${JENKINS_HOST_PORT:-8081}:8080"]`, a long-syntax Docker volume mount with `source: jenkins_home` and `target: /var/jenkins_home`, bind mount `.:/workspace/final-project`, and network `meta`. | ✅        | 2026-06-09 |
| TASK-009 | In `docker-compose.yml`, define named volumes `tomcat_webapps: {}` and `jenkins_home: {}` exactly.                                                                                                                                                                                                                    | ✅        | 2026-06-09 |
| TASK-010 | In `docker-compose.yml`, define network `meta` with `name: meta` and `driver: bridge`.                                                                                                                                                                                                                                     | ✅        | 2026-06-09 |
| TASK-011 | Create `.env.example` at the repository root with `COMPOSE_PROJECT_NAME=meta`, `TOMCAT_IMAGE=tomcat:8.5.100-jdk17-temurin`, `JENKINS_IMAGE=jenkins/jenkins:2.528.1-lts-jdk21`, `TOMCAT_HOST_PORT=8080`, and `JENKINS_HOST_PORT=8081`.                                                                 | ✅        | 2026-06-09 |

### Implementation Phase 3

- GOAL-003: Validate Compose syntax and runtime reachability without claiming application deployment is complete.

| Task     | Description                                                                                                                                                                                                             | Completed | Date       |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ---------- |
| TASK-012 | Run `docker compose config` from the repository root and confirm it exits with status `0`.                                                                                                                              | ✅        | 2026-06-09 |
| TASK-013 | Run `docker compose up -d tomcat jenkins` from the repository root and confirm both containers are created or running.                                                                                                  | ✅        | 2026-06-09 |
| TASK-014 | Run `docker compose ps tomcat jenkins` and confirm the published ports include `0.0.0.0:8080->8080/tcp` for Tomcat and `0.0.0.0:8081->8080/tcp` for Jenkins, or the equivalent Docker Desktop localhost binding output. | ✅        | 2026-06-09 |
| TASK-015 | Run `curl -I http://localhost:8080/` and confirm Tomcat responds with an HTTP status line. Accept `200`, `302`, or `404` because this plan validates container reachability, not deployed app content.                  | ✅        | 2026-06-09 |
| TASK-016 | Run `curl -I http://localhost:8081/` and confirm Jenkins responds with an HTTP status line. Accept `200`, `302`, or `403` because first-run Jenkins setup may not be completed yet.                                     | ✅        | 2026-06-09 |
| TASK-017 | Run `docker compose down` without `-v` after validation unless the user explicitly asks to keep containers running.                                                                                                     | ✅        | 2026-06-09 |

### Implementation Phase 4

- GOAL-004: Close out Plan 02 with tracked documentation and exact validation evidence.

| Task     | Description                                                                                                                                                               | Completed | Date       |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ---------- |
| TASK-018 | Create `docs/changelog/02-docker-compose-foundation.changelog.md` after implementation is complete.                                                                                 | ✅        | 2026-06-09 |
| TASK-019 | In `docs/changelog/02-docker-compose-foundation.changelog.md`, document the exact files changed, the selected images, the published ports, the named volumes, and the network name. | ✅        | 2026-06-09 |
| TASK-020 | In `docs/changelog/02-docker-compose-foundation.changelog.md`, list the exact validation commands and observed pass criteria from TASK-012 through TASK-016.                        | ✅        | 2026-06-09 |
| TASK-021 | Run `git diff -- docker-compose.yml .env.example docs/changelog/02-docker-compose-foundation.changelog.md` and review that no generated state or secrets are present.               | ✅        | 2026-06-09 |
| TASK-022 | Run `git status --short --branch` and confirm only intentional Plan 02 files are modified or untracked.                                                                   | ✅        | 2026-06-09 |

## 3. Alternatives

- **ALT-001**: Use host Tomcat or host Jenkins installations. Rejected because `rules/compliance.md` defines the containerized runtime path as the project runtime and local host installs are not project dependencies.
- **ALT-002**: Add Playwright and Gatling services to `docker-compose.yml` in this plan. Rejected because Plan 02 is only the Tomcat/Jenkins foundation and `rules/compliance.md` requires Playwright and Gatling to be handled as later repeatable test flows.
- **ALT-003**: Use legacy `docker-compose` syntax and a top-level Compose `version` key. Rejected because Compose v2 `docker compose` is the preferred workflow and the `version` key is obsolete for current Compose files.
- **ALT-004**: Store Jenkins home and Tomcat webapps under tracked repository directories. Rejected because generated runtime state must remain outside Git-tracked files.

## 4. Dependencies

- **DEP-001**: Docker Engine must be installed and running before `docker compose up -d tomcat jenkins` can pass.
- **DEP-002**: Docker Compose v2 must be available through `docker compose`.
- **DEP-003**: Docker image `tomcat:8.5.100-jdk17-temurin` must be pullable or already present locally.
- **DEP-004**: Docker image `jenkins/jenkins:2.528.1-lts-jdk21` must be pullable or already present locally.
- **DEP-005**: Local ports `8080` and `8081` must be free before starting the services.
- **DEP-006**: The repository `.gitignore` must continue ignoring Docker/Jenkins runtime state and generated evidence paths.

## 5. Files

- **FILE-001**: `docker-compose.yml` is created to define `tomcat`, `jenkins`, `tomcat_webapps`, `jenkins_home`, and `meta`.
- **FILE-002**: `.env.example` is created to document configurable Compose defaults without storing secrets.
- **FILE-003**: `docs/changelog/02-docker-compose-foundation.changelog.md` is created during closeout after implementation and validation are complete.
- **FILE-004**: `contribution.md` is read but not modified.
- **FILE-005**: `.gitignore` is read and modified only if validation proves a generated Docker, Jenkins, or Tomcat state path is not ignored or a required non-secret example configuration file is incorrectly ignored.

## 6. Testing

- **TEST-001**: `docker compose config` must exit with status `0`.
- **TEST-002**: `docker compose up -d tomcat jenkins` must exit with status `0`.
- **TEST-003**: `docker compose ps tomcat jenkins` must show both services created or running and mapped to host ports `8080` and `8081`.
- **TEST-004**: `curl -I http://localhost:8080/` must return an HTTP status line from Tomcat.
- **TEST-005**: `curl -I http://localhost:8081/` must return an HTTP status line from Jenkins.
- **TEST-006**: `git diff -- docker-compose.yml .env.example docs/changelog/02-docker-compose-foundation.changelog.md` must show no secrets, no generated runtime state, and no unrelated changes.

## 7. Risks & Assumptions

- **RISK-001**: Local port `8080` or `8081` may already be in use by host Tomcat, another Jenkins instance, or another development service; stop and report the conflicting process before changing ports.
- **RISK-002**: The exact Docker image tags may require network access to pull if they are not cached locally.
- **RISK-003**: Jenkins first-run setup may require manual unlock/admin configuration after the container starts; this does not block Plan 02 reachability validation.
- **RISK-004**: Mounting the repository into Jenkins gives the Jenkins container access to the working tree; do not place secrets in the repository.
- **ASSUMPTION-001**: Plan 02 implements only the Docker Compose foundation and does not deploy a JSP WAR file.
- **ASSUMPTION-002**: The JSP/Maven app plan sets the Tomcat context path to `/meta/`.
- **ASSUMPTION-003**: Docker Desktop or an equivalent Docker Engine is available on the project machine.

## 8. Related Specifications / Further Reading

- [Project contribution workflow](../../contribution.md)
- [Project compliance rules](../../rules/compliance.md)
- [Repository baseline](../repository-baseline.md)
