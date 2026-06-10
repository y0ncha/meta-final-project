---
goal: Capture and document a real HAR file for the JSP application flow
version: 1.0
date_created: 2026-06-10
last_updated: 2026-06-10
owner: Yonatan
status: 'Completed'
tags:
  - devops
  - har
  - browser-automation
  - evidence
  - submission
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

This plan implements the HAR deliverable required by `final-project.pdf` and `rules/compliance.md`. The result must provide a written scenario description in `docs/har-scenario.md`, a real HAR file captured from the JSP application flow, a repeatable Dockerized Playwright capture command, and validation that the HAR contains requests for the deployed application at `http://localhost:8080/meta/` or `http://tomcat:8080/meta/`.

## 1. Requirements & Constraints

- **REQ-001**: Capture a real HAR file for the JSP application served at `http://localhost:8080/meta/` from the host and `http://tomcat:8080/meta/` from Docker network `meta`.
- **REQ-002**: Document the exact HAR scenario in `docs/har-scenario.md` using the assignment-facing flow: open the app, click the about link, type text into the name input, click the submit button, and observe the success result.
- **REQ-003**: Align the HAR scenario with existing JSP selectors in `src/main/webapp/index.jsp`: `#aboutLink`, `#nameInput`, `#submitButton`, and `#resultMessage`.
- **REQ-004**: Align the HAR scenario with the existing Playwright functional flow in `tests/playwright/meta-functional.spec.js`.
- **REQ-005**: Save the captured HAR file at `output/har/meta-functional-flow.har`.
- **REQ-006**: Capture full HAR content with embedded response bodies by using Playwright HAR recording option `content: 'embed'` and `mode: 'full'`.
- **REQ-007**: Keep the target URL configurable through environment variable `APP_BASE_URL`; default automated Docker capture to `http://tomcat:8080/meta/` because the capture runner joins Docker network `meta`.
- **REQ-008**: Keep the generated HAR file ignored by Git under `output/`; commit only source files, scripts, documentation, and plan/changelog files.
- **REQ-009**: Validate that `output/har/meta-functional-flow.har` is valid JSON with top-level object `log`, array `log.entries`, and at least one request URL whose pathname starts with `/meta/`.
- **REQ-010**: Validate that the HAR scenario document and captured HAR file describe the same user flow and same target application.
- **SEC-001**: Treat HAR files as potentially sensitive because they may contain URLs, request headers, response headers, cookies, cache metadata, and embedded response content.
- **SEC-002**: Do not commit generated HAR files, browser traces, credentials, API tokens, cookies, private keys, `.env`, Jenkins secrets, or other sensitive runtime evidence.
- **CON-001**: Read and obey `contribution.md` before implementation; keep this work on branch `feature/07-har-capture`.
- **CON-002**: Do not change the Tomcat context path from `meta` in this plan.
- **CON-003**: Do not modify Gatling, monitoring, public-IP bonus, or submission-package implementation in this plan except for links or references needed by Plan 07.
- **CON-004**: Do not install Playwright, Node packages, or browsers on the host machine. Use the existing Dockerized Playwright dependency path.
- **CON-005**: Do not rely on Chrome DevTools manual export as the primary path unless Playwright HAR capture is blocked and the blocker is documented.
- **GUD-001**: Prefer deterministic automated HAR capture over manual browser export because it is easier to rerun, validate, and defend during the live project defense.
- **GUD-002**: Keep `docs/har-scenario.md` written in plain language suitable for the final submission email.
- **PAT-001**: Follow the existing script pattern from `scripts/run-playwright-container`: executable from the project root, explicit environment variables, Dockerized execution, deterministic defaults, and clear failure messages.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Add an automated Playwright HAR capture flow that reuses the deployed JSP application and Docker network.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Create executable script `scripts/capture-har` with shebang `#!/usr/bin/env sh` and `set -eu`. | ✅ | 2026-06-10 |
| TASK-002 | In `scripts/capture-har`, define `PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"`, `PLAYWRIGHT_IMAGE="${PLAYWRIGHT_IMAGE:-mcr.microsoft.com/playwright:v1.60.0-noble}"`, `PLAYWRIGHT_NETWORK="${PLAYWRIGHT_NETWORK:-meta}"`, `APP_BASE_URL="${APP_BASE_URL:-http://tomcat:8080/meta/}"`, `HAR_PATH="${HAR_PATH:-output/har/meta-functional-flow.har}"`, `LOG_FILE="${LOG_FILE:-output/har/07-har-capture.log}"`, and `HAR_CONTAINER_NAME="${HAR_CONTAINER_NAME:-meta-har-${BUILD_NUMBER:-local}}"`. | ✅ | 2026-06-10 |
| TASK-003 | In `scripts/capture-har`, create directory `output/har/` before running the capture. | ✅ | 2026-06-10 |
| TASK-004 | In `scripts/capture-har`, require Docker with `command -v docker >/dev/null 2>&1`; print `Docker is required to capture HAR in the Playwright container.` to stderr and exit `127` when Docker is missing. | ✅ | 2026-06-10 |
| TASK-005 | In `scripts/capture-har`, run `docker run --rm --name "$HAR_CONTAINER_NAME" --network "$PLAYWRIGHT_NETWORK" -v "$PROJECT_ROOT:/work" -w /work -e APP_BASE_URL="$APP_BASE_URL" -e HAR_PATH="$HAR_PATH" -e CI=true "$PLAYWRIGHT_IMAGE" /bin/bash -lc 'npm ci && node tests/playwright/capture-har.js'` and write combined stdout/stderr to `$LOG_FILE` while preserving the container exit code. | ✅ | 2026-06-10 |
| TASK-006 | In `scripts/capture-har`, after a successful capture, print the exact evidence paths `output/har/07-har-capture.log` and `output/har/meta-functional-flow.har`. | ✅ | 2026-06-10 |
| TASK-007 | Mark `scripts/capture-har` executable with `chmod +x scripts/capture-har`. | ✅ | 2026-06-10 |
| TASK-008 | Create `tests/playwright/capture-har.js` that imports `chromium` and `expect` from `@playwright/test`, imports `fs` from `node:fs`, imports `path` from `node:path`, and exits nonzero on any failed assertion or browser error. | ✅ | 2026-06-10 |
| TASK-009 | In `tests/playwright/capture-har.js`, define `appBaseUrl = process.env.APP_BASE_URL || 'http://localhost:8080/meta/'` and `harPath = process.env.HAR_PATH || 'output/har/meta-functional-flow.har'`; create `path.dirname(harPath)` recursively before browser launch. | ✅ | 2026-06-10 |
| TASK-010 | In `tests/playwright/capture-har.js`, launch Chromium, create a browser context with `recordHar: { path: harPath, content: 'embed', mode: 'full' }`, create one page, and run the scenario against `appBaseUrl`. | ✅ | 2026-06-10 |
| TASK-011 | In `tests/playwright/capture-har.js`, implement the scenario exactly: `page.goto(appBaseUrl, { waitUntil: 'networkidle' })`, `page.locator('#aboutLink').click()`, assert the URL ends with `#about`, fill `#nameInput` with `Yonatan`, click `#submitButton`, assert `#resultMessage` has text `Hello, Yonatan. Your JSP form submission worked.`, close the context, and close the browser. | ✅ | 2026-06-10 |
| TASK-012 | In `tests/playwright/capture-har.js`, after closing the context, verify `fs.statSync(harPath).size > 0`; throw an error containing `HAR file was not created or is empty` when the file is missing or empty. | ✅ | 2026-06-10 |

