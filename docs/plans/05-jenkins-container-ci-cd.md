# 05 - Jenkins Container CI/CD

## Goal
Configure Jenkins in Docker to pull GitHub code, build the WAR, and deploy it into Tomcat.

## Deliverables
- Jenkins container with persistent home.
- Jenkins pipeline/job definition or documented freestyle job commands.
- Build/deploy script callable from Jenkins.
- Jenkins evidence screenshots/logs.

## Implementation
- Run Jenkins on `http://localhost:8081/`.
- Install required plugins:
  - Git.
  - Pipeline or freestyle job support.
  - HTML Publisher if report archiving is used.
- Configure source control to use the public GitHub repo.
- Job flow:
  - Checkout/pull GitHub repo.
  - Run `mvn clean package`.
  - Copy WAR to the Tomcat `webapps` mount.
  - Wait for `http://tomcat:8080/meta/` or host URL to respond.
  - Trigger Playwright and Gatling jobs/stages as documented in later plans.

## Validation
- Manual Jenkins build succeeds.
- A small JSP change pushed to GitHub is picked up by Jenkins.
- Tomcat serves the changed app after Jenkins deploys it.

## Human Configuration Needed
- Unlock Jenkins.
- Create admin account.
- Install plugins.
- Add GitHub credentials if the repo is private.
- Create or confirm the final Jenkins job names.
