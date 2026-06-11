# Playwright Functional Test

## Runtime

- Local command: `./scripts/run-playwright-container`
- Jenkins command: `./scripts/run-playwright-container` from the `Playwright Functional Test` stage in `Jenkinsfile`
- Local default container image: `mcr.microsoft.com/playwright:v1.60.0-noble`
- Local container runner: direct disposable `docker run`
- Jenkins container runner: Jenkins Docker Pipeline using `docker.image(env.PLAYWRIGHT_IMAGE).inside(...)`
- Default Docker network: `meta`
- Local default app URL from the Playwright container: `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Jenkins default app URL from the Playwright container: `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Jenkins runner container: `meta-jenkins`
- Default disposable Playwright container name: `meta-playwright-${BUILD_NUMBER:-local}`
- Host browser URL for manual checks: `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

The runner keeps `APP_BASE_URL` configurable. Override it only when the Tomcat target changes for a real environment, for example a public-IP bonus target. The disposable container name is configurable with `PLAYWRIGHT_CONTAINER_NAME`; by default local runs use `meta-playwright-local` and Jenkins runs use `meta-playwright-<build-number>`.

Playwright validation runs through a fresh disposable container each time. The functional test and HAR capture intentionally do not reuse the same Playwright container, so filesystem, browser cache, and test output state cannot leak between validation stages.

## Functional Validations

The test file is `tests/playwright/meta-functional.spec.js`. It contains one browser test with exactly five assignment-facing validation steps. The test uses hard assertions for flow gates and final outcomes, and verify-style soft assertions for independent checks that should be reported without stopping the rest of the flow immediately.

1. Page shell visibility: loads the configured app root, checks `#pageTitle` text equals `MeTA`, and verifies `#submitButton` and `#nameInput` are visible.
2. Link navigation: clicks `#aboutLink`, checks the URL ends with `#about`, and verifies `#about` contains `About`.
3. Text input: fills `#nameInput` with `Yonatan` and verifies the input value.
4. Valid submit: clicks `#submitButton`, verifies `#resultMessage` equals `Hello, Yonatan. MeTA Corporate reviewed your form, opened a committee, and somehow approved it.`, and captures `output/playwright/screenshots/valid-submit.png`.
5. Empty submit: reloads the configured app root, submits an empty form, verifies `#validationMessage` equals `Please enter a name before MeTA Corporate schedules a meeting about the empty box.`, and captures `output/playwright/screenshots/empty-submit.png`.

## Assert And Verify Strategy

Playwright has both assertion styles needed to explain the assignment requirement:

- `expect(...)` is equivalent to Selenium IDE `assert`: if it fails, Playwright stops the current test immediately.
- `expect.soft(...)` is equivalent to Selenium IDE `verify`: if it fails, Playwright records the failure and continues the test, then still fails the test at the end.

This project uses hard assertions for prerequisites and critical outcomes where continuing would produce misleading evidence. It uses soft assertions for independent checks where it is useful to collect more evidence from the same run. After the link-navigation step, the test reloads the app root before form validation so a soft link failure cannot cascade into unrelated input and submit failures.

| Step | Playwright assertion | Validation type | Reason |
|------|----------------------|-----------------|--------|
| Page shell visibility | `expect(...).toHaveText('MeTA')`, `expect.soft(...).toContainText(...)`, `expect(...).toBeVisible()` | Positive assert plus verify | Hard-asserts the page loaded and required controls exist; soft-verifies supporting page copy so the run can continue and still report copy drift. |
| Link navigation | `expect.soft(page).toHaveURL(/#about$/)`, `expect.soft(...).toContainText('About')` | Positive verify | Verifies the required link behavior while allowing later input and submit validations to run; the next step reloads the app root to avoid cascading failures. |
| Text input | `expect(...).toHaveValue('Yonatan')` | Positive assert | Confirms the required text input accepts user-entered text. This is a core interaction, so failure should stop the test. |
| Valid submit | `expect(...).toHaveText('Hello, Yonatan. MeTA Corporate reviewed your form, opened a committee, and somehow approved it.')` | Positive assert | Confirms the JSP form accepts valid input and renders the success message. This is a final outcome, so failure should stop the test. |
| Empty submit | `expect(...).toHaveText('Please enter a name before MeTA Corporate schedules a meeting about the empty box.')` | Negative assert | Confirms the app rejects an empty submission and shows validation feedback instead of a success message. This is the negative test, so failure should stop the test. |

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

The Jenkins post-build behavior publishes `output/playwright/junit.xml` through the Jenkins JUnit publisher and publishes the Jenkins-safe static report at `output/playwright/jenkins-report/index.html` through HTML Publisher when those files exist. The native Playwright report at `output/playwright/playwright-report/index.html` is still archived under `output/**/*`, but it is not linked from the Jenkins-safe report because Jenkins can block the JavaScript needed by Playwright's native HTML app.

## Evidence Files

Generated evidence is ignored by Git and should be archived by Jenkins or attached manually for submission:

- `output/playwright/playwright-run.log`
- `output/playwright/junit.xml`
- `output/playwright/jenkins-report/index.html`
- `output/playwright/jenkins-report/playwright-jenkins-report.css`
- `output/playwright/playwright-report/index.html`
- `output/playwright/screenshots/valid-submit.png`
- `output/playwright/screenshots/empty-submit.png`

## Known Assignment Override

`final-project.pdf` names Selenium IDE `.side` as the browser automation deliverable. This project uses Playwright under the accepted override documented in `rules/compliance.md`. Keep this mismatch visible during defense because the lecturer may still ask why Selenium IDE was not used.
