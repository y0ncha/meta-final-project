# Technical Architecture

## Overview

The project is one Jenkins-driven CI/CD pipeline for a JSP application. Jenkins pulls the code from GitHub, builds the WAR, deploys it to Tomcat, verifies the app, and runs the required automated checks.

```mermaid
flowchart LR
  Dev["Developer"] -->|push code| GitHub["GitHub"]
  GitHub -->|SCM poll| Jenkins["Jenkins (localhost:8081)"]
  Jenkins -->|build WAR| Maven["Maven"]
  Maven -->|meta.war| Tomcat["Tomcat (localhost:8080/meta/)"]
  Jenkins -->|deploy + verify| Tomcat
  Jenkins -->|run browser test| Playwright["Playwright container"]
  Playwright -->|test app| Tomcat
  Jenkins -->|run performance tests| Gatling["Gatling containers"]
  Gatling -->|load/stress app| Tomcat
  Jenkins -->|5-minute check| Monitor["Availability check"]
  Monitor -->|curl app| Tomcat
```

## CI/CD Pipeline

The assignment asks for a single CI/CD pipeline. This Jenkins job keeps one pipeline while using trigger-aware stages: source changes run the build/deploy/test path, and timer runs only the availability check.

```mermaid
flowchart TD
  Start["Jenkins: meta-container-ci-cd"] --> Trigger{"Trigger"}

  Trigger -->|Git push or manual run| Build["Build WAR"]
  Build --> Deploy["Deploy to Tomcat"]
  Deploy --> Verify["Verify app"]
  Verify --> Browser["Run Playwright"]
  Browser --> Perf["Run Gatling load/stress"]
  Perf --> Done["Archive evidence"]

  Trigger -->|Every 5 minutes| Availability["Availability check only"]
  Availability --> Done
```

## Runtime Notes

- Tomcat serves the app at `http://localhost:8080/meta/`.
- Jenkins is available at `http://localhost:8081/`.
- Jenkins uses Docker only to start disposable Playwright and Gatling test containers.
- Timer-triggered runs must not rebuild, redeploy, or run Playwright/Gatling.
- Generated evidence is written under `output/` and stays out of Git.

## Plan Status

Plan 06 is completed: it added the Playwright functional test, container runner, Jenkins execution path, and evidence documentation.
