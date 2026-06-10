# Playwright Functional Test

## Runtime

- Local command: `./scripts/run-playwright-container`
- Jenkins command: `./scripts/run-playwright-container` from the `Playwright Functional Test` stage in `Jenkinsfile`
- Local default container image: `mcr.microsoft.com/playwright:v1.52.0-noble`
- Local default Docker network: `meta`
- Local default app URL from the Playwright container: `http://tomcat:8080/meta/`
- Jenkins default app URL from the Playwright container: `http://tomcat:8080/meta/`
- Jenkins runner container: `meta-jenkins`
- Host browser URL for manual checks: `http://localhost:8080/meta/`

The runner keeps `APP_BASE_URL` configurable. Override it only when the Tomcat target changes for a real environment, for example a public-IP bonus target.

## Functional Validations

The test file is `tests/playwright/meta-functional.spec.js`. It contains one browser test with exactly five assignment-facing validation steps:

1. Page shell visibility: loads the configured app root, checks `#pageTitle` text equals `DevOps Final Project`, and verifies `#submitButton` and `#nameInput` are visible.
2. Link navigation: clicks `#aboutLink`, checks the URL ends with `#about`, and verifies `#about` contains `About`.
3. Text input: fills `#nameInput` with `Yonatan` and verifies the input value.
4. Valid submit: clicks `#submitButton`, verifies `#resultMessage` equals `Hello, Yonatan. Your JSP form submission worked.`, and captures `output/playwright/screenshots/06-valid-submit.png`.
5. Empty submit: reloads the configured app root, submits an empty form, verifies `#validationMessage` equals `Please enter a name before submitting.`, and captures `output/playwright/screenshots/06-empty-submit.png`.

## Local Execution

Run from the repository root after Tomcat is deployed:

```sh
./scripts/deploy-war
./scripts/run-playwright-container
```

The local runner starts the official Playwright container on Docker network `meta`, installs dependencies with `npm ci` inside that container, and runs `npx playwright test`.

## Jenkins Execution

The source-controlled `Jenkinsfile` already contains stage `Playwright Functional Test`. That stage runs only for non-timer builds and executes:

```sh
./scripts/run-playwright-container
```

Jenkins mounts the host Docker socket and uses the Docker CLI to start the same official Playwright container used by local execution. The runner uses `--volumes-from meta-jenkins` so the disposable Playwright container can see the Jenkins workspace and write evidence back under `output/playwright/`.

This 2026-06-10 Plan 06 follow-up replaces the original Jenkins execution path where Node, npm, and Debian Chromium were installed directly inside the Jenkins image. Jenkins now orchestrates the official Playwright container instead.

## Evidence Files

Generated evidence is ignored by Git and should be archived by Jenkins or attached manually for submission:

- `output/playwright/06-playwright-run.log`
- `output/playwright/junit.xml`
- `output/playwright/playwright-report/index.html`
- `output/playwright/screenshots/06-valid-submit.png`
- `output/playwright/screenshots/06-empty-submit.png`

## Known Assignment Override

`final-project.pdf` names Selenium IDE `.side` as the browser automation deliverable. This project uses Playwright under the accepted override documented in `rules/compliance.md`. Keep this mismatch visible during defense because the lecturer may still ask why Selenium IDE was not used.
