# MTA DevOps Final Project

This repository contains the coursework implementation for the MTA 2026 Semester B DevOps final project. The assignment asks for a simple JSP application delivered to Tomcat through Jenkins, with monitoring, browser automation, HAR evidence, and Gatling performance evidence.

The assignment source is `final-project.pdf`; `docs/final-project.txt` is the searchable text extract used by the project docs.

## Project Links

- Public GitHub repository: `https://github.com/y0ncha/meta-final-project`
- Local Tomcat application: `http://localhost:8080/MeTA/`
- Local Jenkins: `http://localhost:8081/`
- Jenkins CI/CD job: `meta-container-ci-cd`
- Jenkins monitoring job: `meta-monitoring`

## What Is Implemented

| Assignment area | Project implementation |
|---|---|
| JSP web app | Maven JSP app in `src/main/webapp/index.jsp`, packaged as `target/MeTA.war`. |
| Git and GitHub | Repository remote points to `https://github.com/y0ncha/meta-final-project.git`. |
| Tomcat deployment | Dockerized Tomcat serves the app at `/MeTA/`; deployment uses `scripts/deploy-war`. |
| Jenkins CI/CD | `Jenkinsfile` builds, deploys, verifies Tomcat, runs Playwright, runs Gatling, and publishes reports. |
| Monitoring | Separate Jenkins Freestyle job `meta-monitoring` runs every 5 minutes via `scripts/run-monitoring-check`. |
| Browser automation | Playwright test in `tests/playwright/meta-functional.spec.js` covers five application validations. |
| HAR evidence | HAR scenario is documented in `docs/har-scenario.md`; capture uses `scripts/capture-har`. |
| Gatling evidence | Gatling max-limit, 5-minute load, and 5-minute stress flows are documented in `docs/gatling.md`. |
| Submission package | Required email items are tracked in `docs/submission.md`. |

## Main Local Commands

Start the local stack:

```sh
docker compose up -d tomcat jenkins
```

Build and deploy the JSP app to Tomcat:

```sh
./scripts/deploy-war
```

Run browser automation:

```sh
./scripts/run-playwright-container
```

Capture HAR evidence:

```sh
./scripts/capture-har
./scripts/validate-har output/har/meta-functional-flow.har
```

Run Gatling evidence flows:

```sh
./scripts/run-gatling-max-limit
./scripts/run-gatling-load-5m
./scripts/run-gatling-stress-5m
./scripts/export-gatling-pdfs
```

Do not run Gatling casually; the load and stress tests are intentionally heavier than normal smoke checks.

## Documentation Map

- `rules/compliance.md` - operational compliance checklist and approved project overrides.
- `docs/submission.md` - final email checklist and remaining evidence status.
- `docs/jenkins.md` - Jenkins jobs, stages, schedules, and evidence to capture.
- `docs/playwright.md` - five browser validations and Playwright override explanation.
- `docs/gatling.md` - Gatling run commands, evidence paths, and graph explanations.
- `docs/monitoring.md` - five-minute monitoring job setup.
- `docs/har-scenario.md` - HAR scenario and validation notes.

## Evidence Policy

Generated evidence is written under ignored `output/` paths and should be reviewed before submission. Do not commit fake screenshots, guessed Gatling numbers, secrets, Jenkins passwords, HAR data that has not been reviewed, or placeholder evidence.

Before final submission, refresh `docs/submission.md` and make sure every required item from `docs/final-project.txt` is backed by real artifacts or screenshots.