### Implementation Phase 2

- GOAL-002: Add validation and documentation for the generated HAR evidence.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-013 | Create executable script `scripts/validate-har` with shebang `#!/usr/bin/env node`. | ✅ | 2026-06-10 |
| TASK-014 | In `scripts/validate-har`, read the HAR path from `process.argv[2] || 'output/har/meta-functional-flow.har'` and fail with exit code `64` when no readable file exists at that path. | ✅ | 2026-06-10 |
| TASK-015 | In `scripts/validate-har`, parse the HAR as JSON and fail with exit code `65` when parsing fails or when `har.log.entries` is not an array. | ✅ | 2026-06-10 |
| TASK-016 | In `scripts/validate-har`, require at least one entry whose `request.url` parses as a URL and whose `pathname` starts with `/meta/`; fail with exit code `66` when no matching request exists. | ✅ | 2026-06-10 |
| TASK-017 | In `scripts/validate-har`, require at least one entry whose `response.content` object exists and has either a non-empty `text` string or a numeric `size`; fail with exit code `67` when content evidence is missing. | ✅ | 2026-06-10 |
| TASK-018 | In `scripts/validate-har`, print a single success line in the exact format `Validated HAR: <path> entries=<count> metaRequests=<count>`. | ✅ | 2026-06-10 |
| TASK-019 | Mark `scripts/validate-har` executable with `chmod +x scripts/validate-har`. | ✅ | 2026-06-10 |
| TASK-020 | Create `docs/har-scenario.md` with sections `Target`, `Scenario Steps`, `Capture Command`, `Evidence Files`, `Validation`, `Submission Notes`, and `Sensitivity Review`. | ✅ | 2026-06-10 |
| TASK-021 | In `docs/har-scenario.md` section `Target`, document host URL `http://localhost:8080/meta/` and Docker-network URL `http://tomcat:8080/meta/`. | ✅ | 2026-06-10 |
| TASK-022 | In `docs/har-scenario.md` section `Scenario Steps`, list exactly five numbered steps: open the app, click `About this app`, type `Yonatan` in the `Name` input, click `Submit`, and observe `Hello, Yonatan. Your JSP form submission worked.` | ✅ | 2026-06-10 |
| TASK-023 | In `docs/har-scenario.md` section `Capture Command`, document command `./scripts/capture-har` and override example `APP_BASE_URL=http://host.docker.internal:8080/meta/ PLAYWRIGHT_NETWORK=bridge ./scripts/capture-har` only if the capture container cannot reach Docker network service name `tomcat`. | ✅ | 2026-06-10 |
| TASK-024 | In `docs/har-scenario.md` section `Evidence Files`, list `output/har/meta-functional-flow.har` and `output/har/07-har-capture.log`. | ✅ | 2026-06-10 |
| TASK-025 | In `docs/har-scenario.md` section `Sensitivity Review`, state that the HAR must be reviewed before external sharing because it may include headers, cookies, and embedded response content. | ✅ | 2026-06-10 |

