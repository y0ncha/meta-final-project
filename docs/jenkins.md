# Jenkins Container CI/CD

## Runtime

- Jenkins URL: `http://localhost:8081/`
- Tomcat host URL: `http://localhost:8080/meta/`
- Tomcat internal Docker URL: `http://tomcat:8080/meta/`
- Jenkins Compose service: `jenkins`
- Tomcat Compose service: `tomcat`
- Jenkins home volume: `jenkins_home`
- Tomcat webapps volume: `tomcat_webapps`
- Jenkins CI/CD SCM workspace: the `meta-container-ci-cd` workspace created from the GitHub repository checkout.
- Jenkins monitoring workspace: the `meta-availability-monitor` workspace that writes availability evidence.
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

This project uses two source-controlled Jenkins Pipeline jobs because the instructor confirmed that availability monitoring should be separate from the CI/CD build/deploy/test job.

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
- The source-controlled Jenkinsfile includes `pollSCM('H/2 * * * *')` so a local Jenkins instance can detect pushed GitHub changes without needing an inbound GitHub webhook.
- If Jenkins is exposed through a stable public URL, prefer a GitHub webhook that triggers this same Pipeline job on push or merge events. Keep `pollSCM` as the local defense fallback unless the webhook evidence is already captured.

### Availability Monitoring Job

- Job name: `meta-availability-monitor`
- Job type: `Pipeline`
- Purpose: run only the five-minute application availability check.
- Definition: `Pipeline script from SCM`
- SCM: `Git`
- Repository URL: `https://github.com/y0ncha/meta-final-project.git`
- Credentials: leave empty for a public repository. If the repository is private, use the same read-only GitHub credentials policy as the CI/CD job.
- Branch specifier: use the same branch as `meta-container-ci-cd` while validating a branch, then switch to `*/main` after merge.
- Script path: `Jenkinsfile.availability`
- The source-controlled availability Jenkinsfile includes `cron('H/5 * * * *')`.
- The job checks `http://tomcat:8080/meta/`, writes `output/monitoring/latest-check.txt`, and archives `output/monitoring/**/*`.

Previous local validation setup used for Plan 05:

- The first local validation job was created with Jenkins' authenticated script API and read `/workspace/final-project/Jenkinsfile` from the repository mount because the repository did not have a GitHub remote yet.
- Do not use that mounted-script job as final evidence after the GitHub repository exists.
- The final Jenkins job must load `Jenkinsfile` from SCM. On non-timer builds it then runs `checkout scm`, so build, deploy, and CI/CD evidence come from the GitHub branch selected in the job configuration.

## Pipeline Stages

The source-controlled `Jenkinsfile` is only for the `meta-container-ci-cd` job. It does not contain the five-minute availability schedule.

1. `Checkout`: Runs `checkout scm` and records the checked-out commit in `CHECKED_OUT_COMMIT`. This makes Jenkins fetch the repository and branch configured in the Pipeline job, so the build uses GitHub source code instead of files copied manually into the Jenkins container.
2. `Prepare Evidence Workspace`: Removes generated `output/gatling`, `output/playwright`, `output/har`, and `output/reports` directories so published artifacts cannot come from a previous workspace run.
3. `Build WAR`: Runs `mvn -B clean package` and archives `target/meta.war`. Maven turns the JSP application into the WAR file Tomcat can deploy; archiving the WAR gives Jenkins build evidence and a traceable artifact.
4. `Deploy Tomcat`: Runs `./scripts/deploy-war` with `SKIP_BUILD=1`, `TOMCAT_SHARED_WEBAPPS_DIR=/tomcat-webapps`, and `DEPLOY_CHECK_URL="$DEPLOY_CHECK_URL"`. This reuses the repository deployment script, avoids rebuilding the WAR twice, writes the WAR into the shared Tomcat webapps volume, and waits until Tomcat serves the deployed app.
5. `Verify Tomcat`: Runs `curl -fsS "$APP_BASE_URL" >/dev/null` after deployment. It proves the deployed WAR is reachable through Tomcat at `http://tomcat:8080/meta/` from inside the Docker network.
6. `Docker Pipeline Preflight`: Runs before disposable test containers. It checks Docker CLI access, Compose CLI access, Docker daemon access, workspace mapping, checked-out commit identity, and Tomcat reachability from the Playwright image.
7. `Playwright Functional Test`: Runs only when `scripts/run-playwright-container` exists. Jenkins starts the official Playwright image through Docker Pipeline with working directory `env.WORKSPACE`, then calls `PLAYWRIGHT_DOCKER_PIPELINE=1 ./scripts/run-playwright-container` inside that container so evidence is written under the checked-out SCM workspace.
8. `Gatling Max Limit`: Runs `./scripts/run-gatling-max-limit` only when that script exists and build parameter `RUN_GATLING_MAX_LIMIT=true`. This keeps disruptive max-limit discovery out of ordinary CI/CD runs while still making it Jenkins-runnable for evidence capture.
9. `Gatling Load Test`: Runs `./scripts/run-gatling-load-5m` only when that script exists. This is the required five-minute Gatling load test.
10. `Gatling Stress Test`: Runs `./scripts/run-gatling-stress-5m` only when that script exists. This is the required five-minute Gatling stress test.

