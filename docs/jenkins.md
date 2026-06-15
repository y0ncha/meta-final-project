# Jenkins Container CI/CD

## Runtime

- Jenkins URL: `http://localhost:8081/`
- Tomcat host URL: `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Tomcat internal Docker URL: `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Jenkins Compose service: `jenkins`
- Tomcat Compose service: `tomcat`
- Jenkins home volume: `jenkins_home`
- Tomcat webapps volume: `tomcat_webapps`
- Jenkins CI/CD SCM workspace: the `meta-container-ci-cd` workspace created from the GitHub repository checkout.
- Jenkins monitoring workspace: the `meta-monitoring` workspace that writes monitoring evidence.
- Legacy local validation mount: `/workspace/final-project`
- Jenkins Tomcat deployment mount: `/tomcat-webapps`
- Jenkins Docker socket mount: `/var/run/docker.sock`
- Jenkins Docker tooling: `docker-ce-cli` and `docker-compose-plugin` from Docker's Debian apt repository.
- Jenkins image-managed plugins: `docker-workflow`, `htmlpublisher`, and `gatling`.
- GitHub repository: `https://github.com/y0ncha/meta-final-project.git`

## Manual Jenkins Setup

1. Start the stack with `docker compose up -d tomcat jenkins`.
2. Open `http://localhost:8081/`.
3. Unlock Jenkins with the initial admin password from `/var/jenkins_home/secrets/initialAdminPassword`.
4. Create the Jenkins admin user.
5. Confirm required plugins are installed by the custom Jenkins image:
   - `Git`
   - `Pipeline`
   - `Pipeline: SCM Step`
   - `Pipeline: Declarative`
   - `Pipeline: Stage View`
   - `Docker Pipeline` (`docker-workflow`)
   - `HTML Publisher` (`htmlpublisher`)
   - `Gatling` (`gatling`)

## Jenkins Jobs

This project uses one source-controlled Jenkins Pipeline job for CI/CD and one Jenkins Freestyle job for monitoring because the instructor confirmed that monitoring should be separate from the CI/CD build/deploy/test job.

### CI/CD Job

- Job name: `meta-container-ci-cd`
- Job type: `Pipeline`
- Script path: `Jenkinsfile`
- Purpose: build the WAR, deploy to Tomcat, verify Tomcat, run Playwright, run Gatling, and publish reports.

Final GitHub-backed setup:

- Definition: `Pipeline script from SCM`
- SCM: `Git`
- Repository URL: `https://github.com/y0ncha/meta-final-project.git`
- Credentials: leave empty for a public repository. If the repository is private, create Jenkins credentials and reference only the credentials ID.
- Branch specifier: use the branch being defended or reviewed, for example `*/feature/09-monitoring-and-jenkins-schedule`. Switch to `*/main` after the branch is merged into the default branch.
- Script path: `Jenkinsfile`
- The source-controlled Jenkinsfile includes `pollSCM('* * * * *')` so a local Jenkins instance can detect pushed GitHub changes every minute without needing an inbound GitHub webhook.
- If Jenkins is exposed through a stable public URL, prefer a GitHub webhook that triggers this same Pipeline job on push or merge events. Keep `pollSCM` as the local defense fallback unless the webhook evidence is already captured.

### Monitoring Job

- Job name: `meta-monitoring`
- Job type: `Freestyle project`
- Purpose: run only the five-minute monitoring check.
- Source code management: `Git`
- Repository URL: `https://github.com/y0ncha/meta-final-project.git`
- Credentials: leave empty for a public repository. If the repository is private, use the same read-only GitHub credentials policy as the CI/CD job.
- Branch specifier: use the same branch as `meta-container-ci-cd` while validating a branch, then switch to `*/main` after merge.
- Trigger: `Build periodically`
- Schedule: `H/5 * * * *`
- Build step: `Execute shell`
- Build command: `./scripts/run-monitoring-check`
- Post-build action: archive artifacts with pattern `output/monitoring/**/*`.
- The job checks `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` through the script, writes `output/monitoring/latest-check.txt`, and archives that monitoring evidence.

