# 08 Gatling Container Tests Changelog

- Plan: `docs/plans/08-gatling-container-tests.md`
- Implementation status: Evidence pending as of 2026-06-10
- Branch: `feature/08-gatling-container-tests`

## What Changed

- Added Dockerized Gatling execution through source-controlled runner scripts for max-limit, 5-minute load, and 5-minute stress profiles.
- Added `src/gatling/user-files/simulations/MetaSimulation.scala` with run-type selection, JSP GET/POST checks, and failure/response-time assertions.
- Added automated Gatling PDF export through the Playwright container.
- Updated Jenkins pipeline behavior to include optional max-limit execution and required load/stress stages for non-timer builds.
- Removed the earlier profiled Compose runner-service approach; `docker-compose.yml` now remains limited to long-running `tomcat` and `jenkins` services.
- Updated local Playwright, HAR, Gatling, and PDF-export runners to start disposable containers directly with `docker run`.
- Updated Jenkins Playwright, Gatling, and PDF-export execution to use Jenkins Docker Pipeline containers from the checked-out SCM workspace.
- Kept Playwright functional validation and HAR capture isolated by using separate disposable containers.
- Moved Gatling PDF export into Jenkins `post` finalization before final pipeline report generation and publishing.
- Kept local Gatling PDF export strict while allowing Jenkins finalization to export only the reports produced in builds where optional max-limit discovery is skipped.
- Cleared stale generated evidence at the start of non-timer Jenkins builds and changed the Gatling runner to normalize reports before returning assertion-failure status.
- Changed Plan 08 from completed to evidence pending because Gatling terminal/Jenkins-console screenshots and live Jenkins build evidence are still deferred.
- Escaped dynamic Jenkins job, build, branch, and timestamp values in the generated Pipeline HTML report.
- Improved the generated Pipeline HTML report rendering by moving styles into `output/reports/pipeline-report.css`, replacing run-together summary text with a metadata grid, grouping artifacts by evidence area, and rendering status badges.
- Updated Pipeline report artifact links to use the current Jenkins `BUILD_URL`, so renamed jobs such as `meta-ci-cd` do not keep old `meta-container-ci-cd` artifact URLs after a fresh build.
- Marked missing max-limit artifacts as opt-in/not-run evidence requiring `RUN_GATLING_MAX_LIMIT=true` instead of treating the manual-only stage as an unexpected missing artifact.
- Added `tests/scripts/test-generate-pipeline-report.sh` to guard the report rendering behavior.
- Added `docs/gatling.md` with runtime details, commands, evidence paths, max-limit method, and report-backed graph explanations.
- Updated `docs/submission.md` to show Gatling logs/reports/PDFs as ready while keeping the three Gatling terminal screenshots explicitly deferred.
- Fixed the Gatling runner normalization flow so logs and PDFs are not deleted when the latest raw report is copied into the stable report directory.

## Evidence Produced

- Max-limit:
  - Log: `output/gatling/max-limit/max-limit-run.log`
  - HTML report: `output/gatling/max-limit/index.html`
  - PDF: `output/gatling/max-limit/max-limit-report.pdf`
  - Result: 21,450 requests, 21,450 OK, 0 failures, p95 10 ms.
  - Conclusion: tested lower bound through the configured 5 to 50 users-per-second stepped profile; no failing threshold was crossed, so this is not a true maximum.
- Load 5m:
  - Log: `output/gatling/load-5m/load-5m-run.log`
  - HTML report: `output/gatling/load-5m/index.html`
  - PDF: `output/gatling/load-5m/load-5m-report.pdf`
  - Result: 3,000 requests, 3,000 OK, 0 failures, p95 20 ms.
- Stress 5m:
  - Log: `output/gatling/stress-5m/stress-5m-run.log`
  - HTML report: `output/gatling/stress-5m/index.html`
  - PDF: `output/gatling/stress-5m/stress-5m-report.pdf`
  - Result: 16,500 requests, 16,500 OK, 0 failures, p95 14 ms.
- Pipeline report:
  - `output/reports/pipeline-report.html`
  - `output/reports/pipeline-report.css`

Generated evidence remains ignored under `output/`. The older `08-*` generated evidence files may still exist locally from earlier runs, but the documented closeout paths use the no-prefix convention.

## Validation

