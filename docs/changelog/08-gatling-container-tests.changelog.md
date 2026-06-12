# 08 Gatling Container Tests Changelog

- Plan: `docs/plans/08-gatling-container-tests.md`
- Implementation status: Evidence pending as of 2026-06-10
- Branch: `feature/08-gatling-container-tests`

## What Changed

- Added Dockerized Gatling execution through source-controlled runner scripts for max-limit, 5-minute load, and 5-minute stress profiles.
- Added `src/gatling/user-files/simulations/MetaSimulation.scala` with run-type selection, JSP GET/POST checks, and Gatling failure assertions.
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
- Marked missing Gatling artifacts as opt-in/not-run evidence requiring `RUN_GATLING_TESTS=true` instead of treating intentionally skipped evidence stages as unexpected missing artifacts.
- Added `tests/scripts/test-generate-pipeline-report.sh` to guard the report rendering behavior.
- Added `docs/gatling.md` with runtime details, commands, evidence paths, max-limit method, and report-backed graph explanations.
- Updated `docs/submission.md` to show Gatling logs/reports/PDFs as ready while keeping the three Gatling terminal screenshots explicitly deferred.
- Fixed the Gatling runner normalization flow so logs and PDFs are not deleted when the latest raw report is copied into the stable report directory.
- Updated the opt-in max-limit path so the Jenkins Gatling evidence toggle runs `scripts/run-gatling-max-limit`, which performs bounded full discovery attempts instead of calling the one-attempt primitive directly.

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

## 2026-06-11 Full Max-Limit Discovery Follow-Up

- Changed `scripts/run-gatling-max-limit` from a thin single-run wrapper into a bounded discovery wrapper.
- Default discovery now runs up to three complete stepped profiles: `5-50`, `55-100`, and `105-150` users/sec, using the existing step, level-count, hold, and ramp defaults.
- A Gatling assertion failure is treated as successful max-limit discovery only when `output/gatling/max-limit/index.html` and `output/gatling/max-limit/max-limit-run.log` were normalized first.
- Added `output/gatling/max-limit/raw/max-limit-discovery.log` as the summary of attempted ranges.
- Updated `Jenkinsfile` so the optional `Gatling Max Limit` stage invokes `./scripts/run-gatling-max-limit` with `GATLING_DOCKER_PIPELINE=1`.
- Increased the pipeline timeout to 60 minutes so an intentional max-limit build can complete discovery plus the required load and stress stages.
- Added `tests/scripts/test-run-gatling-max-limit.sh` to verify repeated full-profile attempts and stop-on-threshold behavior with a stubbed runner.
- Validation:
  - `sh tests/scripts/test-run-gatling-max-limit.sh`

## 2026-06-12 RUN_GATLING_TESTS Jenkins Toggle Follow-Up

- Replaced the Jenkins build parameter `RUN_GATLING_MAX_LIMIT` with `RUN_GATLING_TESTS`.
- Gated `Gatling Max Limit`, `Gatling Load Test`, and `Gatling Stress Test` with `params.RUN_GATLING_TESTS` while preserving their existing script-existence checks.
- Kept max-limit tuning parameters unchanged: `GATLING_MAX_BASE_USERS_PER_SEC`, `GATLING_MAX_STEP_USERS_PER_SEC`, `GATLING_MAX_DURATION_SECONDS`, and `GATLING_MAX_LIMIT_USERS_PER_SEC`.
- Updated `scripts/generate-pipeline-report` so max-limit, load, and stress evidence are all labeled opt-in unless a `RUN_GATLING_TESTS=true` Jenkins build produced artifacts.
- Updated `scripts/generate-pipeline-report` after review so a requested `RUN_GATLING_TESTS=true` evidence build reports missing Gatling artifacts as `Missing`, not `Opt-in / not run`.
- Updated `docs/gatling.md`, `docs/jenkins.md`, and `docs/plans/08-gatling-container-tests.md` so normal CI/CD runs skip all Gatling stages and explicit evidence builds use `RUN_GATLING_TESTS=true`.
- Documented that Jenkins may need one Pipeline run or reload after merge before the Build with Parameters form exposes `RUN_GATLING_TESTS`; old `RUN_GATLING_MAX_LIMIT` invocations are obsolete.
- Added static coverage in `tests/scripts/test-jenkinsfile-gatling-params.sh` to reject the old parameter and require exactly three `RUN_GATLING_TESTS` stage gates.
- Added pipeline-report regression coverage for `RUN_GATLING_TESTS=true` with no Gatling artifacts, expecting `Missing`.

Validation:

- `sh tests/scripts/test-jenkinsfile-gatling-params.sh`: passed.
- `sh tests/scripts/test-run-gatling-max-limit.sh`: passed.
- `sh tests/scripts/test-generate-pipeline-report.sh`: passed.
- `sh -n scripts/run-gatling-max-limit`: passed.
- `sh -n scripts/generate-pipeline-report`: passed.
- `git diff --check`: passed.
- `mvn -q test`: passed.
- Jenkins declarative linter via `docker compose exec -T jenkins sh -lc '. /var/jenkins_home/codex-automation.env && curl -fsS -u "$JENKINS_USER:$JENKINS_TOKEN" -X POST -F "jenkinsfile=</workspace/final-project/Jenkinsfile" "http://localhost:8080/pipeline-model-converter/validate"'`: passed with `Jenkinsfile successfully validated.`

Skipped validation:

- Gatling execution was not run by the agent. Current project instructions require asking the user to run Gatling validation and provide the output or artifacts.
- Compliance-validator execution was not run because this checkout contains `.agents/rules/compliance.md` but does not contain the previously documented `.agents/skills/compliance-validator/scripts/validate_compliance.py` script or root `rules/compliance.md` path.

Remaining risks and follow-up:

- Run a Jenkins build with `RUN_GATLING_TESTS=true` before final submission to produce current max-limit, load, and stress reports, logs, PDFs, and Jenkins-console evidence.
- Confirm the published Jenkins HTML report links show all three Gatling evidence areas after that build.

## 2026-06-12 Class-Aligned Max-Limit Follow-Up

- Updated Gatling assertions so `max-limit`, `load-5m`, and `stress-5m` pass/fail on zero failed Gatling requests/checks/timeouts instead of the earlier hard `p95 <= 2000 ms` SLA.
- Kept response-time percentiles as report and graph-explanation evidence, but not as the max-limit pass/fail rule.
- Updated Jenkins max-limit defaults to start discovery at `50` users/sec, step by `50`, and search through `1000`.
- Updated `docs/gatling.md`, `docs/submission.md`, and Plan 08 so the max-limit explanation matches the class PDFs: highest tested users/sec with `KO=0`, first tested level with any KO as the failure point.
- Corrected `docs/submission.md` after review so the three-PDF Gatling checklist row is partial until the max-limit PDF is refreshed under the zero-KO rule.
- Added `tests/scripts/test-gatling-assertions.sh` to reject the old p95 gate and require the zero-KO assertion policy.
- Added `tests/scripts/test-submission-readiness.sh` to guard the max-limit and Gatling PDF submission-readiness rows.

Validation:

- `sh tests/scripts/test-gatling-assertions.sh`: passed.
- `sh -n scripts/run-gatling-container scripts/run-gatling-max-limit scripts/run-gatling-load-5m scripts/run-gatling-stress-5m scripts/export-gatling-pdfs scripts/generate-pipeline-report`: passed.
- `sh tests/scripts/test-run-gatling-max-limit.sh`: passed.
- `sh tests/scripts/test-jenkinsfile-gatling-params.sh`: passed.
- `sh tests/scripts/test-generate-pipeline-report.sh`: passed.
- `sh tests/scripts/test-submission-readiness.sh`: passed.
- `git diff --check`: passed.

Skipped validation:

- Gatling execution was not run by the agent. Current project instructions require asking the user to run Gatling validation and provide the output or artifacts.

## 2026-06-11 Pipeline Report Rendering Follow-Up

- Reworked `scripts/generate-pipeline-report` to generate CSP-friendly external CSS for Jenkins HTML Publisher.
- Updated the `Published Artifacts` table to show short reference links such as `HTML`, `PDF`, `Log`, and `Screenshot` instead of visible full artifact paths or URLs.
- Collapsed Gatling HTML/PDF/log duplicates into one row per Gatling run, with multiple reference links in that row.
- Changed the `Pipeline Stages` table from a generic `Status` column to `Evidence State`, deriving artifact-backed stage states from generated files and labeling console-only stages as `Console log`.
- Verified the CSS rendering pass through Browser over a temporary localhost server; computed styles showed the stylesheet applied, status badges rendered with badge backgrounds, the metadata grid existed, and artifact links pointed at `http://localhost:8081/job/meta-ci-cd/164/artifact/...`.
- Verified the later short-reference table change with `sh tests/scripts/test-generate-pipeline-report.sh` and direct generated HTML inspection. A second Browser refresh could not be completed because the temporary localhost server did not accept connections from the browser session.
- Verified the evidence-state regression with `sh tests/scripts/test-generate-pipeline-report.sh`; the test now asserts missing build/stress/Playwright artifacts are not shown as available while present load-test artifacts are shown as available.
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