Previous local validation setup used for Plan 05:

- The first local validation job was created with Jenkins' authenticated script API and read `/workspace/final-project/Jenkinsfile` from the repository mount because the repository did not have a GitHub remote yet.
- Do not use that mounted-script job as final evidence after the GitHub repository exists.
- The final Jenkins job must load `Jenkinsfile` from SCM. At the start of `Pre Actions`, it then runs `checkout scm`, so build, deploy, and CI/CD evidence come from the GitHub branch selected in the job configuration.

## Pipeline Flow

The source-controlled `Jenkinsfile` is only for the `meta-container-ci-cd` job. It does not contain the five-minute monitoring schedule.

### Pre Actions

The `Pre Actions` stage runs the setup work that must happen before Maven runs:

- `checkout scm`: fetches the repository and branch configured in the Jenkins Pipeline job.
- `CHECKED_OUT_COMMIT`: records the exact Git commit so disposable Docker test containers can prove they are testing the same source revision.
- Evidence cleanup: removes generated `output/gatling`, `output/playwright`, `output/har`, and `output/reports` directories so published artifacts cannot come from a previous workspace run.
- Docker readiness checks: verifies Docker CLI access, Compose CLI access, and Docker daemon access before the build spends time producing test artifacts.

The pipeline keeps `skipDefaultCheckout(true)` so Jenkins does not perform a hidden checkout before the visible CI/CD flow starts. This keeps checkout timing explicit and lets later test stages verify that their disposable containers are using the same checked-out commit.

### Visible Stages

1. `Pre Actions`: Checks out the configured SCM branch, records `CHECKED_OUT_COMMIT`, cleans old generated evidence directories, and confirms Jenkins can reach Docker before Maven runs.
2. `Build WAR`: Runs `mvn -B clean package` and archives `target/yonatan-csasznik-yoed-halberstam-niv-levin.war`. Maven turns the JSP application into the WAR file Tomcat can deploy; archiving the WAR gives Jenkins build evidence and a traceable artifact.
3. `Deploy Tomcat`: Runs `./scripts/deploy-war` with `SKIP_BUILD=1`, `TOMCAT_SHARED_WEBAPPS_DIR=/tomcat-webapps`, and `DEPLOY_CHECK_URL="$DEPLOY_CHECK_URL"`. This reuses the repository deployment script, avoids rebuilding the WAR twice, writes the WAR into the shared Tomcat webapps volume, and waits until Tomcat serves the deployed app.
4. `Verify Tomcat`: Runs `curl -fsS "$APP_BASE_URL" >/dev/null` after deployment. It proves the deployed WAR is reachable through Tomcat at `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` from inside the Docker network.
5. `Playwright Functional Test`: Runs only when `scripts/run-playwright-container` exists. Jenkins starts the official Playwright image through Docker Pipeline, verifies workspace mapping, verifies the container sees the same checked-out commit, verifies Tomcat reachability from inside the Playwright image, then calls `PLAYWRIGHT_DOCKER_PIPELINE=1 ./scripts/run-playwright-container` so evidence is written under the checked-out SCM workspace.
6. `Gatling Max Limit`: Runs only when `scripts/run-gatling-max-limit` exists and build parameter `RUN_GATLING_MAX_LIMIT=true`. Jenkins starts the Gatling image through Docker Pipeline, verifies the Gatling container workspace, and calls `GATLING_DOCKER_PIPELINE=1 GATLING_RUN_TYPE=max-limit ./scripts/run-gatling-max-limit`. The wrapper runs one bounded, targeted users/sec arrival-rate staircase from `GATLING_MAX_START_USERS_PER_SEC` through `GATLING_MAX_END_USERS_PER_SEC`, with optional ramp windows controlled by `GATLING_MAX_RAMP_SECONDS`, and keeps the normalized staircase report even when Gatling exits non-zero after assertion evaluation. The maintained Gatling scenario exits a virtual user after a failed request and the max-limit setup applies a calculated `.maxDuration(...)` guard. Summary console mode is the default: it keeps the console compact, prints Gatling metrics, then prints a short wrapper summary with the app URL, parameters, and key boundary result. The full run log exists in the workspace during the build, but Jenkins excludes Gatling raw directories, wrapper logs, and `simulation.log` files from long-lived archived/published history to avoid multi-GB build storage growth. This keeps disruptive max-limit discovery out of clean load/stress runs while still making it Jenkins-runnable when explicitly requested.
7. `Gatling Load Test`: Runs only when `scripts/run-gatling-load-5m` exists and build parameter `RUN_GATLING_LOAD_TEST=true`. Jenkins uses that wrapper as the existence gate, then starts the Gatling image through Docker Pipeline, verifies the Gatling container workspace and shared runner script, and calls `GATLING_DOCKER_PIPELINE=1 GATLING_RUN_TYPE=load-5m ./scripts/run-gatling-container`. This is the five-minute Gatling load test: it ramps to `GATLING_LOAD_USERS` users/sec, holds that arrival rate, then ramps down. The console mode parameter controls whether Jenkins streams the complete Gatling log live or only prints summary lines.
8. `Gatling Stress Test`: Runs only when `scripts/run-gatling-stress-5m` exists and build parameter `RUN_GATLING_STRESS_TEST=true`. Jenkins uses that wrapper as the existence gate, then starts the Gatling image through Docker Pipeline, verifies the Gatling container workspace and shared runner script, and calls `GATLING_DOCKER_PIPELINE=1 GATLING_RUN_TYPE=stress-5m ./scripts/run-gatling-container`. This is the five-minute Gatling stress test: it runs five users/sec staircase levels from `GATLING_STRESS_START_USERS` to `GATLING_STRESS_TARGET_USERS`. The complete Gatling output is preserved in `output/gatling/stress-5m/stress-5m-run.log` even when summary console mode is selected.

