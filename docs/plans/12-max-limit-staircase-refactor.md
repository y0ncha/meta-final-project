---
goal: Refactor Gatling Max-Limit Evidence to a Single Staircase Simulation
version: 1.0
date_created: 2026-06-14
last_updated: 2026-06-14
owner: Yonatan
status: 'Implemented'
tags:
  - devops
  - gatling
  - performance
  - refactor
  - evidence
  - submission
---

# Introduction

![Status: Implemented](https://img.shields.io/badge/status-Implemented-green)

This plan changes the max-limit Gatling evidence from repeated flat single-level runs into one staircase max-limit simulation. The published max-limit HTML/PDF report must show active users increasing level by level until the configured failure-search ceiling. The report, console summary, screenshots, and submission text must make the defended cutoff clear: the max limit is the highest tested level with `KO=0`, and the first failing tested level is the first level in the staircase that produces one or more failed requests/checks/timeouts.

This is a refactor of the already implemented Gatling container evidence flow from `docs/plans/08-gatling-container-tests.md`; it must not reopen the completed Docker, Jenkins, Playwright, HAR, load-test, or stress-test implementation scope.

## 1. Requirements & Constraints

- **REQ-001**: Keep Gatling execution Docker-only through existing source-controlled scripts.
- **REQ-002**: Keep accepted `GATLING_RUN_TYPE` values exactly `max-limit`, `load-5m`, and `stress-5m`.
- **REQ-003**: Change only the `max-limit` injection profile in `src/gatling/user-files/simulations/MetaSimulation.scala`; do not change the `load-5m` or `stress-5m` profiles.
- **REQ-004**: Preserve the existing HAR-derived business flow: GET app root, POST `nameInput=Yonatan`, GET app root, POST empty `nameInput=`.
- **REQ-005**: Preserve the max-limit pass/fail rule `global.failedRequests.count.lt(1)`.
- **REQ-006**: Implement max-limit as one staircase Gatling simulation using `GATLING_MAX_BASE_USERS`, `GATLING_MAX_STEP_USERS`, `GATLING_MAX_LIMIT_USERS`, and `GATLING_MAX_DURATION_SECONDS`.
- **REQ-007**: The staircase must include every tested level from `GATLING_MAX_BASE_USERS` through `GATLING_MAX_LIMIT_USERS`, inclusive, using `GATLING_MAX_STEP_USERS`.
- **REQ-008**: Each staircase level must run for exactly `GATLING_MAX_DURATION_SECONDS`.
- **REQ-009**: The active-users graph in `output/gatling/max-limit/index.html` and `output/gatling/max-limit/max-limit-report.pdf` must visibly increase through the tested levels.
- **REQ-010**: The wrapper summary must still print `highest passing tested level: <value> virtual users` and `first failing tested level: <value> virtual users` when those values can be derived from the report.
- **REQ-011**: If the staircase reaches `GATLING_MAX_LIMIT_USERS` with no failing level, the wrapper must describe the result as `tested lower bound; no failing level found`.
- **REQ-012**: Preserve stable max-limit evidence paths: `output/gatling/max-limit/index.html`, `output/gatling/max-limit/max-limit-run.log`, `output/gatling/max-limit/raw/`, `output/gatling/max-limit/raw/max-limit-discovery.log`, and `output/gatling/max-limit/max-limit-report.pdf`.
- **REQ-013**: Keep Jenkins `RUN_GATLING_TESTS=true` behavior that intentionally runs max-limit, load, and stress evidence in one build.
- **REQ-014**: Preserve Jenkins HTML Publisher compatibility with stable Gatling report directories.
- **REQ-015**: Do not run Gatling evidence collection as part of this implementation. The assistant may run only validations and internal tests that do not execute Gatling load.
- **REQ-016**: Keep public submission Gatling folders limited to screenshot PNG files, PDF reports, and Markdown docs after the user refreshes evidence.
- **REQ-017**: Update source documentation so it no longer describes max-limit as a flat single-level report.
- **SEC-001**: Do not mount `/var/run/docker.sock` into the Gatling container.
- **SEC-002**: Do not write secrets, cookies, Jenkins credentials, GitHub tokens, API keys, or private keys into Gatling scripts, reports, screenshots, PDFs, logs, or docs.
- **SEC-003**: Review Gatling reports and logs before external sharing because generated evidence may include URLs, headers, or environment values.
- **CON-001**: Do not implement an unbounded or infinite public stress run. Gatling must use a configured upper ceiling through `GATLING_MAX_LIMIT_USERS`.
- **CON-002**: Do not smooth load or stress graphs by removing pauses or changing the HAR-derived business flow.
- **CON-003**: Do not replace the HAR-derived flow with a single synthetic endpoint only to make graphs smoother.
- **CON-004**: Do not create new long-running Compose services for Gatling, Playwright, or HAR runners.
- **GUD-001**: Prefer explicit source-controlled scripts in `scripts/` over Jenkins UI-only shell logic.
- **GUD-002**: Choose final local/public staircase ranges close to known failure regions; do not run a broad public staircase far past expected failure.
- **PAT-001**: Follow the existing disposable-runner pattern in `scripts/run-gatling-container`: direct local Docker execution, `GATLING_DOCKER_PIPELINE=1` support for Jenkins, stable output paths, and raw report preservation.
- **PAT-002**: Keep generated evidence under ignored `output/`; copy only final submission artifacts into `submission/`.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Replace the flat max-limit injection profile with a staircase profile while preserving load and stress behavior.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | In `src/gatling/user-files/simulations/MetaSimulation.scala`, add helper `private def steppedLevels(baseUsers: Int, limitUsers: Int, stepUsers: Int): Seq[Int]` that returns an inclusive ascending sequence and throws `IllegalArgumentException("GATLING_MAX_LIMIT_USERS must be greater than or equal to GATLING_MAX_BASE_USERS")` when `limitUsers < baseUsers`. | Yes | 2026-06-14 |
| TASK-002 | Keep a single `Meta JSP HAR-derived flow` scenario and apply the max-limit staircase as sequential closed injection steps so levels do not overlap as separate populations. | Yes | 2026-06-14 |
| TASK-003 | In the `case "max-limit"` branch, stop using `GATLING_MAX_USERS` as the primary load value. Keep it only as a backward-compatible fallback for `GATLING_MAX_BASE_USERS` when that variable is not set. | Yes | 2026-06-14 |
| TASK-004 | In the `case "max-limit"` branch, read `GATLING_MAX_BASE_USERS`, `GATLING_MAX_STEP_USERS`, `GATLING_MAX_LIMIT_USERS`, and `GATLING_MAX_DURATION_SECONDS` with positive-integer validation. | Yes | 2026-06-14 |
| TASK-005 | In the `case "max-limit"` branch, build `levels = steppedLevels(maxBaseUsers, maxLimitUsers, maxStepUsers)`. | Yes | 2026-06-14 |
| TASK-006 | In the `case "max-limit"` branch, build `staircaseProfile = levels.map { level => constantConcurrentUsers(level).during(maxDurationSeconds.seconds) }` so each level runs sequentially for the configured duration. | Yes | 2026-06-14 |
| TASK-007 | In the `case "max-limit"` branch, call `setUp(scn.inject(staircaseProfile))`, apply the existing `httpProtocol`, and keep assertion `global.failedRequests.count.lt(1)`. | Yes | 2026-06-14 |
| TASK-008 | Verify by diff inspection that `load-5m` still uses `rampConcurrentUsers(0).to(loadUsers).during(60.seconds)`, `constantConcurrentUsers(loadUsers).during(180.seconds)`, and `rampConcurrentUsers(loadUsers).to(0).during(60.seconds)`. | Yes | 2026-06-14 |
| TASK-009 | Verify by diff inspection that `stress-5m` still uses five `60.seconds` levels from `GATLING_STRESS_START_USERS` to `GATLING_STRESS_TARGET_USERS`. | Yes | 2026-06-14 |

### Implementation Phase 2

- GOAL-002: Refactor the max-limit wrapper so it runs one staircase report and summarizes the result.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-010 | In `scripts/run-gatling-max-limit`, remove the repeated single-level discovery loop as the default execution path. | Yes | 2026-06-14 |
| TASK-011 | In `scripts/run-gatling-max-limit`, validate `GATLING_MAX_BASE_USERS`, `GATLING_MAX_STEP_USERS`, `GATLING_MAX_DURATION_SECONDS`, and `GATLING_MAX_LIMIT_USERS`. | Yes | 2026-06-14 |
| TASK-012 | In `scripts/run-gatling-max-limit`, write `output/gatling/max-limit/raw/max-limit-discovery.log` with the tested staircase range, step, duration, level-to-time schedule, and exact command parameters used. | Yes | 2026-06-14 |
| TASK-013 | In `scripts/run-gatling-max-limit`, call `scripts/run-gatling-container` exactly once with `GATLING_RUN_TYPE=max-limit`, `GATLING_MAX_BASE_USERS`, `GATLING_MAX_STEP_USERS`, `GATLING_MAX_DURATION_SECONDS`, and `GATLING_MAX_LIMIT_USERS`. | Yes | 2026-06-14 |
| TASK-014 | In `scripts/run-gatling-max-limit`, allow the Gatling command to return non-zero when `output/gatling/max-limit/index.html` and `output/gatling/max-limit/max-limit-run.log` exist, because an assertion failure is expected evidence for the first failing level. | Yes | 2026-06-14 |
| TASK-015 | In `scripts/run-gatling-max-limit`, if Gatling returns non-zero and no stable report exists, print `Max-limit staircase failed before a usable Gatling report was created.` to stderr and exit with the Gatling status. | Yes | 2026-06-14 |
| TASK-016 | In `scripts/run-gatling-max-limit`, print a final summary that names the report as `staircase Gatling report: output/gatling/max-limit/index.html`. | Yes | 2026-06-14 |
| TASK-017 | In `scripts/run-gatling-max-limit`, keep `GATLING_CONSOLE_MODE=summary` behavior compatible with Jenkins so the console remains readable. | Yes | 2026-06-14 |
| TASK-018 | In `scripts/run-gatling-container`, add `GATLING_MAX_LIMIT_USERS` to the configured environment variables and export it in both local Docker mode and `GATLING_DOCKER_PIPELINE=1` mode. | Yes | 2026-06-14 |
| TASK-019 | In `scripts/run-gatling-container`, update the max-limit console start message to print `base`, `step`, `limit`, and `duration` instead of one flat `GATLING_MAX_USERS` value. | Yes | 2026-06-14 |

### Implementation Phase 3

- GOAL-003: Make the staircase report defensible by extracting or documenting the max-limit cutoff.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-020 | Inspect the generated Gatling report structure and identify whether per-level `OK` and `KO` counts are stored in a stable form. | Yes | 2026-06-14 |
| TASK-021 | If per-level counts are available in a stable generated `js/stats.js` shape, add POSIX-shell parsing in `scripts/run-gatling-max-limit` that derives `highest_passing_level` and `first_failing_level` from those counts. | N/A | 2026-06-14 |
| TASK-022 | If per-level counts are not stable enough to parse safely, keep the wrapper summary honest: print `highest passing tested level: inspect staircase report` and require the submission docs to name the values from manual report inspection. | Yes | 2026-06-14 |
| TASK-023 | Do not infer a precise max limit from response-time percentiles. The cutoff remains the first staircase level with `KO > 0`. | Yes | 2026-06-14 |
| TASK-024 | If no `KO > 0` level appears through `GATLING_MAX_LIMIT_USERS`, print `result: tested lower bound; no failing level found`. | Yes | 2026-06-14 |
| TASK-025 | Confirm the active-users graph in the HTML report visibly increases across the configured levels. | Deferred to user/Jenkins evidence run | 2026-06-14 |
| TASK-026 | Confirm the exported PDF preserves the active-users graph and does not crop the staircase. | Deferred to user/Jenkins evidence run | 2026-06-14 |

### Implementation Phase 4

- GOAL-004: Update tests and documentation for the new max-limit evidence contract.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-027 | Update `tests/scripts/test-run-gatling-max-limit.sh` so the fake runner expects one staircase invocation instead of repeated flat single-level invocations. | Yes | 2026-06-14 |
| TASK-028 | Update `tests/scripts/test-run-gatling-max-limit.sh` to assert that `GATLING_MAX_LIMIT_USERS` is passed to `scripts/run-gatling-container`. | Yes | 2026-06-14 |
| TASK-029 | Update `tests/scripts/test-run-gatling-max-limit.sh` to assert that a non-zero Gatling result with a usable report still exits `0`. | Yes | 2026-06-14 |
| TASK-030 | Update `tests/test_gatling_max_limit_summary.sh` to check for `staircase Gatling report` wording and the `KO=0` cutoff rule. | Yes | 2026-06-14 |
| TASK-031 | Update `tests/scripts/test-gatling-assertions.sh` to verify `MetaSimulation.scala` contains `steppedLevels`, `staircaseProfile`, `constantConcurrentUsers(level)`, and `GATLING_MAX_LIMIT_USERS`, while rejecting delayed `nothingFor` scheduling. | Yes | 2026-06-14 |
| TASK-032 | Update `docs/gatling.md` to describe max-limit as one staircase simulation with a configured upper ceiling, not a no-time-limit infinite run. | Yes | 2026-06-14 |
| TASK-033 | Update `docs/gatling.md` to explain that Gatling assertions are evaluated after a run; the staircase must be bounded by a safe `GATLING_MAX_LIMIT_USERS` value. | Yes | 2026-06-14 |
| TASK-034 | Update `docs/gatling.md` to keep the load/stress internal oscillation explanation unchanged and acceptable. | Yes | 2026-06-14 |
| TASK-035 | Add `docs/changelog/12-max-limit-staircase-refactor.changelog.md` when this implementation is completed. | Yes | 2026-06-14 |

### Evidence Handoff

This implementation intentionally stops before final evidence refresh. Gatling max-limit/load/stress runs must be triggered by the user or Jenkins, not by the assistant. After those real artifacts exist, a separate submission-refresh task can copy PDFs/screenshots/logs into `submission/` and update final max-limit values.

## 3. Alternatives

- **ALT-001**: Keep the existing repeated flat single-level max-limit runs and only explain the graph. Rejected because the PDF itself must show increasing active-user levels.
- **ALT-002**: Add a second visual staircase run after the existing flat discovery loop. Rejected for this plan because the requested refactor is a single staircase max-limit simulation.
- **ALT-003**: Run an unbounded max-limit test with no ceiling until the public server breaks. Rejected because Gatling assertions are evaluated after execution and an unbounded public overload is not safe or reproducible.
- **ALT-004**: Remove pauses or use one endpoint to smooth active-user graphs. Rejected because the assignment evidence should remain aligned with the HAR-derived business flow.
- **ALT-005**: Generate a synthetic chart outside Gatling. Rejected because the required visual evidence should come from the Gatling report/PDF.

## 4. Dependencies

- **DEP-001**: Existing Gatling container implementation from `docs/plans/08-gatling-container-tests.md`.
- **DEP-002**: Docker image `denvazh/gatling:3.2.1`.
- **DEP-003**: Docker network `meta` and reachable Tomcat target at the configured `APP_BASE_URL`.
- **DEP-004**: Jenkins `RUN_GATLING_TESTS=true` evidence flow.
- **DEP-005**: `scripts/export-gatling-pdfs` must continue exporting `output/gatling/max-limit/index.html` to `output/gatling/max-limit/max-limit-report.pdf`.
- **DEP-006**: Final local/public performance artifacts must come from user/Jenkins evidence runs, not invented values.

## 5. Files

- **FILE-001**: `docs/plans/12-max-limit-staircase-refactor.md` - this implementation plan.
- **FILE-002**: `src/gatling/user-files/simulations/MetaSimulation.scala` - replace max-limit flat profile with staircase profile.
- **FILE-003**: `scripts/run-gatling-max-limit` - run one staircase max-limit evidence simulation and summarize results.
- **FILE-004**: `scripts/run-gatling-container` - pass `GATLING_MAX_LIMIT_USERS` into Gatling and print staircase parameters.
- **FILE-005**: `tests/scripts/test-run-gatling-max-limit.sh` - update wrapper behavior tests.
- **FILE-006**: `tests/test_gatling_max_limit_summary.sh` - update summary wording tests.
- **FILE-007**: `tests/scripts/test-gatling-assertions.sh` - update simulation source assertions.
- **FILE-008**: `docs/gatling.md` - document staircase max-limit semantics and safety bounds.
- **FILE-009**: `docs/changelog/12-max-limit-staircase-refactor.changelog.md` - record implementation and verification when completed.

## 6. Testing

- **TEST-001**: `sh tests/scripts/test-run-gatling-max-limit.sh` must pass.
- **TEST-002**: `sh tests/test_gatling_max_limit_summary.sh` must pass.
- **TEST-003**: `sh tests/scripts/test-gatling-assertions.sh` must pass.
- **TEST-004**: `sh -n scripts/run-gatling-container scripts/run-gatling-max-limit` must pass.
- **TEST-005**: `git diff --check` must pass.
- **TEST-006**: No Gatling evidence runs are allowed during implementation validation.
- **TEST-007**: After a later user/Jenkins evidence refresh, the local and public max-limit PDFs must visibly show a staircase of increasing active users through the tested range.

## 7. Risks & Assumptions

- **RISK-001**: Gatling does not automatically stop a simulation at the first assertion failure; assertions are evaluated after the run. The staircase must therefore use a safe configured upper ceiling.
- **RISK-002**: If the staircase range is too wide, the public EC2 host can be overloaded after the first failing level. Final public runs must use tight bounds.
- **RISK-003**: Per-level report parsing may be fragile if Gatling 3.2.1 changes generated `stats.js` shape. If parsing is not reliable, document the cutoff from manual report inspection.
- **RISK-004**: The PDF may crop the active-users graph if the existing PDF exporter viewport is too small. The exporter must be adjusted only if visual inspection proves cropping.
- **RISK-005**: Final local/public failure thresholds may shift between evidence builds. Submission docs must use refreshed artifact values only.
- **ASSUMPTION-001**: The assignment accepts the same HAR-derived business flow for max-limit, load, and stress tests.
- **ASSUMPTION-002**: The defended max-limit cutoff remains `KO=0`.
- **ASSUMPTION-003**: Load and stress internal oscillation remains acceptable and should not be refactored.
- **ASSUMPTION-004**: The user will trigger final local/public Jenkins evidence builds after the code change is implemented.

## 8. Related Specifications / Further Reading

[Gatling container tests plan](./08-gatling-container-tests.md)
[Gatling evidence guide](../gatling.md)
[HAR capture plan](./07-har-capture.md)
[Submission package plan](./11-submission-package.md)
[Gatling documentation](https://docs.gatling.io/)
