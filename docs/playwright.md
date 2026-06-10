# Playwright Functional Test

## Runtime

- Local command: `./scripts/run-playwright-container`
- Jenkins command: `./scripts/run-playwright-container` from the `Playwright Functional Test` stage in `Jenkinsfile`
- Local default container image: `mcr.microsoft.com/playwright:v1.60.0-noble`
- Local container runner: direct disposable `docker run`
- Jenkins container runner: Jenkins Docker Pipeline using `docker.image(env.PLAYWRIGHT_IMAGE).inside(...)`
- Default Docker network: `meta`
- Local default app URL from the Playwright container: `http://tomcat:8080/meta/`
- Jenkins default app URL from the Playwright container: `http://tomcat:8080/meta/`
- Jenkins runner container: `meta-jenkins`
- Default disposable Playwright container name: `meta-playwright-${BUILD_NUMBER:-local}`
- Host browser URL for manual checks: `http://localhost:8080/meta/`

The runner keeps `APP_BASE_URL` configurable. Override it only when the Tomcat target changes for a real environment, for example a public-IP bonus target. The disposable container name is configurable with `PLAYWRIGHT_CONTAINER_NAME`; by default local runs use `meta-playwright-local` and Jenkins runs use `meta-playwright-<build-number>`.

Playwright validation runs through a fresh disposable container each time. The functional test and HAR capture intentionally do not reuse the same Playwright container, so filesystem, browser cache, and test output state cannot leak between validation stages.

## Functional Validations

The test file is `tests/playwright/meta-functional.spec.js`. It contains one browser test with exactly five assignment-facing validation steps:

1. Page shell visibility: loads the configured app root, checks `#pageTitle` text equals `MeTA`, and verifies `#submitButton` and `#nameInput` are visible.
2. Link navigation: clicks `#aboutLink`, checks the URL ends with `#about`, and verifies `#about` contains `About`.
3. Text input: fills `#nameInput` with `Yonatan` and verifies the input value.
4. Valid submit: clicks `#submitButton`, verifies `#resultMessage` equals `Hello, Yonatan. Your JSP form submission worked.`, and captures `output/playwright/screenshots/06-valid-submit.png`.
5. Empty submit: reloads the configured app root, submits an empty form, verifies `#validationMessage` equals `Please enter a name before submitting.`, and captures `output/playwright/screenshots/06-empty-submit.png`.

## Assertion And Validation Types

Playwright uses `expect(...)` assertions for every automated validation in this project. In Selenium IDE terms, these behave like `assert` commands: if one fails, the test fails immediately. The project does not use soft `verify` checks that continue after failure.

| Step | Playwright assertion | Validation type | Reason |
|------|----------------------|-----------------|--------|
| Page shell visibility | `toHaveText('MeTA')`, `toBeVisible()` | Positive assertion | Confirms the deployed JSP page loaded and exposes the required button and text input. |
| Link navigation | `toHaveURL(/#about$/)`, `toContainText('About')` | Positive assertion | Confirms the required link works and navigates to the about section. |
| Text input | `toHaveValue('Yonatan')` | Positive assertion | Confirms the required text input accepts user-entered text. |
| Valid submit | `toHaveText('Hello, Yonatan. Your JSP form submission worked.')` | Positive assertion | Confirms the JSP form accepts valid input and renders the success message. |
| Empty submit | `toHaveText('Please enter a name before submitting.')` | Negative validation assertion | Confirms the app rejects an empty submission and shows validation feedback instead of a success message. |

## Local Execution

Run from the repository root after Tomcat is deployed:

```sh
./scripts/deploy-war
./scripts/run-playwright-container
```

The local runner starts the official Playwright image with direct `docker run`, mounts the repository at `/work`, installs dependencies with `npm ci` inside that disposable container, and runs `npx playwright test`.

## Jenkins Execution

The source-controlled `Jenkinsfile` already contains stage `Playwright Functional Test`. That stage runs only for non-timer builds and executes:

```sh
./scripts/run-playwright-container
```

Jenkins mounts the host Docker socket and uses Docker Pipeline to start the same official Playwright container used by local execution. The Pipeline passes `--network meta`, `--volumes-from meta-jenkins`, and working directory `env.WORKSPACE`, so the disposable Playwright container runs from the checked-out SCM workspace and writes evidence back under `output/playwright/`.

This 2026-06-10 Plan 06 follow-up replaces the original Jenkins execution path where Node, npm, and Debian Chromium were installed directly inside the Jenkins image. Jenkins now orchestrates the official Playwright container instead.

The Jenkins post-build behavior publishes `output/playwright/junit.xml` through the Jenkins JUnit publisher and `output/playwright/playwright-report/index.html` through HTML Publisher when those files exist. The raw files are still archived under `output/**/*`.

## Evidence Files

Generated evidence is ignored by Git and should be archived by Jenkins or attached manually for submission:

- `output/playwright/06-playwright-run.log`
- `output/playwright/junit.xml`
- `output/playwright/playwright-report/index.html`
- `output/playwright/screenshots/06-valid-submit.png`
- `output/playwright/screenshots/06-empty-submit.png`

## Known Assignment Override

`final-project.pdf` names Selenium IDE `.side` as the browser automation deliverable. This project uses Playwright under the accepted override documented in `rules/compliance.md`. Keep this mismatch visible during defense because the lecturer may still ask why Selenium IDE was not used.