The `post` block performs administrative finalization after validation stages finish. It exports PDFs for the Gatling HTML reports that exist in the checked-out SCM workspace, generates `output/reports/pipeline-report.html`, archives `output/**/*`, publishes the final Pipeline HTML report, publishes Playwright JUnit XML and HTML reports, and publishes Gatling HTML/PDF reports from `output/gatling/max-limit/`, `output/gatling/load-5m/`, and `output/gatling/stress-5m/`. Jenkins runs the PDF exporter with `GATLING_PDF_REQUIRE_ALL=false` because the max-limit stage is optional. `gatlingArchive()` is intentionally deferred until Plan 08 validates the Gatling output shape expected by the Jenkins Gatling plugin.

## Schedule

- `meta-container-ci-cd` uses SCM polling schedule `H/2 * * * *` or manual builds.
- `meta-availability-monitor` uses availability schedule `H/5 * * * *`.
- The monitoring target from inside Jenkins is `http://tomcat:8080/meta/`.
- Do not schedule Gatling every five minutes. The project requires five-minute Gatling test duration, not a five-minute Gatling cadence.

## Security Notes

- Jenkins mounts `/var/run/docker.sock` for this coursework stack so Docker Pipeline can run disposable test/report containers such as the official Playwright image and the Gatling image.
- Playwright runs in `mcr.microsoft.com/playwright:v1.60.0-noble`, not directly in the Jenkins image. Functional Playwright and HAR capture use separate disposable containers so validation stages do not share browser or filesystem state.
- The Jenkins image installs Docker CLI and Docker Compose from Docker's official Debian apt repository so Jenkins-side diagnostics and test-container orchestration can use `docker` and `docker compose`.
- Jenkins deploys by writing `meta.war` into the shared Docker volume mounted at `/tomcat-webapps`.
- The Jenkins service currently runs as `root` inside the container so it can write to the Tomcat `webapps` volume. This is a local coursework tradeoff and must not be described as production-secure.
- Do not store GitHub tokens, Jenkins admin passwords, API keys, cookies, private keys, or other secrets in tracked files.

## Evidence To Capture

- Jenkins dashboard screenshot with `localhost:8081` visible.
- Successful manual or SCM-triggered `meta-container-ci-cd` build log.
- Successful scheduled `meta-availability-monitor` availability log.
- `output/monitoring/latest-check.txt` from `meta-availability-monitor`.
- Console line showing `mvn -B clean package`.
- Console line showing `./scripts/deploy-war`.
- Console line showing `curl -fsS http://tomcat:8080/meta/`.
- Tomcat app screenshot with `http://localhost:8080/meta/` visible.
- SCM-triggered evidence should show Jenkins detected a repository change or was manually run after a push, then checked out the configured branch and deployed the WAR.
- Monitoring evidence should show `Started by timer` in `meta-availability-monitor` and no Maven, deploy, Playwright, or Gatling commands.
- Playwright evidence from Plan 06:
  - `output/playwright/06-playwright-run.log`
  - `output/playwright/junit.xml`
  - `output/playwright/playwright-report/index.html`
  - `output/playwright/screenshots/06-valid-submit.png`
  - `output/playwright/screenshots/06-empty-submit.png`
- Jenkins published report evidence:
  - Consolidated final Pipeline HTML report from `output/reports/pipeline-report.html`.
  - Playwright JUnit result from `output/playwright/junit.xml`.
  - Playwright HTML report from `output/playwright/playwright-report/index.html`.
  - Gatling max-limit HTML/PDF report from `output/gatling/max-limit/`.
  - Gatling load-test HTML/PDF report from `output/gatling/load-5m/`.
  - Gatling stress-test HTML/PDF report from `output/gatling/stress-5m/`.
- Previous Plan 05 remote-backed Jenkins evidence, captured before the trigger split:
  - Build `#7`: `SUCCESS`
  - Source: `https://github.com/y0ncha/meta-final-project.git`
  - Revision: `5290e50d05396e1794ad07e60d8aa9fba46232ef`
  - Branch: `refs/remotes/origin/feature/plan-05-jenkins-container-ci-cd`
  - Console evidence includes `Obtained Jenkinsfile from git`, `mvn -B clean package`, `./scripts/deploy-war`, and two `curl -fsS http://tomcat:8080/meta/` checks.
- Previous Plan 05 local evidence files:
  - `output/jenkins/05-manual-build-1-console.log`
  - `output/jenkins/05-scheduled-build-2-console.log`
  - `output/jenkins/05-meta-container-ci-cd-config.xml`
  - `output/jenkins/05-meta-container-ci-cd-builds.json`

## Troubleshooting

- If `docker exec meta-jenkins ...` hangs while `curl -fsS http://localhost:8081/login` succeeds, Jenkins is serving HTTP but Docker exec is blocked by the local container runtime. Restart OrbStack or Docker Desktop before rerunning container-side validation.
- If Jenkins cannot write `/tomcat-webapps/meta.war`, confirm service `jenkins` mounts volume `tomcat_webapps` at `/tomcat-webapps` and runs with write permission to that mount.
- If Jenkins can deploy but Tomcat does not serve the updated app, remove `/tomcat-webapps/meta` and `/tomcat-webapps/meta.war`, rerun `scripts/deploy-war`, and wait for Tomcat to expand the WAR.
- If `docker compose` is missing inside Jenkins, rebuild the custom Jenkins image and recreate the service with `docker compose build jenkins` followed by `docker compose up -d jenkins`.
- If Docker Pipeline fails before the Playwright/Gatling stages, inspect the `Docker Pipeline Preflight` stage first. It checks Docker CLI access, Compose CLI access, Docker daemon access, the Playwright-image workspace path, and container reachability to `http://tomcat:8080/meta/`.