### Implementation Phase 3

- GOAL-003: Validate capture, update the plan checklist, and record completion evidence.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-026 | Run `sh -n scripts/capture-har` and fix any shell syntax errors before running Docker commands. | ✅ | 2026-06-10 |
| TASK-027 | Run `node --check tests/playwright/capture-har.js` and fix any JavaScript syntax errors. | ✅ | 2026-06-10 |
| TASK-028 | Run `node --check scripts/validate-har` and fix any JavaScript syntax errors. | ✅ | 2026-06-10 |
| TASK-029 | Run `docker compose up -d tomcat` and verify the Tomcat container is running with `docker compose ps tomcat`. | ✅ | 2026-06-10 |
| TASK-030 | Run `./scripts/deploy-war` and verify it prints `Deployed URL: http://localhost:8080/meta/`. | ✅ | 2026-06-10 |
| TASK-031 | Run `./scripts/capture-har` and verify it exits `0`. | ✅ | 2026-06-10 |
| TASK-032 | Run `./scripts/validate-har output/har/meta-functional-flow.har` and verify it prints `Validated HAR: output/har/meta-functional-flow.har entries=<count> metaRequests=<count>`. | ✅ | 2026-06-10 |
| TASK-033 | Run `test -s output/har/meta-functional-flow.har` and verify it exits `0`. | ✅ | 2026-06-10 |
| TASK-034 | Run `test -s output/har/07-har-capture.log` and verify it exits `0`. | ✅ | 2026-06-10 |
| TASK-035 | Run `git check-ignore output/har/meta-functional-flow.har` and verify it prints `output/har/meta-functional-flow.har`. | ✅ | 2026-06-10 |
| TASK-036 | Manually review `output/har/meta-functional-flow.har` for secrets, cookies, credentials, or unrelated domains before using it in the final submission package. | ✅ | 2026-06-10 |
| TASK-037 | Run `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md` and manually inspect all `manual` items before marking the plan complete. | ✅ | 2026-06-10 |
| TASK-038 | Create `docs/changelog/07-har-capture.changelog.md` with what changed, why it changed, exact validation commands, generated evidence paths, and remaining risks. | ✅ | 2026-06-10 |
| TASK-039 | Update this plan's front matter status to `Completed`, update the badge color to `brightgreen`, and mark completed tasks with date `2026-06-10` only after TASK-026 through TASK-038 pass. | ✅ | 2026-06-10 |

## 3. Alternatives

- **ALT-001**: Export the HAR manually from Chrome DevTools. Rejected as the primary path because manual export is harder to reproduce, harder to run during defense, and easier to capture the wrong browser state. It remains an emergency fallback only if Playwright HAR recording is blocked and the blocker is documented.
- **ALT-002**: Commit `output/har/meta-functional-flow.har` to Git. Rejected because HAR files can contain sensitive request metadata and generated evidence is intentionally ignored under `output/`.
- **ALT-003**: Reuse the Plan 06 functional Playwright test and enable HAR globally in `playwright.config.js`. Rejected because global HAR recording would affect unrelated Playwright runs and create extra generated evidence when only the HAR deliverable needs it.
- **ALT-004**: Capture a summary-only HAR without embedded content. Rejected because the plan requires full evidence and `rules/compliance.md` requires real artifacts over prose claims.
- **ALT-005**: Add HAR capture to the Jenkins pipeline immediately. Rejected for this plan because the assignment requires the HAR file and scenario description, not a scheduled HAR stage; Jenkins integration can be added later only if the submission workflow needs archived HAR artifacts.

## 4. Dependencies

