# Technical Architecture

## Overview

The project uses two Jenkins Pipeline jobs for a JSP application. The CI/CD job pulls code from GitHub, builds the WAR, deploys it to Tomcat, verifies the app, and runs the required automated checks. The separate availability job checks the deployed app every 5 minutes, matching the instructor-confirmed monitoring split.

```mermaid
flowchart LR
  Dev["Developer"] -->|push code| GitHub["GitHub"]
  GitHub -->|SCM poll| CICD["Jenkins job: meta-container-ci-cd"]
  CICD -->|build WAR| Maven["Maven"]
  Maven -->|meta.war| Tomcat["Tomcat (localhost:8080/meta/)"]
  CICD -->|deploy + verify| Tomcat
  CICD -->|run browser test| Playwright["Playwright container"]
  Playwright -->|test app| Tomcat
  CICD -->|run performance tests| Gatling["Gatling containers"]
  Gatling -->|load/stress app| Tomcat
  MonitorJob["Jenkins job: meta-availability-monitor"] -->|5-minute check| Monitor["Availability check"]
  Monitor -->|curl app| Tomcat
```

## CI/CD Pipeline

The CI/CD job is `meta-container-ci-cd` and uses script path `Jenkinsfile`. It runs on SCM polling or manual execution. It does not contain the availability-monitor schedule.

```mermaid
flowchart TD
  Start["Jenkins job: meta-container-ci-cd"] --> Build["Build WAR"]
  Build --> Deploy["Deploy to Tomcat"]
  Deploy --> Verify["Verify app"]
  Verify --> Browser["Run Playwright"]
  Browser --> Perf["Run Gatling load/stress"]
  Perf --> Done["Archive evidence"]
```

## Availability Monitoring Job

The availability job is `meta-availability-monitor` and uses script path `Jenkinsfile.availability`. It runs every 5 minutes and performs only a `curl` availability check.

```mermaid
flowchart TD
  Start["Jenkins job: meta-availability-monitor"] --> Schedule["H/5 * * * *"]
  Schedule --> Availability["curl http://tomcat:8080/meta/"]
  Availability --> Evidence["Archive output/monitoring/latest-check.txt"]
  Evidence --> Done["Finish"]
```

## Runtime Notes

- Tomcat serves the app at `http://localhost:8080/meta/`.
- Jenkins is available at `http://localhost:8081/`.
- Jenkins uses Docker only to start disposable Playwright and Gatling test containers.
- The scheduled monitoring job must not rebuild, redeploy, or run Playwright/Gatling.
- Generated evidence is written under `output/` and stays out of Git.

## Plan Status

Plan 06 is completed: it added the Playwright functional test, container runner, Jenkins execution path, and evidence documentation.
