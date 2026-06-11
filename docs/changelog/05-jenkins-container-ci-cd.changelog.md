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
- `docker compose exec -T jenkins sh -lc 'cd /workspace/final-project && mvn -B clean package'`: passed and produced `target/MeTA.war`.
- `test -f target/MeTA.war`: passed.
- `docker compose exec -T jenkins sh -lc 'cd /workspace/final-project && SKIP_BUILD=1 TOMCAT_SHARED_WEBAPPS_DIR=/tomcat-webapps DEPLOY_CHECK_URL=http://tomcat:8080/MeTA/ ./scripts/deploy-war'`: passed.
- `docker compose exec -T jenkins sh -lc 'curl -fsS http://tomcat:8080/MeTA/ >/dev/null'`: passed.
- `curl -f http://localhost:8080/MeTA/`: passed and returned the JSP application HTML.
- Jenkins authenticated API configured job `meta-container-ci-cd` from the mounted `Jenkinsfile`.
- Jenkins manual build `#1`: passed with result `SUCCESS`.
- Jenkins scheduled timer build `#2`: passed with result `SUCCESS`.
- Jenkins job config contains schedule `H/5 * * * *`.

## Evidence

- `output/jenkins/05-manual-build-1-console.log`: manual build `#1`, result `SUCCESS`; includes `mvn -B clean package`, `./scripts/deploy-war`, and `curl -fsS http://tomcat:8080/MeTA/`.
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

## 2026-06-10 Jenkins Docker Pipeline Runner Refactor Follow-Up

- Rewrote `docs/plans/05-jenkins-container-ci-cd.md` in place for the Docker Pipeline follow-up and marked it completed after validation.
- Removed the profiled Compose runner-service model from `docker-compose.yml`; `docker compose config --services` now returns only `jenkins` and `tomcat`.
- Updated `Jenkinsfile` so Playwright, Gatling max-limit, Gatling load, Gatling stress, and Gatling PDF export run through Jenkins Docker Pipeline containers using `docker.image(...).inside(...)`.
- Added `Docker Pipeline Preflight` to verify Docker CLI, Docker Compose CLI, Docker daemon access, Playwright-image workspace access, and Tomcat reachability before test containers run.
- Reworked `scripts/run-playwright-container`, `scripts/run-gatling-container`, `scripts/export-gatling-pdfs`, and `scripts/capture-har` so local runs use direct `docker run` and Jenkins uses explicit Docker Pipeline mode flags instead of nested Compose runner services.
- Updated Jenkins, Playwright, Gatling, HAR, and related plan documentation to remove current-runner references to profiled Compose services.

Validation:

- `docker compose config --quiet`: passed.
- `docker compose config --services`: passed with `jenkins` and `tomcat` only.
- `sh -n scripts/run-playwright-container scripts/run-gatling-container scripts/run-gatling-max-limit scripts/run-gatling-load-5m scripts/run-gatling-stress-5m scripts/export-gatling-pdfs scripts/capture-har`: passed.
- `git diff --check`: passed.
- Stale-reference scan for removed runner service names and profiled Compose runner commands across changed docs/scripts: passed with no matches.
- `docker compose build jenkins`: passed after Docker daemon escalation; image layers were cached.
- `docker compose up -d tomcat jenkins`: passed.
- `docker compose up -d --force-recreate jenkins`: passed and refreshed the bind mount used by Docker Pipeline-equivalent validation containers.
- `docker compose exec -T jenkins docker --version`: passed with `Docker version 29.5.3, build d1c06ef`.
- `docker compose exec -T jenkins docker compose version`: passed with `Docker Compose version v5.1.4`.
- `docker compose exec -T jenkins docker info`: passed and confirmed Jenkins can reach the Docker daemon.
- `docker compose exec -T jenkins sh -lc 'for p in docker-workflow htmlpublisher gatling; do if [ -f /var/jenkins_home/plugins/$p.jpi ] || [ -f /var/jenkins_home/plugins/$p.hpi ]; then echo "$p present"; else echo "$p missing"; exit 1; fi; done'`: passed for all three plugins.
- Docker Pipeline-equivalent Playwright smoke with `--network meta --volumes-from meta-jenkins -w /workspace/final-project`: passed; the container printed `/workspace/final-project`, found `Jenkinsfile`, and reached `http://tomcat:8080/MeTA/`.
- Docker Pipeline-equivalent Playwright run: passed with `PLAYWRIGHT_DOCKER_PIPELINE=1 ./scripts/run-playwright-container`; one Chromium test passed and evidence was written under `output/playwright/`.
- Docker Pipeline-equivalent Gatling load run: passed after one clean rerun with `3000` OK, `0` KO, p95 `17 ms`, and normalized report `output/gatling/load-5m/index.html`.
- Docker Pipeline-equivalent Gatling stress run: passed with `16500` OK, `0` KO, p95 `11 ms`, and normalized report `output/gatling/stress-5m/index.html`.
- Docker Pipeline-equivalent Gatling PDF export: passed with `GATLING_PDF_DOCKER_PIPELINE=1 GATLING_PDF_REQUIRE_ALL=false ./scripts/export-gatling-pdfs`; PDFs were generated for max-limit, load, and stress reports that existed.
- Jenkins declarative linter for `/workspace/final-project/Jenkinsfile`: passed with `Jenkinsfile successfully validated.`
- `test -s output/playwright/junit.xml && test -s output/playwright/playwright-report/index.html && test -s output/gatling/load-5m/index.html && test -s output/gatling/stress-5m/index.html && test -s output/gatling/load-5m/load-5m-report.pdf && test -s output/gatling/stress-5m/stress-5m-report.pdf`: passed.
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md`: passed with `pass=70`, `warn=0`, `manual=9`, `fail=0`.

Debug notes:

- A first Docker Pipeline-equivalent Gatling run completed with healthy Gatling metrics but the wrapper exited after report generation because the disposable container inherited a stale, truncated copy of `scripts/run-gatling-container` through `--volumes-from meta-jenkins`.
- Recreating `meta-jenkins` refreshed the inherited bind mount. After that, the Gatling image saw the complete `5326` byte wrapper and BusyBox `sh -n` passed.
- A subsequent load run normalized the report but failed the p95 assertion after a local timing spike. A clean rerun passed with p95 `17 ms`; no thresholds were relaxed and no performance numbers were invented.

Remaining risks and follow-up:

- The validation used Docker Pipeline-equivalent `docker run` commands and Jenkins declarative linter because the SCM-backed `meta-container-ci-cd` job would fetch committed GitHub content, not uncommitted local edits.
- `AGENTS.md` contains a user-side uncommitted change that says not to run Gatling tests directly. It was discovered after the Gatling validation commands above had already run, was left untouched, and no further Gatling tests were run after discovery.

## 2026-06-10 SCM Workspace Source Correction

- Updated `Jenkinsfile` so non-timer `checkout scm` records `CHECKED_OUT_COMMIT`.
- Updated Docker Pipeline args for Playwright, Gatling, and Gatling PDF export to use working directory `env.WORKSPACE` instead of the legacy `/workspace/final-project` bind mount.
- Updated `Docker Pipeline Preflight` to prove the disposable container is in the Jenkins SCM workspace, is inside a Git worktree, matches `CHECKED_OUT_COMMIT`, and can still reach `http://tomcat:8080/MeTA/`.
- Updated Jenkins, Playwright, Plan 05, and Plan 08 documentation so current Docker Pipeline execution is described as SCM-workspace based. Historical `/workspace/final-project` validation notes remain as past evidence only.

Validation:

- `git diff --check`: passed.
- `sh -n scripts/run-playwright-container scripts/run-gatling-container scripts/run-gatling-max-limit scripts/run-gatling-load-5m scripts/run-gatling-stress-5m scripts/export-gatling-pdfs scripts/capture-har`: passed.
- `docker compose config --quiet`: passed.
- Jenkins declarative linter for `/workspace/final-project/Jenkinsfile`: passed with `Jenkinsfile successfully validated.`
- Docker Pipeline-equivalent Playwright smoke with `--network meta --volumes-from meta-jenkins -w /var/jenkins_home/workspace/meta-container-ci-cd`: passed; the container printed `/var/jenkins_home/workspace/meta-container-ci-cd`, confirmed a Git worktree, matched commit `36d246f9e7d25a7c6602541af51d343091a6d863`, and reached Tomcat.
- Active stale-reference scan across `Jenkinsfile`, current docs, and plans for Docker Pipeline `/workspace/final-project` working-directory references: passed with no matches.
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md`: passed with `pass=70`, `warn=0`, `manual=9`, `fail=0`.

Remaining risks and follow-up:

- Gatling validation was not run for this correction because `AGENTS.md` requires asking the user to run Gatling commands directly.

## 2026-06-10 Docker Pipeline Preflight Quote Fix

- Updated `Jenkinsfile` so the Docker Pipeline preflight HTTP probe runs Node from a single-quoted heredoc instead of `sh 'node -e "..."'`.
- Root cause: Groovy and shell quote handling removed the JavaScript quotes around `http` and `error`, so Jenkins executed `require(http)` and `.on(error)` and Node failed with `TypeError [ERR_INVALID_ARG_TYPE]`.

Validation:

- `if rg -n "sh 'node -e \\\"" Jenkinsfile; then exit 1; fi`: failed before the fix and passed after the fix.
- `awk '/node <<'\\''NODE'\\''/{flag=1;next}/^NODE/{flag=0}flag' Jenkinsfile | node --check`: passed.
- `git diff --check`: passed.
- `docker compose exec -T jenkins sh -lc '. /var/jenkins_home/codex-automation.env && curl -fsS -u "$JENKINS_USER:$JENKINS_TOKEN" -X POST -F "jenkinsfile=</workspace/final-project/Jenkinsfile" "http://localhost:8080/pipeline-model-converter/validate"'`: passed with `Jenkinsfile successfully validated.`
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md`: passed with no failures.

Remaining risks and follow-up:

- No Gatling validation was run because `AGENTS.md` requires asking the user before direct Gatling execution.

## 2026-06-10 Availability Stage Visibility Follow-Up

- Merged the old non-timer `Verify Tomcat` curl check into `Availability Check` so availability is visible in both SCM/manual and timer-triggered Jenkins runs.
- Kept heavy stages gated away from `TimerTrigger`: checkout, evidence cleanup, Maven build, Tomcat deploy, Docker Pipeline preflight, Playwright, Gatling max-limit, Gatling load, and Gatling stress do not run on the old five-minute monitor schedule.
- Updated `docs/jenkins.md` and `docs/plans/05-jenkins-container-ci-cd.md` so the documented stage list and trigger behavior match the Jenkinsfile.

Validation:

- `if rg -q "stage\\('Verify Tomcat'\\)" Jenkinsfile; then printf 'FAIL: Verify Tomcat stage still exists\\n'; exit 1; fi`: failed before the fix and passed after the fix.
- `if ! rg -q "stage\\('Availability Check'\\)" Jenkinsfile; then printf 'FAIL: Availability Check stage missing\\n'; exit 1; fi`: passed.
- Timer-gate scan confirmed every heavy stage still contains `triggeredBy 'TimerTrigger'` under a `not` condition.
- `git diff --check`: passed.
- `docker compose exec -T jenkins sh -lc '. /var/jenkins_home/codex-automation.env && curl -fsS -u "$JENKINS_USER:$JENKINS_TOKEN" -X POST -F "jenkinsfile=</workspace/final-project/Jenkinsfile" "http://localhost:8080/pipeline-model-converter/validate"'`: passed with `Jenkinsfile successfully validated.`
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md`: passed with `pass=70`, `warn=0`, `manual=9`, `fail=0`.

Remaining risks and follow-up:

- This validates the source-controlled Jenkinsfile shape locally. The live SCM-backed Jenkins job will only execute this change after it is committed and the job checks out the updated branch.

## 2026-06-10 Superseded Availability Split

- Instructor confirmation superseded the trigger-aware availability design above.
- Plan 09 now owns monitoring through separate Jenkins Freestyle job `meta-monitoring` with shell command `./scripts/run-monitoring-check`.
- Plan 05 now owns only the CI/CD job `meta-container-ci-cd`: checkout, build, deploy, `Verify Tomcat`, Docker Pipeline preflight, Playwright, Gatling, and report publishing.

## 2026-06-11 CI/CD Stage Graph Cleanup Follow-Up

- Removed the separate visible `Checkout` and `Prepare Evidence Workspace` stages from `Jenkinsfile`.
- Kept `skipDefaultCheckout(true)` and moved explicit `checkout scm`, `CHECKED_OUT_COMMIT` capture, and old generated evidence cleanup into the beginning of `Build WAR`.
- Updated `docs/jenkins.md` to explain the CI/CD flow as pre-build, visible stages, and post-build instead of presenting checkout and evidence cleanup as assignment-facing stages.

Validation:

- Old visible setup stage scan: passed; `stage('Checkout')` and `stage('Prepare Evidence Workspace')` are no longer present.
- `git diff --check`: passed.
- Jenkins declarative linter for `/workspace/final-project/Jenkinsfile`: passed with `Jenkinsfile successfully validated.`
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md`: passed with `pass=71`, `warn=0`, `manual=9`, `fail=0`.