- **DEP-001**: `final-project.pdf` remains the authoritative assignment source; `rules/compliance.md` is the active operational checklist derived from it.
- **DEP-002**: `contribution.md` defines branch, plan rewrite, validation, and changelog workflow.
- **DEP-003**: Docker Compose service `tomcat` must serve the app on Docker network `meta` with service DNS name `tomcat`.
- **DEP-004**: `scripts/deploy-war` must deploy `target/meta.war` to Tomcat before HAR capture runs.
- **DEP-005**: `package.json` and `package-lock.json` from Plan 06 must remain valid so `npm ci` succeeds inside `mcr.microsoft.com/playwright:v1.60.0-noble`.
- **DEP-006**: Browser selectors in `src/main/webapp/index.jsp` must remain stable: `#aboutLink`, `#nameInput`, `#submitButton`, and `#resultMessage`.
- **DEP-007**: Docker must be able to pull or reuse local image `mcr.microsoft.com/playwright:v1.60.0-noble`.

## 5. Files

- **FILE-001**: `docs/plans/07-har-capture.md` - this executable implementation plan.
- **FILE-002**: `scripts/capture-har` - Dockerized Playwright HAR capture runner.
- **FILE-003**: `tests/playwright/capture-har.js` - browser automation script that records the HAR.
- **FILE-004**: `scripts/validate-har` - Node-based HAR structure and request validator.
- **FILE-005**: `docs/har-scenario.md` - plain-language HAR scenario documentation for final submission.
- **FILE-006**: `docs/changelog/07-har-capture.changelog.md` - completion record created after validation.
- **FILE-007**: `output/har/meta-functional-flow.har` - generated ignored HAR evidence for final submission attachment.
- **FILE-008**: `output/har/07-har-capture.log` - generated ignored command log for local evidence.

## 6. Testing

- **TEST-001**: `sh -n scripts/capture-har` must pass.
- **TEST-002**: `node --check tests/playwright/capture-har.js` must pass.
- **TEST-003**: `node --check scripts/validate-har` must pass.
- **TEST-004**: `docker compose up -d tomcat` must start the Tomcat service.
- **TEST-005**: `./scripts/deploy-war` must deploy the app and print `Deployed URL: http://localhost:8080/meta/`.
- **TEST-006**: `./scripts/capture-har` must pass and create `output/har/meta-functional-flow.har`.
- **TEST-007**: `./scripts/validate-har output/har/meta-functional-flow.har` must pass.
- **TEST-008**: `test -s output/har/meta-functional-flow.har` must pass.
- **TEST-009**: `test -s output/har/07-har-capture.log` must pass.
- **TEST-010**: `git check-ignore output/har/meta-functional-flow.har` must print `output/har/meta-functional-flow.har`.
- **TEST-011**: `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md` must report no unreviewed failures before completion.
- **TEST-012**: `git diff --check` must pass before commit.

## 7. Risks & Assumptions

- **RISK-001**: HAR files can contain sensitive request and response data; the generated HAR must be reviewed before it is attached to the final email.
- **RISK-002**: Docker image pull for `mcr.microsoft.com/playwright:v1.60.0-noble` can fail if the machine is offline or the registry is unavailable; rerun when network access is available and document the blocker if it persists.
- **RISK-003**: Browser HAR capture depends on stable JSP IDs; changing IDs in `src/main/webapp/index.jsp` requires updating `tests/playwright/capture-har.js`, `docs/har-scenario.md`, and this plan.
- **RISK-004**: The default Docker-network URL `http://tomcat:8080/meta/` will fail if the capture container does not join network `meta`; set `PLAYWRIGHT_NETWORK=meta` or document the local network blocker.
- **RISK-005**: A HAR captured against `http://tomcat:8080/meta/` proves the same app flow inside Docker but does not show a browser address bar; final submission still needs the separate Tomcat screenshot with `http://localhost:8080/meta/` visible.
- **ASSUMPTION-001**: The Tomcat app remains deployed at context path `/meta/`.
- **ASSUMPTION-002**: Docker Compose project name remains `meta`, preserving Docker network name `meta`.
- **ASSUMPTION-003**: Plan 06 remains implemented, so `package.json`, `package-lock.json`, and the official Playwright container path are available.
- **ASSUMPTION-004**: Generated evidence remains ignored by `.gitignore` and is attached manually or archived separately rather than committed.

## 8. Related Specifications / Further Reading

- [Final project compliance rules](../../rules/compliance.md)
- [Contribution workflow](../../contribution.md)
- [Playwright container functional test plan](./06-playwright-container-functional-test.md)
- [Gatling container tests plan](./08-gatling-container-tests.md)
- [Submission package plan](./11-submission-package.md)
- [JSP application source](../../src/main/webapp/index.jsp)
