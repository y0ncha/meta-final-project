# 02-docker-compose-foundation

## Completed Plan

- Plan: `.agents/plans/02-docker-compose-foundation.md`
- Completed: 2026-06-09

## What Changed

- Added `docker-compose.yml` with two services:
  - `tomcat` uses `tomcat:8.5.100-jdk17-temurin`, container name `meta-tomcat`, and publishes `8080:8080`.
  - `jenkins` uses `jenkins/jenkins:2.528.1-lts-jdk21`, container name `meta-jenkins`, and publishes `8081:8080`.
- Added persistent Docker-managed named volumes using explicit long syntax and no host filesystem paths:
  - `tomcat_webapps` mounted at container target `/usr/local/tomcat/webapps`.
  - `jenkins_home` mounted at container target `/var/jenkins_home`.
- Added shared Compose bridge network `meta`.
- Mounted the repository root into Jenkins at `/workspace/final-project` for later build/deploy scripts.
- Added `.env.example` with configurable defaults for `COMPOSE_PROJECT_NAME`, images, and host ports.
- Added a narrow `.gitignore` exception for `.env.example` so the non-secret example file is visible to Git while real `.env` files stay ignored.
- Updated the Compose project and container naming to use the assignment-aligned `meta`/`meta-*` names while keeping Docker-managed named volumes.
- Removed host Tomcat/Jenkins fallback assumptions from `contribution.md`; the project runtime is container-only for Tomcat and Jenkins.

## Why

Plan 02 creates the project runtime foundation required by `contribution.md`: Tomcat owns local port `8080`, Jenkins owns local port `8081`, both tools run in containers, and generated runtime state stays in Docker-managed volumes rather than tracked repository directories.

## Validation

- `rtk read contribution.md`: confirmed Plan 02 does not conflict with active project constraints.
- `git status --short --branch`: before implementation reported branch `feature/plan-02-docker-compose-foundation` with the existing untracked `plan/` directory from plan creation.
- `docker --version`: returned `Docker version 29.4.0, build 9d7ad9f`.
- `docker compose version`: returned `Docker Compose version v5.1.2`.
- `docker info`: required host-level Docker socket access; returned Docker context `orbstack`, server version `29.4.0`, `Containers: 0`, and `Images: 9` before startup.
- `docker compose config`: exited `0` and resolved services `tomcat` and `jenkins`, published ports `8080` and `8081`, volumes `tomcat_webapps` and `jenkins_home`, network `meta`, and container names `meta-tomcat` and `meta-jenkins`.
- `docker compose up -d tomcat jenkins`: required host-level Docker socket access; pulled `tomcat:8.5.100-jdk17-temurin` and `jenkins/jenkins:2.528.1-lts-jdk21`, then started the configured Tomcat and Jenkins containers.
- `docker compose ps tomcat jenkins`: required host-level Docker socket access; showed Tomcat mapped as `0.0.0.0:8080->8080/tcp` and Jenkins mapped as `0.0.0.0:8081->8080/tcp`.
- `curl -I http://localhost:8080/`: sandboxed curl could not reach the OrbStack-published localhost port, but host-level curl returned `HTTP/1.1 404`, which is accepted by the plan because no JSP app is deployed yet.
- `curl -I http://localhost:8081/`: sandboxed curl could not reach the OrbStack-published localhost port, but host-level curl returned `HTTP/1.1 403 Forbidden`, `X-Jenkins: 2.528.1`, which is accepted by the plan because Jenkins first-run setup is not part of Plan 02.
- `docker compose down`: required host-level Docker socket access; stopped and removed the two containers without `-v`, preserving Docker volumes.
- `git status --short --branch`: after adding the `.gitignore` exception, reported only intentional Plan 02 files as modified or untracked.

## Remaining Risks And Follow-Up

- Jenkins first-run unlock/admin setup is still manual follow-up for later Jenkins plans.
- The JSP application is not deployed yet, so Tomcat root returning `404` is expected for this plan.
- Compose now resolves the runtime project name as `meta`, uses explicit container names `meta-tomcat` and `meta-jenkins`, and creates/uses the bridge network named `meta`.
- Host-level Docker access is needed for commands that talk to OrbStack's Docker socket in this managed Codex environment.
