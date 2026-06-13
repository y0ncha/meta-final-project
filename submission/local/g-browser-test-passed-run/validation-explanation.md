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

The test file is `tests/playwright/meta-functional.spec.js`. It contains one app-specific browser flow with exactly five assignment-facing validation steps. It does not copy the login exercise from Lecture 8; it applies the same rationale to this JSP app: open the app, check required UI, exercise one positive path, exercise one negative path, and explain when a check is an assert versus a verify.

1. Open app and assert page title: loads the configured app root, verifies browser title `MeTA`, and verifies `#pageTitle` text equals `MeTA`.
2. Verify required elements are present: verifies the assignment-required link `#aboutLink`, button `#submitButton`, and text box `#nameInput`.
3. Click about link and verify text is present: clicks `#aboutLink`, verifies the URL ends with `#about`, and verifies `#about` contains `About`.
4. Positive scenario: types `Yonatan` into `#nameInput`, submits the form, asserts `#resultMessage` equals `Hello, Yonatan. MeTA Corporate reviewed your form, opened a committee, and somehow approved it.`, and captures `output/playwright/screenshots/valid-submit.png`.
5. Negative scenario: reloads the configured app root, submits an empty form, verifies `#validationMessage` equals `Please enter a name before MeTA Corporate schedules a meeting about the empty box.`, and captures `output/playwright/screenshots/empty-submit.png`.

## Course Rationale Mapping

Lecture 8 teaches Selenium IDE through command, target, and value style actions. The project uses Playwright as the approved Selenium-like substitute. The flow is intentionally different from the lecture's login-site example, but the validation rationale uses the same assert/verify distinction:

| Step | Class rationale | Playwright action | Validation type |
|------|-----------------|-------------------|-----------------|
| Open app and assert page title | Assert the app identity before trusting later evidence | `page.goto('./')`, `expect(page).toHaveTitle('MeTA')` | Positive assert |
| Verify required elements are present | Verify assignment-required UI elements are present, like Selenium IDE `verifyElementPresent` | `expect.soft(...).toBeVisible()` for link, button, and text box | Positive verify |
| Click about link and verify text is present | Verify independent navigation/text behavior, like Selenium IDE `click` plus `verifyTextPresent` | `click()`, `expect.soft(...).toContainText('About')` | Positive verify |
| Positive scenario | Assert the final success outcome because a wrong success message means the positive path failed | `fill('Yonatan')`, submit, `expect(...).toHaveText(...)` | Positive assert plus verify |
| Negative scenario | Verify the error message, matching the lecture's negative-test rationale | Empty submit, `expect.soft(...).toHaveText(...)` | Negative verify |

## Assert And Verify Strategy

Playwright has both assertion styles needed to explain the assignment requirement:

- `expect(...)` is equivalent to Selenium IDE `assert`: if it fails, Playwright stops the current test immediately.
- `expect.soft(...)` is equivalent to Selenium IDE `verify`: if it fails, Playwright records the failure and continues the test, then still fails the test at the end.

This project uses hard assertions for the title and positive success outcome because those are core pass/fail checkpoints. It uses soft assertions for Selenium-style verify checks: element presence, link/text presence, typed input value, and the negative error message. The test reloads the app root before the positive and negative form scenarios so one verification cannot cascade into unrelated evidence.

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
