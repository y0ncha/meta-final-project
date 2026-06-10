# 05-jenkins-container-ci-cd

## Status

- Result: Completed on 2026-06-10.
- Caveat: The original local validation job read the mounted source-controlled `Jenkinsfile` from `/workspace/final-project/Jenkinsfile` because the repository had no GitHub remote at validation time. The final Jenkins job should use `Pipeline script from SCM` with `https://github.com/y0ncha/meta-final-project.git`.

## Files Changed

- `docs/plans/05-jenkins-container-ci-cd.md`: Expanded and then updated the implementation plan to use shared-volume deployment instead of Docker-socket-based Tomcat deployment.
- `ops/jenkins/Dockerfile`: Added a custom Jenkins image based on `jenkins/jenkins:2.528.1-lts-jdk21` with Maven and curl.
- `docker-compose.yml`: Configured Jenkins to build the custom image, run on `8081`, persist `jenkins_home`, mount the repository at `/workspace/final-project`, and mount `tomcat_webapps` at `/tomcat-webapps`.
- `scripts/deploy-war`: Added `SKIP_BUILD`, `DEPLOY_CHECK_URL`, and `TOMCAT_SHARED_WEBAPPS_DIR` support while preserving the original local Docker Compose deployment path.
- `Jenkinsfile`: Added the source-controlled Declarative Pipeline and updated it to build from the Jenkins SCM workspace through `checkout scm`.
- `docs/jenkins.md`: Added Jenkins setup, schedule, evidence, security, troubleshooting documentation, and the final GitHub SCM repository target.

## Version Snapshot

- Docker: `Docker version 29.4.0, build 9d7ad9f`
- Docker Compose: `Docker Compose version v5.1.2`
- Host Maven: `Apache Maven 3.9.15`
- Host Java: `21.0.9`
- Git: `2.50.1`
- Host curl: `8.7.1`
- Jenkins image: `meta-jenkins:2.528.1-lts-jdk21`
- Jenkins container Maven package observed during image build: `maven 3.9.9-1`

## Validation Performed

- `docker compose config`: passed after Compose edits.
- `sh -n scripts/deploy-war`: passed.
- `docker compose build jenkins`: passed after escalation for Docker build access.
- `docker compose up -d tomcat jenkins`: passed after escalation for Docker daemon access.
- `docker compose exec -T jenkins sh -lc 'command -v mvn && command -v curl && command -v git'`: passed and showed required tools present.
- `docker compose ps tomcat jenkins`: passed and showed both services running.
- `curl -fsS http://localhost:8081/login`: passed outside the sandbox and returned the Jenkins sign-in page.
- `docker compose exec -T jenkins sh -lc 'cd /workspace/final-project && mvn -B clean package'`: passed and produced `target/meta.war`.
- `test -f target/meta.war`: passed.
- `docker compose exec -T jenkins sh -lc 'cd /workspace/final-project && SKIP_BUILD=1 TOMCAT_SHARED_WEBAPPS_DIR=/tomcat-webapps DEPLOY_CHECK_URL=http://tomcat:8080/meta/ ./scripts/deploy-war'`: passed.
- `docker compose exec -T jenkins sh -lc 'curl -fsS http://tomcat:8080/meta/ >/dev/null'`: passed.
- `curl -f http://localhost:8080/meta/`: passed and returned the JSP application HTML.
- Jenkins authenticated API configured job `meta-container-ci-cd` from the mounted `Jenkinsfile`.
- Jenkins manual build `#1`: passed with result `SUCCESS`.
- Jenkins scheduled timer build `#2`: passed with result `SUCCESS`.
- Jenkins job config contains schedule `H/5 * * * *`.

## Evidence

- `output/jenkins/05-manual-build-1-console.log`: manual build `#1`, result `SUCCESS`; includes `mvn -B clean package`, `./scripts/deploy-war`, and `curl -fsS http://tomcat:8080/meta/`.
- `output/jenkins/05-scheduled-build-2-console.log`: scheduled timer build `#2`, result `SUCCESS`; includes `Started by timer` and the availability check.
- `output/jenkins/05-meta-container-ci-cd-config.xml`: Jenkins job configuration snapshot, including the cron trigger.
- `output/jenkins/05-meta-container-ci-cd-builds.json`: Jenkins build API snapshot for the validated job.

## Notes

- Follow-up correction on 2026-06-10: The Jenkins trigger design was tightened after re-reading the assignment PDF. Timer-triggered runs now provide only the five-minute availability check, while manual or SCM-triggered runs perform checkout, build, deploy, verification, and optional Playwright/Gatling stages.
- The initial Docker-socket approach for Tomcat deployment was rejected by the approval layer when recreating Jenkins as root with `/var/run/docker.sock` mounted. The implementation was changed to the shared-volume deployment path.
- Follow-up correction on 2026-06-10: Plan 06 later adds `/var/run/docker.sock` to Jenkins only for disposable browser test containers. Tomcat deployment remains shared-volume based.
- The user removed the previous Compose containers/network before final validation; `docker compose up -d tomcat jenkins` recreated the required runtime.
- `git status --short --branch` also shows an unrelated `.env.example` one-line comment diff. It is not required by Plan 05 and was left untouched.
- Generated evidence should remain under ignored `output/` paths.

## 2026-06-10 Jenkins Docker Tooling And Report Publishing Follow-Up

- Updated `ops/jenkins/Dockerfile` to use Docker's official Debian apt repository and install `docker-ce-cli` plus `docker-compose-plugin`.
- Added image-managed Jenkins plugins with `jenkins-plugin-cli --plugins "docker-workflow htmlpublisher gatling"`.
- Updated `Jenkinsfile` post-build behavior to keep archiving `output/**/*`, publish Playwright JUnit XML, publish Playwright HTML, and publish Gatling HTML/PDF reports when those files exist.
- Left `gatlingArchive()` deferred until Plan 08 validates a real Gatling output layout compatible with the Jenkins Gatling plugin.

Validation:

- `docker compose config`: passed.
- `sh -n scripts/run-playwright-container`: passed.
- `git diff --check`: passed.
- `docker compose build jenkins`: passed; `jenkins-plugin-cli` completed with `Done`.
- `docker compose up -d tomcat jenkins`: passed; Jenkins was recreated from the rebuilt image.
- `docker compose exec -T jenkins docker --version`: passed with `Docker version 29.5.3, build d1c06ef`.
- `docker compose exec -T jenkins docker compose version`: passed with `Docker Compose version v5.1.4`.
- `docker compose exec -T jenkins jenkins-plugin-cli --version`: passed with `2.13.2`.
- `docker compose exec -T jenkins sh -lc 'for p in docker-workflow htmlpublisher gatling; do if [ -f /var/jenkins_home/plugins/$p.jpi ] || [ -f /var/jenkins_home/plugins/$p.hpi ]; then echo "$p present"; else echo "$p missing"; exit 1; fi; done'`: passed for all three plugins.
- Jenkins declarative linter API for `/workspace/final-project/Jenkinsfile`: passed with `Jenkinsfile successfully validated.`
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md`: passed with `pass=70`, `warn=0`, `manual=9`, `fail=0`.

Live Jenkins build note:

- The current `meta-container-ci-cd` job is configured as `org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition` against `https://github.com/y0ncha/meta-final-project.git`. A live non-timer build before committing would fetch the GitHub version of `Jenkinsfile`, not these uncommitted local edits, so the local Jenkinsfile was validated through the Jenkins declarative linter instead.
