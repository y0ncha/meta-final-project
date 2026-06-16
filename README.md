# MTA DevOps Final Project

The project is a simple JSP application delivered to Tomcat through Jenkins, with monitoring, browser automation, HAR evidence, and Gatling performance evidence. The default runtime is the approved containerized track: Tomcat, Jenkins, Playwright, and Gatling run through Docker instead of host-installed coursework tools. The main CI/CD implementation is the Jenkins Pipeline job `meta-ci-cd`. Monitoring is intentionally split into the separate Jenkins Freestyle job `meta-monitoring`.

## Project Links

- Public GitHub repository: `https://github.com/y0ncha/meta-final-project`
- Local Tomcat application: `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Local Jenkins: `http://localhost:8081/`
- Jenkins CI/CD job: `meta-ci-cd`
- Jenkins monitoring job: `meta-monitoring`

## Assignment Requirements

| Final-project requirement | Repository answer |
|---|---|
| 1. Simple JSP app with at least one link, one button, and one text input | `src/main/webapp/index.jsp` implements the MeTA page, link, submit button, and name input. |
| 2. Store code in Git and GitHub | The repository is tracked in Git and published at `https://github.com/y0ncha/meta-final-project`. |
| 3. Tomcat `webapps` folder name includes group names | Maven builds `target/yonatan-csasznik-yoed-halberstam-niv-levin.war`, served at `/yonatan-csasznik-yoed-halberstam-niv-levin/`. |
| 4. Jenkins deploys Git/GitHub code to Tomcat | `Jenkinsfile` builds the WAR, deploys it with `scripts/deploy-war`, and verifies Tomcat. |
| 5. Optional public-IP bonus | Tracked separately in `docs/public-app-bonus.md`; do not claim unless the public URL and bullets 6-10 are validated with real evidence. |
| 6. Availability monitor every 5 minutes | `meta-monitoring` runs `scripts/run-monitoring-check` on `H/5 * * * *`; UptimeRobot/SiteMonitorLite evidence is tracked in `docs/submission.md`. |
| 7. Browser test with 5 validations | `tests/playwright/meta-functional.spec.js` provides the Selenium IDE or similar substitute and is run by Jenkins through `scripts/run-playwright-container`. |
| 8. Gatling max-limit test | `scripts/run-gatling-max-limit` runs bounded max-limit discovery in a Gatling container and writes evidence under `output/gatling/max-limit/`. |
| 9. 5-minute Gatling load test | `scripts/run-gatling-load-5m` runs the 5-minute load flow from Jenkins or local evidence capture. |
| 10. 5-minute Gatling stress test | `scripts/run-gatling-stress-5m` runs the 5-minute stress flow from Jenkins or local evidence capture. |

## Main Local Commands

Start Tomcat and Jenkins:

```sh
docker compose up -d tomcat jenkins
```

Build and deploy the JSP app:

```sh
./scripts/deploy-war
```

Run browser automation:

```sh
./scripts/run-playwright-container
```

Capture and validate HAR evidence:

```sh
./scripts/capture-har
./scripts/validate-har output/har/meta-functional-flow.har
```

Run Gatling evidence flows only when intentionally refreshing performance evidence:

```sh
./scripts/run-gatling-max-limit
./scripts/run-gatling-load-5m
./scripts/run-gatling-stress-5m
./scripts/export-gatling-pdfs
```

Do not run Gatling casually - the load and stress tests are intentionally heavier than normal smoke checks.

## Documentation Map

- `rules/compliance.md` - operational compliance checklist and approved project overrides.
- `docs/submission.md` - consolidated final email, evidence checklist, explanations, and package readiness.
- `docs/jenkins.md` - Jenkins jobs, stages, schedules, and evidence to capture.
- `docs/playwright.md` - five browser validations and Playwright override explanation.
- `docs/gatling.md` - Gatling commands, evidence paths, max-limit method, and graph explanations.
- `docs/monitoring.md` - five-minute monitoring job setup.
- `docs/har-scenario.md` - HAR scenario and validation notes.
- `docs/public-app-bonus.md` - optional public-IP bonus target and cleanup notes.
