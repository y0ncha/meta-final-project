# 06 - Playwright Container Functional Test Changelog

## Completed Plan

- Plan: `docs/plans/06-playwright-container-functional-test.md`
- Status: Completed
- Completed: 2026-06-10

## What Changed

- Added Playwright project metadata in `package.json` and deterministic dependency lock in `package-lock.json`.
- Added `playwright.config.js` with reports under `output/playwright/` and configurable `APP_BASE_URL`.
- Added `tests/playwright/meta-functional.spec.js` with exactly five functional validations for the JSP app:
  1. Page shell visibility.
  2. About-link navigation.
  3. Text input entry.
  4. Valid submit success message.
  5. Empty submit validation message.
- Added `scripts/run-playwright-container` for local and Jenkins execution through the official Playwright container.
- Updated `docker-compose.yml` so Jenkins mounts `/var/run/docker.sock` for disposable test containers.
- Updated `ops/jenkins/Dockerfile` so Jenkins includes Docker CLI support, `curl`, and `maven`; Playwright Node/npm/Chromium dependencies live in the official Playwright image.
- Added `docs/playwright.md` and updated `docs/jenkins.md` with runtime, evidence, and assignment-override details.

## Why It Changed

Plan 06 satisfies the browser automation deliverable from `final-project.pdf` using the approved Playwright override documented in `rules/compliance.md`. The 2026-06-10 follow-up moved Jenkins to the same official Playwright-container execution model used locally, because the user prioritized the simplest operational model for this coursework stack.

## Validation Performed

- `sh -n scripts/run-playwright-container`
- `node -e "require('./playwright.config.js')"`
- `git diff --check`
- `docker run --rm -v "$PWD:/work" -w /work node:22-bookworm npm install --package-lock-only`
- `docker compose build jenkins`
- `docker compose up -d tomcat jenkins`
- `docker compose ps`
- `docker compose exec -T jenkins docker version`
- `docker compose exec -T jenkins sh -lc 'command -v docker && command -v node || true && command -v npm || true && command -v chromium || true'`
- `./scripts/deploy-war`
- `curl -fsS http://localhost:8080/meta/ >/dev/null`
- `docker compose exec -T jenkins curl -fsS http://tomcat:8080/meta/ >/dev/null`
- `./scripts/run-playwright-container`
- `docker compose exec -T jenkins sh -lc 'cd /workspace/final-project && ./scripts/run-playwright-container'`
- `test -s output/playwright/06-playwright-run.log && test -s output/playwright/junit.xml && test -s output/playwright/playwright-report/index.html && test -s output/playwright/screenshots/06-valid-submit.png && test -s output/playwright/screenshots/06-empty-submit.png`
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md`
- `docker compose config`

## Evidence

- Local Playwright run passed: `1 passed`.
- Jenkins-triggered official Playwright container run passed: `1 passed`.
- Required ignored evidence files were generated:
  - `output/playwright/06-playwright-run.log`
  - `output/playwright/junit.xml`
  - `output/playwright/playwright-report/index.html`
  - `output/playwright/screenshots/06-valid-submit.png`
  - `output/playwright/screenshots/06-empty-submit.png`
- Compliance validator result: `pass=70`, `warn=0`, `manual=9`, `fail=0`.
- Manual compliance review confirmed the Docker socket mount is limited to Jenkins disposable test-container orchestration and no public-IP bonus evidence is claimed.

## 2026-06-10 Follow-Up

- Folded the Playwright runner simplification into Plan 06 instead of tracking it as a standalone plan.
- Jenkins now starts `mcr.microsoft.com/playwright:v1.60.0-noble` through Docker socket access.
- Local and Jenkins Playwright paths both execute `npm ci && npx playwright test` inside the official Playwright container.
- Debian package `docker.io` did not provide `docker` on `PATH` in the Jenkins image during validation, so the original Plan 06 follow-up used `docker-cli`. The later Jenkins tooling follow-up supersedes that package with Docker's official `docker-ce-cli` plus `docker-compose-plugin`.

## 2026-06-10 Playwright Version Follow-Up

- Upgraded `@playwright/test` from `1.52.0` to exact version `1.60.0` after checking the latest npm `latest` dist-tag.
- Updated the default official Playwright container image from `mcr.microsoft.com/playwright:v1.52.0-noble` to `mcr.microsoft.com/playwright:v1.60.0-noble`.
- Verified the npm package engine requirement is `node >=18`; the current local Node runtime is `v22.15.0`.
- Verified `npm install --package-lock-only --save-dev --save-exact @playwright/test@1.60.0` completed with `found 0 vulnerabilities`.
- Verified `./scripts/run-playwright-container` passed against Tomcat with `mcr.microsoft.com/playwright:v1.60.0-noble`; the functional test reported `1 passed`.
- Verified `docker compose exec -T jenkins sh -lc 'cd /workspace/final-project && ./scripts/run-playwright-container'` passed with `mcr.microsoft.com/playwright:v1.60.0-noble`; the Jenkins-container path reported `1 passed`.
- Added configurable disposable container names through `PLAYWRIGHT_CONTAINER_NAME`, defaulting to `meta-playwright-${BUILD_NUMBER:-local}`.

## 2026-06-10 Jenkins Report Publishing Follow-Up

- Updated `Jenkinsfile` so Playwright JUnit evidence at `output/playwright/junit.xml` is published through Jenkins JUnit reporting when present.
- Updated `Jenkinsfile` so Playwright HTML evidence at `output/playwright/playwright-report/index.html` is published through HTML Publisher when present.
- Kept Playwright execution inside the official Playwright container; no Playwright-specific Jenkins plugin was added.
- Verified Jenkins declarative linter accepted the updated `Jenkinsfile`.
- Verified Jenkins image plugins include `htmlpublisher`; raw Playwright evidence remains archived through `output/**/*`.

## Remaining Risks And Follow-Up

- `final-project.pdf` names Selenium IDE `.side`; Playwright remains an explicit accepted override and should be explained during defense if asked.
- Browser screenshots under `output/playwright/` do not replace the final submission screenshot that must show `http://localhost:8080/meta/` in the browser address bar.
- Plans 07 through 11 remain required for HAR, Gatling, monitoring, and final submission packaging.
- Jenkins now has broad Docker host control through `/var/run/docker.sock`; this is an accepted coursework simplicity tradeoff, not a production recommendation.
