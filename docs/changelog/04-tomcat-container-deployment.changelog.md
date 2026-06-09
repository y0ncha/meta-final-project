# Plan 04 Changelog: Tomcat Container Deployment

## Summary

Implemented repeatable deployment of the Maven WAR into the containerized Tomcat runtime. The deployment command is `./scripts/deploy-war`; it builds `target/meta.war`, ensures the `tomcat` Compose service is running, removes stale `meta` deployment artifacts inside the container, copies the WAR into Tomcat `webapps`, and waits for `http://localhost:8080/meta/`.

## Files Changed

- `scripts/deploy-war`: Added executable deployment script.
- `docs/plans/04-tomcat-container-deployment.md`: Updated execution state for completed implementation tasks.
- `docs/changelog/04-tomcat-container-deployment.changelog.md`: Added this evidence log.

## Observed Tool Versions

- Docker: `Docker version 29.4.0, build 9d7ad9f`
- Docker Compose: `Docker Compose version v5.1.2`
- Maven: `Apache Maven 3.9.15 (98b2cdbfdb5f1ac8781f537ea9acccaed7922349)`
- Java: `java version "21.0.9" 2025-10-21 LTS`

## Deployment Configuration

- Docker Compose service: `tomcat`
- Tomcat image: `tomcat:8.5.100-jdk17-temurin`
- Published port: `0.0.0.0:8080->8080/tcp`
- Docker volume: `tomcat_webapps`
- Container WAR path: `/usr/local/tomcat/webapps/meta.war`
- Container expanded app path: `/usr/local/tomcat/webapps/meta`
- Local app URL: `http://localhost:8080/meta/`

## Validation Evidence

- `docker compose config`: passed and resolved service `tomcat` to image `tomcat:8.5.100-jdk17-temurin`, published port `8080`, and volume `meta_tomcat_webapps`.
- `./scripts/deploy-war`: passed with final output `Deployed URL: http://localhost:8080/meta/`.
- `test -x scripts/deploy-war`: passed.
- `test -f target/meta.war`: passed.
- `docker compose ps tomcat`: showed `meta-tomcat`, image `tomcat:8.5.100-jdk17-temurin`, command `catalina.sh run`, status `Up`, and ports `0.0.0.0:8080->8080/tcp` and `[::]:8080->8080/tcp`.
- `docker compose exec -T tomcat sh -lc 'test -f /usr/local/tomcat/webapps/meta.war'`: passed.
- `docker compose exec -T tomcat sh -lc 'test -d /usr/local/tomcat/webapps/meta'`: passed.
- `curl -f http://localhost:8080/meta/`: passed outside the sandbox and returned the JSP HTML.
- `curl -s http://localhost:8080/meta/`: returned HTML containing `DevOps Final Project`, `About this app`, `nameInput`, and `submitButton`.
- Browser automation verified the tab URL as `http://localhost:8080/meta/` and page title as `DevOps Final Project`.
- `git diff -- scripts/deploy-war docs/changelog/04-tomcat-container-deployment.changelog.md docs/plans/04-tomcat-container-deployment.md | rtk diff -`: passed and showed only the intended deployment script, plan, and changelog changes.

## Screenshot Evidence

- Screenshot path: `output/screenshots/04-tomcat-meta-local.png`
- Git tracking status: ignored by `.gitignore` through `output/**`.
- Evidence classification: supplemental local evidence, not final submission-grade address-bar evidence.
- Evidence caveat: the saved screenshot captures the rendered browser viewport. The in-app browser screenshot API does not include browser chrome, and the host `screencapture -x output/screenshots/04-tomcat-meta-local.png` attempt failed with `could not create image from display`, so the address-bar URL is proven by browser automation URL state and HTTP validation instead of appearing inside this screenshot.
- Final submission action: capture a normal manual browser screenshot with `http://localhost:8080/meta/` visible in the address bar before sending the final assignment package.

## Environment Notes

- The first sandboxed `./scripts/deploy-war` run built the WAR successfully but could not access the Docker socket.
- The elevated `./scripts/deploy-war` run completed successfully.
- Sandboxed `curl` could not reach `localhost:8080`; elevated host-network `curl` succeeded.

## Code Review Follow-Up

- Requested Superpowers code review before merge.
- Fixed reviewer finding about invalid RTK diff evidence by replacing the checklist command with `git diff -- ... | rtk diff -`.
- Fixed reviewer finding about unvalidated numeric inputs by validating `DEPLOY_TIMEOUT_SECONDS` and `TOMCAT_HOST_PORT`.
- Fixed reviewer finding about shell-string cleanup by passing `TOMCAT_WEBAPPS_DIR` and `TOMCAT_CONTEXT` as positional arguments to the inner container shell.
- Clarified that `output/screenshots/04-tomcat-meta-local.png` is supplemental evidence and that the final submission still needs a manual address-bar screenshot.
- Re-ran `./scripts/deploy-war` after fixes and confirmed it still exits with status `0`.
