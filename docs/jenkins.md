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
- Branch specifier: `*/feature/plan-05-jenkins-container-ci-cd` while this plan branch is being defended or reviewed. Switch to `*/main` after this branch is merged into the default branch.
- Script path: `Jenkinsfile`

Previous local validation setup used for Plan 05:

- The first local validation job was created with Jenkins' authenticated script API and read `/workspace/final-project/Jenkinsfile` from the repository mount because the repository did not have a GitHub remote yet.
- Do not use that mounted-script job as final evidence after the GitHub repository exists.
- The final Jenkins job must load `Jenkinsfile` from SCM and then run `checkout scm`, so build, deploy, and evidence come from the GitHub branch selected in the job configuration.

## Schedule

- The source-controlled schedule is `H/5 * * * *`.
- The scheduled run executes the `Availability Check` stage every five minutes.
- The availability target from inside Jenkins is `http://tomcat:8080/meta/`.

## Security Notes

- Jenkins does not mount `/var/run/docker.sock`.
- Jenkins deploys by writing `meta.war` into the shared Docker volume mounted at `/tomcat-webapps`.
- The Jenkins service currently runs as `root` inside the container so it can write to the Tomcat `webapps` volume. This is a local coursework tradeoff and must not be described as production-secure.
- Do not store GitHub tokens, Jenkins admin passwords, API keys, cookies, private keys, or other secrets in tracked files.

## Evidence To Capture

- Jenkins dashboard screenshot with `localhost:8081` visible.
- Successful manual `meta-container-ci-cd` build log.
- Successful scheduled `meta-container-ci-cd` build log.
- Console line showing `mvn -B clean package`.
- Console line showing `./scripts/deploy-war`.
- Console line showing `curl -fsS http://tomcat:8080/meta/`.
- Tomcat app screenshot with `http://localhost:8080/meta/` visible.
- Current local evidence files:
  - `output/jenkins/05-manual-build-1-console.log`
  - `output/jenkins/05-scheduled-build-2-console.log`
  - `output/jenkins/05-meta-container-ci-cd-config.xml`
  - `output/jenkins/05-meta-container-ci-cd-builds.json`

## Troubleshooting

- If `docker exec meta-jenkins ...` hangs while `curl -fsS http://localhost:8081/login` succeeds, Jenkins is serving HTTP but Docker exec is blocked by the local container runtime. Restart OrbStack or Docker Desktop before rerunning container-side validation.
- If Jenkins cannot write `/tomcat-webapps/meta.war`, confirm service `jenkins` mounts volume `tomcat_webapps` at `/tomcat-webapps` and runs with write permission to that mount.
- If Jenkins can deploy but Tomcat does not serve the updated app, remove `/tomcat-webapps/meta` and `/tomcat-webapps/meta.war`, rerun `scripts/deploy-war`, and wait for Tomcat to expand the WAR.