## 2026-06-11 Pre/Post Block Correction Follow-Up

- Restored a separate visible `Pre-build` stage in `Jenkinsfile`.
- Moved `checkout scm`, `CHECKED_OUT_COMMIT` capture, and generated evidence cleanup out of `Build WAR` and back into `Pre-build`.
- Kept post-build work in Declarative Pipeline `post { always { ... } }` instead of converting it to a normal final stage, so report generation, artifact archiving, JUnit publishing, and HTML publishing still run after failed visible stages.
- Updated `docs/jenkins.md` to show `Pre-build` as stage 1 and to keep `Post-build` documented as the real Jenkins `post` block.

Validation:

- `git diff --check`: passed.
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md`: passed with `pass=71`, `warn=0`, `manual=9`, `fail=0`.
- Jenkins declarative linter: not rerun in this follow-up because `curl -fsS -I http://localhost:8081/login` could not connect to local Jenkins.

## 2026-06-11 Preflight Naming And Placement Follow-Up

- Moved Docker CLI, Compose CLI, and Docker daemon readiness checks from `Docker Pipeline Preflight` into `Pre-build`.
- Renamed the remaining `Docker Pipeline Preflight` stage to `Container Test Preflight`.
- Kept the disposable Playwright-image workspace, commit identity, and Tomcat reachability checks after deployment. Moving those checks into `Pre-build` would validate the test container against an old Tomcat deployment instead of the WAR produced by the current build.
- Updated `docs/jenkins.md` and `scripts/generate-pipeline-report` so project-facing language says `Post-build`, while documenting that Jenkins Stage View may still show `Declarative: Post Actions` for the real Declarative `post` block.

Validation:

- `git diff --check`: passed.
- `sh -n scripts/generate-pipeline-report`: passed.
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md`: passed with `pass=71`, `warn=0`, `manual=9`, `fail=0`.
- Jenkins declarative linter: not rerun in this follow-up because local Jenkins was not reachable in the prior check at `http://localhost:8081/login`.

## 2026-06-11 Stage Ownership Follow-Up

- Renamed `Pre-build` to `Pre Actions`.
- Removed the standalone `Container Test Preflight` stage from `Jenkinsfile`.
- Moved Playwright-image workspace, checked-out commit, and Tomcat reachability checks into `Playwright Functional Test`.
- Added lightweight workspace and runner-script checks inside each Gatling container stage before the stage invokes `scripts/run-gatling-container`.
- Updated `docs/jenkins.md`, `docs/plans/05-jenkins-container-ci-cd.md`, and `scripts/generate-pipeline-report` so the pipeline graph and plan requirements document validation under the stage that owns the relevant container.
- Updated `tests/scripts/test-generate-pipeline-report.sh` so the report-rendering test expects the renamed `Pre Actions` stage instead of the removed `Checkout` stage.

Validation:

- `git diff --check`: passed.
- `sh -n scripts/generate-pipeline-report`: passed.
- `sh tests/scripts/test-generate-pipeline-report.sh`: passed.
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md`: passed with `pass=71`, `warn=0`, `manual=9`, `fail=0`.
- Active stage-name scan: passed; `Jenkinsfile` now has `stage('Pre Actions')` and no `stage('Container Test Preflight')`.
- Code-review follow-up: fixed stale plan requirements and task text, fixed stale Jenkins Gatling-stage wording, and fixed the report-rendering test expectation.
- `docker compose exec -T jenkins sh -lc '. /var/jenkins_home/codex-automation.env && curl -fsS -u "$JENKINS_USER:$JENKINS_TOKEN" -X POST -F "jenkinsfile=</workspace/final-project/Jenkinsfile" "http://localhost:8080/pipeline-model-converter/validate"'`: passed with `Jenkinsfile successfully validated.`
