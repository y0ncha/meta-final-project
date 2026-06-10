# Jenkins Container CI/CD

## Runtime

- Jenkins URL: `http://localhost:8081/`
- Tomcat host URL: `http://localhost:8080/meta/`
- Tomcat internal Docker URL: `http://tomcat:8080/meta/`
- Jenkins Compose service: `jenkins`
- Tomcat Compose service: `tomcat`
- Jenkins home volume: `jenkins_home`
- Tomcat webapps volume: `tomcat_webapps`
- Jenkins SCM workspace: the Jenkins job workspace created from the GitHub repository checkout.
- Legacy local validation mount: `/workspace/final-project`
- Jenkins Tomcat deployment mount: `/tomcat-webapps`
- GitHub repository: `https://github.com/y0ncha/meta-final-project.git`

## Manual Jenkins Setup

1. Start the stack with `docker compose up -d tomcat jenkins`.
2. Open `http://localhost:8081/`.
3. Unlock Jenkins with the initial admin password from `/var/jenkins_home/secrets/initialAdminPassword`.
4. Create the Jenkins admin user.
5. Install required plugins:
   - `Git`
   - `Pipeline`
   - `Pipeline: SCM Step`
   - `Pipeline: Declarative`
   - `Pipeline: Stage View`
   - `HTML Publisher` if report archival is needed by later evidence plans.

## Pipeline Job

- Job name: `meta-container-ci-cd`
- Job type: `Pipeline`
- Script path: `Jenkinsfile`

Final GitHub-backed setup:

- Definition: `Pipeline script from SCM`
- SCM: `Git`
- Repository URL: `https://github.com/y0ncha/meta-final-project.git`
- Credentials: leave empty for a public repository. If the repository is private, create Jenkins credentials and reference only the credentials ID.
- Branch specifier: use the branch being defended or reviewed, for example `*/feature/jenkins-trigger-split`. Switch to `*/main` after the branch is merged into the default branch.
- Script path: `Jenkinsfile`
- The source-controlled Jenkinsfile includes `pollSCM('H/2 * * * *')` so a local Jenkins instance can detect pushed GitHub changes without needing an inbound GitHub webhook.
- If Jenkins is exposed through a stable public URL, prefer a GitHub webhook that triggers this same Pipeline job on push or merge events. Keep `pollSCM` as the local defense fallback unless the webhook evidence is already captured.

Previous local validation setup used for Plan 05:

- The first local validation job was created with Jenkins' authenticated script API and read `/workspace/final-project/Jenkinsfile` from the repository mount because the repository did not have a GitHub remote yet.
- Do not use that mounted-script job as final evidence after the GitHub repository exists.
- The final Jenkins job must load `Jenkinsfile` from SCM. On non-timer builds it then runs `checkout scm`, so build, deploy, and CI/CD evidence come from the GitHub branch selected in the job configuration.

## Pipeline Stages

The source-controlled `Jenkinsfile` handles two different trigger classes:

- SCM or manual builds run the CI/CD path: checkout, build, deploy, verify, and optional Playwright/Gatling scripts.
- Timer builds run only the Jenkins-side availability check every five minutes.

1. `Checkout`: Runs `checkout scm` only for non-timer builds. This makes Jenkins fetch the repository and branch configured in the Pipeline job, so the build uses GitHub source code instead of files copied manually into the Jenkins container.
2. `Build WAR`: Runs `mvn -B clean package` and archives `target/meta.war` only for non-timer builds. Maven turns the JSP application into the WAR file Tomcat can deploy; archiving the WAR gives Jenkins build evidence and a traceable artifact.
3. `Deploy Tomcat`: Runs `./scripts/deploy-war` with `SKIP_BUILD=1`, `TOMCAT_SHARED_WEBAPPS_DIR=/tomcat-webapps`, and `DEPLOY_CHECK_URL="$DEPLOY_CHECK_URL"` only for non-timer builds. This reuses the repository deployment script, avoids rebuilding the WAR twice, writes the WAR into the shared Tomcat webapps volume, and waits until Tomcat serves the deployed app.
4. `Verify Tomcat`: Runs `curl -fsS "$APP_BASE_URL" >/dev/null` only for non-timer builds. This proves the deployment is not just copied to disk but reachable through Tomcat at `http://tomcat:8080/meta/` from inside the Docker network.
5. `Availability Check`: Runs `curl -fsS "$APP_BASE_URL" >/dev/null` only for timer-triggered builds. This is the Jenkins-side five-minute availability monitor evidence required by the project; it does not rebuild, redeploy, or run Gatling.
6. `Playwright Functional Test`: Runs `./scripts/run-playwright-container` only for non-timer builds and only when that script exists. This keeps the CI/CD pipeline ready for the browser-test plan without failing before the Playwright script is added.
7. `Gatling Load Test`: Runs `./scripts/run-gatling-load-5m` only for non-timer builds and only when that script exists. This is the hook for the required five-minute Gatling load test once the Gatling plan adds the script.
8. `Gatling Stress Test`: Runs `./scripts/run-gatling-stress-5m` only for non-timer builds and only when that script exists. This is the hook for the required five-minute Gatling stress test once the Gatling plan adds the script.

The `post` block always archives `output/**/*` if files exist. Later Playwright, Gatling, HAR, screenshots, and report files should be written under `output/` so Jenkins can attach them to the build without tracking generated evidence in Git.

## Schedule

- The source-controlled availability schedule is `H/5 * * * *`.
- The source-controlled SCM polling schedule is `H/2 * * * *`.
- Timer-triggered runs execute only the `Availability Check` stage every five minutes.
- SCM-triggered or manual runs execute the build, deploy, verification, and optional test stages.
- The availability target from inside Jenkins is `http://tomcat:8080/meta/`.
- Do not schedule Gatling every five minutes. The project requires five-minute Gatling test duration, not a five-minute Gatling cadence.

## Security Notes

- Jenkins does not mount `/var/run/docker.sock`.
- Jenkins deploys by writing `meta.war` into the shared Docker volume mounted at `/tomcat-webapps`.
- The Jenkins service currently runs as `root` inside the container so it can write to the Tomcat `webapps` volume. This is a local coursework tradeoff and must not be described as production-secure.
- Do not store GitHub tokens, Jenkins admin passwords, API keys, cookies, private keys, or other secrets in tracked files.

## Evidence To Capture

- Jenkins dashboard screenshot with `localhost:8081` visible.
- Successful manual or SCM-triggered `meta-container-ci-cd` build log.
- Successful timer-triggered `meta-container-ci-cd` availability log.
- Console line showing `mvn -B clean package`.
- Console line showing `./scripts/deploy-war`.
- Console line showing `curl -fsS http://tomcat:8080/meta/`.
- Tomcat app screenshot with `http://localhost:8080/meta/` visible.
- Timer-triggered evidence should show `Started by timer`, skip the build/deploy/test stages, and run only the availability `curl` check.
- SCM-triggered evidence should show Jenkins detected a repository change or was manually run after a push, then checked out the configured branch and deployed the WAR.
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