- `sh -n scripts/run-gatling-container scripts/run-gatling-max-limit scripts/run-gatling-load-5m scripts/run-gatling-stress-5m scripts/export-gatling-pdfs scripts/generate-pipeline-report`
- `sh -n scripts/run-playwright-container scripts/capture-har`
- `node --check tests/playwright/export-gatling-pdfs.js`
- `node --check tests/playwright/capture-har.js`
- `docker compose config --quiet`
- Docker Pipeline-equivalent Playwright smoke with `--network meta`, `--volumes-from meta-jenkins`, and working directory `/var/jenkins_home/workspace/meta-container-ci-cd` proved the disposable container ran from the SCM workspace, matched the checked-out commit, and reached Tomcat.
- Jenkins declarative linter for `Jenkinsfile`: passed.
- `./scripts/run-playwright-container`
- `./scripts/capture-har`
- `./scripts/export-gatling-pdfs`
- `GATLING_PDF_REQUIRE_ALL=false ./scripts/export-gatling-pdfs`
- `./scripts/generate-pipeline-report`
- `sh tests/scripts/test-generate-pipeline-report.sh`
- `docker compose ps`
- `./scripts/deploy-war`
- `./scripts/run-gatling-stress-5m`
- `./scripts/export-gatling-pdfs`
- `test -s output/reports/pipeline-report.html`
- `test -s output/gatling/max-limit/index.html && test -s output/gatling/load-5m/index.html && test -s output/gatling/stress-5m/index.html`
- `test -s output/gatling/max-limit/max-limit-run.log && test -s output/gatling/load-5m/load-5m-run.log && test -s output/gatling/stress-5m/stress-5m-run.log`
- `test -s output/gatling/max-limit/max-limit-report.pdf && test -s output/gatling/load-5m/load-5m-report.pdf && test -s output/gatling/stress-5m/stress-5m-report.pdf`
- `git check-ignore output/reports/pipeline-report.html output/gatling/max-limit/index.html output/gatling/load-5m/index.html output/gatling/stress-5m/index.html output/gatling/max-limit/max-limit-report.pdf output/gatling/screenshots/max-limit-terminal.png`
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md`
  - Result: `pass=70`, `warn=0`, `manual=9`, `fail=0`.
  - Manual items were reviewed as negative-rule or defense-readiness checks. No hard compliance failure was found for this closeout.
- `git diff --check`

## 2026-06-11 Pipeline Report Rendering Follow-Up

- Reworked `scripts/generate-pipeline-report` to generate CSP-friendly external CSS for Jenkins HTML Publisher.
- Updated the `Published Artifacts` table to show short reference links such as `HTML`, `PDF`, `Log`, and `Screenshot` instead of visible full artifact paths or URLs.
- Collapsed Gatling HTML/PDF/log duplicates into one row per Gatling run, with multiple reference links in that row.
- Verified the CSS rendering pass through Browser over a temporary localhost server; computed styles showed the stylesheet applied, status badges rendered with badge backgrounds, the metadata grid existed, and artifact links pointed at `http://localhost:8081/job/meta-ci-cd/164/artifact/...`.
- Verified the later short-reference table change with `sh tests/scripts/test-generate-pipeline-report.sh` and direct generated HTML inspection. A second Browser refresh could not be completed because the temporary localhost server did not accept connections from the browser session.
- The current Jenkins build `#164` still shows the older archived report until a fresh Jenkins build publishes the regenerated `output/reports` files.

## 2026-06-10 Documentation Drift Cleanup

- Removed stale closeout wording that still described profiled Compose runner services as the current Plan 08 execution model.
- Removed obsolete profiled Compose validation entries from the active validation list.
- Kept the remaining evidence-pending status unchanged because Gatling terminal/Jenkins-console screenshots and live Jenkins build-page evidence are still required.

## Remaining Risks And Follow-Up

- The three Gatling terminal or Jenkins-console screenshots are not captured yet:
  - `output/gatling/screenshots/max-limit-terminal.png`
  - `output/gatling/screenshots/load-5m-terminal.png`
  - `output/gatling/screenshots/stress-5m-terminal.png`
- These screenshot files remain required before sending the final email submission. This deferral is intentionally documented in `docs/submission.md`.
- Plan 08 must not be treated as complete or merge-ready until the deferred screenshot and live Jenkins evidence is captured.
- Live Jenkins build-page evidence should be refreshed before final submission so the published Gatling report links are visible in Jenkins.
- The max-limit result is a tested lower bound, not a proven maximum, because the configured stepped run did not hit a failing threshold.