### Post-build

The Jenkins UI may label this as `Declarative: Post Actions` because that is Jenkins' built-in name for Declarative Pipeline `post` blocks. In the project documentation and defense explanation, this is the `Post-build` block.

The `post` block runs after the visible stages finish. It exports PDFs for the Gatling HTML reports that exist in the checked-out SCM workspace, generates `output/reports/pipeline-report.html` plus `output/reports/pipeline-report.css`, archives `output/**/*` while excluding Gatling raw/log files, publishes the final Pipeline HTML report, publishes Playwright JUnit XML and HTML reports, and publishes slim Gatling HTML/PDF report directories staged under `output/jenkins-html/gatling/`. Jenkins runs the PDF exporter with `GATLING_PDF_REQUIRE_ALL=false` because each Gatling stage is intentionally optional unless its matching build parameter is checked. `gatlingArchive()` is intentionally deferred until Plan 08 validates the Gatling output shape expected by the Jenkins Gatling plugin.

## Schedule

- `meta-container-ci-cd` uses SCM polling schedule `* * * * *` or manual builds.
- `meta-monitoring` uses monitoring schedule `H/5 * * * *`.
- The monitoring target from inside Jenkins is `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- Do not schedule Gatling every five minutes. The project requires five-minute Gatling test duration, not a five-minute Gatling cadence.

## Security Notes

- Jenkins mounts `/var/run/docker.sock` for this coursework stack so Docker Pipeline can run disposable test/report containers such as the official Playwright image and the Gatling image.
- Playwright runs in `mcr.microsoft.com/playwright:v1.60.0-noble`, not directly in the Jenkins image. Functional Playwright and HAR capture use separate disposable containers so validation stages do not share browser or filesystem state.
- The Jenkins image installs Docker CLI and Docker Compose from Docker's official Debian apt repository so Jenkins-side diagnostics and test-container orchestration can use `docker` and `docker compose`.
- Jenkins deploys by writing `yonatan-csasznik-yoed-halberstam-niv-levin.war` into the shared Docker volume mounted at `/tomcat-webapps`.
- The Jenkins service currently runs as `root` inside the container so it can write to the Tomcat `webapps` volume. This is a local coursework tradeoff and must not be described as production-secure.
- Do not store GitHub tokens, Jenkins admin passwords, API keys, cookies, private keys, or other secrets in tracked files.

## Evidence To Capture

- Jenkins dashboard screenshot with `localhost:8081` visible.
- Successful manual or SCM-triggered `meta-container-ci-cd` build log.
- Successful scheduled `meta-monitoring` build log.
- `output/monitoring/latest-check.txt` from `meta-monitoring`.
- Console line showing `mvn -B clean package`.
- Console line showing `./scripts/deploy-war`.
- Console line showing `curl -fsS http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- Tomcat app screenshot with `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` visible.
- SCM-triggered evidence should show Jenkins detected a repository change or was manually run after a push, then checked out the configured branch and deployed the WAR.
- Monitoring evidence should show `Started by timer` in `meta-monitoring` and no Maven, deploy, Playwright, or Gatling commands.
- Playwright evidence from Plan 06:
  - `output/playwright/playwright-run.log`
  - `output/playwright/junit.xml`
  - `output/playwright/jenkins-report/index.html`
  - `output/playwright/playwright-report/index.html`
  - `output/playwright/screenshots/valid-submit.png`
  - `output/playwright/screenshots/empty-submit.png`
