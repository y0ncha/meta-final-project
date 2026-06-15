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

The test file is `tests/playwright/meta-functional.spec.js`. It contains one app-specific browser flow with exactly five assignment-facing validations and one Playwright `expect` per validation. It does not copy the login exercise from Lecture 8; it applies the same rationale to this JSP app: prove the app identity, verify supporting content, exercise one positive path, exercise one negative path, and explain when a check is an assert versus a verify.

1. Assert the app identity: opens the app and strictly asserts the browser title is `MeTA`.
2. Verify supporting About content: clicks `#aboutLink` and softly verifies `#about` contains `Maven WAR for Tomcat`.
3. Assert valid submit succeeds: types `Yonatan`, submits the form, strictly asserts the expected success message, and captures `output/playwright/screenshots/valid-submit.png`.
4. Verify empty submit does not show success: submits an empty form and softly verifies `#resultMessage` is hidden.
5. Assert empty submit shows validation text: captures `output/playwright/screenshots/empty-submit.png` and strictly asserts the expected empty-name validation message.

## Course Rationale Mapping

Lecture 8 teaches Selenium IDE through command, target, and value style actions. The project uses Playwright as the approved Selenium-like substitute. The flow is intentionally different from the lecture's login-site example, but the validation rationale uses the same assert/verify distinction:

| Step | Class rationale | Playwright action | Validation type |
|------|-----------------|-------------------|-----------------|
| Assert the app identity | Assert the app identity before trusting later evidence | `page.goto('./')`, `expect(page).toHaveTitle('MeTA')` | Positive assert, strict |
| Verify supporting About content | Verify independent page content, like Selenium IDE `click` plus `verifyTextPresent` | `click()`, `expect.soft(...).toContainText(...)` | Positive verify, soft |
| Assert valid submit succeeds | Assert the final success outcome because a wrong success message means the positive path failed | `fill('Yonatan')`, submit, `expect(...).toHaveText(...)` | Positive assert, strict |
| Verify empty submit does not show success | Verify negative-path evidence without hiding the explicit validation-message result | Empty submit, `expect.soft(...).toBeHidden()` | Negative verify, soft |
| Assert empty submit shows validation text | Assert the empty-name guardrail because accepting invalid input or showing wrong feedback breaks the negative flow | Screenshot, `expect(...).toHaveText(...)` | Negative assert, strict |

## Assert And Verify Strategy

Playwright has both assertion styles needed to explain the assignment requirement:

- `expect(...)` is equivalent to Selenium IDE `assert`: if it fails, Playwright stops the current test immediately.
- `expect.soft(...)` is equivalent to Selenium IDE `verify`: if it fails, Playwright records the failure and continues the test, then still fails the test at the end.

This project uses hard assertions when downstream business flow cannot be trusted: the app identity, the positive success message, and the empty-name validation result. It uses soft assertions for Selenium-style verify checks that should be reported without blocking the decisive form result: supporting About content and the negative check that empty submit does not show success. The test captures the empty-submit screenshot before the strict negative assertion so evidence is still available if validation is broken.

Each `expect` in `tests/playwright/meta-functional.spec.js` has a short comment with:

- `Type`: strict/assert or soft/verify.
- `What test`: the specific browser behavior or page state being checked.
- `Why this type`: the downstream impact on page or form functionality.

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
