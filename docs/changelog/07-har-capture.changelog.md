# Plan 07 - HAR Capture Changelog

Date: 2026-06-10

## Summary

Implemented repeatable HAR capture for the JSP application flow. The capture runs in the official Playwright container, records a full HAR with embedded content for the `/meta/` app flow, validates the HAR structure and request targets, and documents the scenario for the final submission package.

## What Changed

- `scripts/capture-har`: Added a Dockerized Playwright HAR capture runner with configurable `PLAYWRIGHT_IMAGE`, `PLAYWRIGHT_NETWORK`, `APP_BASE_URL`, `HAR_PATH`, and `LOG_FILE`.
- `scripts/capture-har`: Added configurable disposable container naming through `HAR_CONTAINER_NAME`, defaulting to `meta-har-${BUILD_NUMBER:-local}`.
- `tests/playwright/capture-har.js`: Added the browser scenario that opens the app, clicks the about link, enters `Yonatan`, submits the form, validates the success message, and writes `output/har/meta-functional-flow.har`.
- `scripts/validate-har`: Added a Node validator that checks HAR JSON structure, `/meta/` request URLs, and response content evidence.
- `docs/har-scenario.md`: Added the plain-language HAR scenario, capture command, validation command, evidence paths, and sensitivity warning.
- `docs/har-scenario.md`: Added `What This HAR Tests` to explain the expected GET `/meta/`, same-page `#about` fragment navigation, POST `/meta/index.jsp`, success response, and out-of-scope evidence items.
- `docs/playwright.md`: Added an assertion and validation type table explaining that Playwright `expect(...)` checks are fail-fast assertions, with positive assertions for normal behavior and one negative validation assertion for the empty-submit case.
- `docs/plans/07-har-capture.md`: Marked the implementation plan completed after validation.

## Why It Changed

The final project requires a written HAR scenario and an actual HAR file. Automated Playwright capture is the strongest default path because it is repeatable, aligned with the existing Playwright functional flow, and easier to defend live than a manual Chrome DevTools export.

## Validation

| Command | Result |
|---------|--------|
| `sh -n scripts/capture-har` | Passed. |
| `node --check tests/playwright/capture-har.js` | Passed. |
| `node --check scripts/validate-har` | Passed. |
| `docker compose up -d tomcat` | Passed with elevated Docker socket access; `meta-tomcat` was already running. |
| `docker compose ps tomcat` | Passed; `meta-tomcat` was `Up` and published `8080:8080`. |
| `./scripts/deploy-war` | Passed with elevated Docker socket access and printed `Deployed URL: http://localhost:8080/meta/`. |
| `./scripts/capture-har` | Passed with elevated Docker socket access and generated `output/har/meta-functional-flow.har`. |
| `./scripts/validate-har output/har/meta-functional-flow.har` | Passed with `entries=2` and `metaRequests=2`. |
| `test -s output/har/meta-functional-flow.har` | Passed. |
| `test -s output/har/07-har-capture.log` | Passed. |
| `git check-ignore output/har/meta-functional-flow.har` | Passed; generated HAR remains ignored by Git. |
| `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md` | Passed with `fail=0`; nine general assignment rules required manual review. |
| `npm view @playwright/test version dist-tags engines --json` | Passed with latest stable `1.60.0` and engine `node >=18`. |
| `npm install --package-lock-only --save-dev --save-exact @playwright/test@1.60.0` | Passed with `found 0 vulnerabilities`. |
| `./scripts/run-playwright-container` | Passed with Playwright container `mcr.microsoft.com/playwright:v1.60.0-noble`; functional test reported `1 passed`. |
| `./scripts/capture-har` after Playwright upgrade | Passed with Playwright container `mcr.microsoft.com/playwright:v1.60.0-noble` and `found 0 vulnerabilities`. |

## Evidence

- Generated HAR: `output/har/meta-functional-flow.har`
- Capture log: `output/har/07-har-capture.log`
- Scenario document: `docs/har-scenario.md`
- Validator output: `Validated HAR: output/har/meta-functional-flow.har entries=2 metaRequests=2`
- Captured request URLs reviewed: `http://tomcat:8080/meta/` and `http://tomcat:8080/meta/index.jsp`

## Sensitivity Review

The HAR contains the expected local Tomcat `JSESSIONID` cookie for the JSP session. No credentials, API tokens, private keys, authorization headers, or unrelated domains were found by the review search. Keep `output/har/meta-functional-flow.har` out of Git and review it again before attaching it to the final email.

## Remaining Risks

- The HAR uses Docker-network URL `http://tomcat:8080/meta/`; the separate final Tomcat screenshot still needs a browser address bar showing `http://localhost:8080/meta/`.
- The assignment PDF names Selenium IDE, while this project uses Playwright under the documented accepted override in `rules/compliance.md`.

## 2026-06-10 Compose One-Shot Runner Follow-Up

- Updated `scripts/capture-har` to launch profiled Compose one-shot service `har-runner` instead of invoking raw `docker run`.
- Added Jenkins-specific Compose service `har-runner-jenkins` so Jenkins-side HAR capture can inherit the Jenkins workspace volumes.
- Kept HAR capture isolated from the Playwright functional-test container so browser cache, test output, and temporary files cannot affect HAR validation evidence.