- Jenkins published report evidence:
  - Consolidated final Pipeline HTML report from `output/reports/pipeline-report.html` and generated stylesheet `output/reports/pipeline-report.css`.
  - Playwright JUnit result from `output/playwright/junit.xml`.
  - Playwright HTML report from `output/playwright/jenkins-report/index.html`.
  - Native Playwright HTML artifact from `output/playwright/playwright-report/index.html`.
  - Gatling max-limit HTML/PDF report from `output/jenkins-html/gatling/max-limit/`.
  - Gatling load-test HTML/PDF report from `output/jenkins-html/gatling/load-5m/`.
  - Gatling stress-test HTML/PDF report from `output/jenkins-html/gatling/stress-5m/`.
- Previous Plan 05 remote-backed Jenkins evidence, captured before the trigger split:
  - Build `#7`: `SUCCESS`
  - Source: `https://github.com/y0ncha/meta-final-project.git`
  - Revision: `5290e50d05396e1794ad07e60d8aa9fba46232ef`
  - Branch: `refs/remotes/origin/feature/plan-05-jenkins-container-ci-cd`
  - Console evidence includes `Obtained Jenkinsfile from git`, `mvn -B clean package`, `./scripts/deploy-war`, and two `curl -fsS http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` checks.
- Previous Plan 05 local evidence files:
  - `output/jenkins/manual-build-1-console.log`
  - `output/jenkins/scheduled-build-2-console.log`
  - `output/jenkins/meta-container-ci-cd-config.xml`
  - `output/jenkins/meta-container-ci-cd-builds.json`

## Troubleshooting

- If `docker exec meta-jenkins ...` hangs while `curl -fsS http://localhost:8081/login` succeeds, Jenkins is serving HTTP but Docker exec is blocked by the local container runtime. Restart OrbStack or Docker Desktop before rerunning container-side validation.
- If Jenkins cannot write `/tomcat-webapps/yonatan-csasznik-yoed-halberstam-niv-levin.war`, confirm service `jenkins` mounts volume `tomcat_webapps` at `/tomcat-webapps` and runs with write permission to that mount.
- If Jenkins can deploy but Tomcat does not serve the updated app, remove `/tomcat-webapps/yonatan-csasznik-yoed-halberstam-niv-levin`, `/tomcat-webapps/MeTA`, `/tomcat-webapps/meta`, and `/tomcat-webapps/yonatan-csasznik-yoed-halberstam-niv-levin.war`, rerun `scripts/deploy-war`, and wait for Tomcat to expand the WAR.
- If `docker compose` is missing inside Jenkins, rebuild the custom Jenkins image and recreate the service with `docker compose build jenkins` followed by `docker compose up -d jenkins`.
- If container startup fails before the Playwright/Gatling stages, inspect `Pre Actions` for Docker CLI/daemon access, then inspect the failing Playwright or Gatling stage for that container's workspace mapping and reachability checks.
