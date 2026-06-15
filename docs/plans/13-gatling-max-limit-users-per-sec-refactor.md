---
goal: Refactor Gatling Max-Limit Evidence to Users Per Second
version: 2.0
date_created: 2026-06-14
last_updated: 2026-06-15
owner: Yonatan
status: 'Planned'
tags:
  - devops
  - gatling
  - performance
  - refactor
  - evidence
  - submission
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

This plan refactors only the Gatling max-limit testing method from a closed concurrent-virtual-user staircase to an open users-per-second staircase. The goal is to align the max-limit evidence with the instructor direction to slowly raise the users/sec rate until the first failing level is observed. Playwright functional validation, HAR capture, WAR deployment, Docker Compose service definitions, load 5m testing, and stress 5m testing are out of scope.

The defended max-limit result after this refactor must be stated as users/sec: the highest tested users/sec level with `KO=0` is the passing limit, and the first tested users/sec level with `KO>0` is the failure boundary. Existing concurrent-user evidence such as `8300` virtual users passed and `8350` virtual users failed must not be reused as the final max-limit answer after this refactor.

## 1. Requirements & Constraints

- **REQ-001**: Change only the Gatling `max-limit` testing method to users/sec; do not modify Playwright tests, Playwright scripts, HAR capture scripts, application JSP code, Maven WAR packaging, Tomcat deployment, or Docker Compose service topology.
- **REQ-002**: Keep accepted `GATLING_RUN_TYPE` values exactly `max-limit`, `load-5m`, and `stress-5m`.
- **REQ-003**: Preserve the existing HAR-derived business flow in `src/gatling/user-files/simulations/MetaSimulation.scala`: GET app root, POST `nameInput=Yonatan`, GET app root, POST empty `nameInput=`.
- **REQ-004**: Preserve the max-limit pass/fail assertion `global.failedRequests.count.lt(1)` so a tested rate passes only when Gatling reports zero failed requests/checks/timeouts.
- **REQ-005**: In `src/gatling/user-files/simulations/MetaSimulation.scala`, replace only the `case "max-limit"` injection profile with an open workload profile that uses `constantUsersPerSec(rate.toDouble).during(maxDurationSeconds.seconds)` for each tested users/sec level.
- **REQ-006**: Preserve the `load-5m` and `stress-5m` injection profiles exactly unless a separate future plan explicitly changes them.
- **REQ-007**: Keep the existing max-limit environment variable names for compatibility: `GATLING_MAX_BASE_USERS`, `GATLING_MAX_STEP_USERS`, `GATLING_MAX_LIMIT_USERS`, `GATLING_MAX_DURATION_SECONDS`, and `GATLING_MAX_RAMP_SECONDS`.
- **REQ-008**: Treat the values of `GATLING_MAX_BASE_USERS`, `GATLING_MAX_STEP_USERS`, and `GATLING_MAX_LIMIT_USERS` as users/sec values for max-limit execution and documentation after this refactor.
- **REQ-009**: Update console output, wrapper logs, docs, tests, and submission text to label max-limit values as `users/sec`, not `virtual users`, `active users`, or `concurrent users`.
- **REQ-010**: The max-limit wrapper must continue to execute one bounded staircase simulation with a configured upper ceiling through `GATLING_MAX_LIMIT_USERS`.
- **REQ-011**: Each users/sec level must run for exactly `GATLING_MAX_DURATION_SECONDS`.
- **REQ-012**: If `GATLING_MAX_RAMP_SECONDS` is greater than `0`, the max-limit profile must ramp from the current users/sec rate to the next users/sec rate using `rampUsersPerSec(current.toDouble).to(next.toDouble).during(maxRampSeconds.seconds)`.
- **REQ-013**: If `GATLING_MAX_RAMP_SECONDS` is `0`, the max-limit profile must move directly between `constantUsersPerSec` levels without an intermediate ramp.
- **REQ-014**: The generated Gatling report and exported PDF must show an increasing users/sec injection pattern for the max-limit run.
- **REQ-015**: The wrapper summary must print `highest passing tested level: <value> users/sec` and `first failing tested level: <value> users/sec` when those values can be derived safely.
- **REQ-016**: If no failing level appears through `GATLING_MAX_LIMIT_USERS`, the wrapper must describe the result as `tested lower bound; no failing users/sec level found`.
- **REQ-017**: Preserve stable max-limit evidence paths: `output/gatling/max-limit/index.html`, `output/gatling/max-limit/max-limit-run.log`, `output/gatling/max-limit/raw/`, `output/gatling/max-limit/raw/max-limit-discovery.log`, `output/gatling/max-limit/max-limit-report.pdf`, and `output/gatling/screenshots/max-limit-terminal.png`.
- **REQ-018**: Keep Jenkins `RUN_GATLING_TESTS=true` behavior that intentionally runs max-limit, load, and stress evidence in one build.
- **REQ-019**: Preserve Jenkins HTML Publisher compatibility with stable Gatling report directories.
- **REQ-020**: Do not run real Gatling max-limit evidence collection during implementation validation. The assistant may run shell tests and syntax checks only.
- **REQ-021**: After implementation, refresh Gatling max-limit evidence before submission: terminal/Jenkins screenshot, HTML report, PDF report, run log, discovery log, graph explanation, and max-limit explanation.
- **REQ-022**: Do not reuse previous concurrent-user max-limit evidence as users/sec evidence.
- **SEC-001**: Do not mount `/var/run/docker.sock` into the Gatling container.
- **SEC-002**: Do not write secrets, cookies, Jenkins credentials, GitHub tokens, API keys, private keys, or private SSH material into Gatling scripts, reports, screenshots, PDFs, logs, or docs.
- **SEC-003**: Review Gatling reports and logs before external sharing because generated evidence may include URLs, headers, or environment values.
- **CON-001**: Do not implement an unbounded or infinite public stress run. Gatling must use a configured upper ceiling through `GATLING_MAX_LIMIT_USERS`.
- **CON-002**: Do not remove pauses, remove checks, or replace the HAR-derived flow with a single synthetic endpoint to inflate users/sec numbers.
- **CON-003**: Do not create new long-running Compose services for Gatling, Playwright, or HAR runners.
- **CON-004**: Do not rename the Tomcat context path `/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **GUD-001**: Prefer explicit source-controlled scripts in `scripts/` over Jenkins UI-only shell logic.
- **GUD-002**: Choose final local/public users/sec ranges close to known failure regions; do not run broad public users/sec sweeps far past expected failure.
- **PAT-001**: Follow the existing disposable-runner pattern in `scripts/run-gatling-container`: direct local Docker execution, `GATLING_DOCKER_PIPELINE=1` support for Jenkins, stable output paths, and raw report preservation.
- **PAT-002**: Keep generated evidence under ignored `output/`; copy only final submission artifacts into `submission/`.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Refactor the max-limit simulation profile from closed concurrent users to open users/sec while preserving load and stress behavior.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | In `src/gatling/user-files/simulations/MetaSimulation.scala`, keep helper `private def steppedLevels(baseUsers: Int, limitUsers: Int, stepUsers: Int): Seq[Int]` but treat its returned values as users/sec rates when `runType == "max-limit"`. | No | N/A |
| TASK-002 | In `src/gatling/user-files/simulations/MetaSimulation.scala`, keep `val maxBaseUsers = intEnv("GATLING_MAX_BASE_USERS", intEnv("GATLING_MAX_USERS", 8250))`, `val maxStepUsers = intEnv("GATLING_MAX_STEP_USERS", 50)`, `val maxLimitUsers = intEnv("GATLING_MAX_LIMIT_USERS", 8350)`, `val maxDurationSeconds = intEnv("GATLING_MAX_DURATION_SECONDS", 10)`, and `val maxRampSeconds = nonNegativeIntEnv("GATLING_MAX_RAMP_SECONDS", 0)` unless Jenkins defaults are changed in Phase 2. | No | N/A |
| TASK-003 | In `src/gatling/user-files/simulations/MetaSimulation.scala`, replace `constantConcurrentUsers(level).during(maxDurationSeconds.seconds)` in the max-limit branch with `constantUsersPerSec(level.toDouble).during(maxDurationSeconds.seconds)`. | No | N/A |
| TASK-004 | In `src/gatling/user-files/simulations/MetaSimulation.scala`, replace max-limit ramp code `rampConcurrentUsers(level).to(nextLevel).during(maxRampSeconds.seconds)` with `rampUsersPerSec(level.toDouble).to(nextLevel.toDouble).during(maxRampSeconds.seconds)`. | No | N/A |
| TASK-005 | In `src/gatling/user-files/simulations/MetaSimulation.scala`, replace initial max-limit ramp code `rampConcurrentUsers(0).to(levels.head).during(maxRampSeconds.seconds)` with `rampUsersPerSec(0.0).to(levels.head.toDouble).during(maxRampSeconds.seconds)`. | No | N/A |
| TASK-006 | In `src/gatling/user-files/simulations/MetaSimulation.scala`, keep `scn.inject(staircaseProfile)`, `protocols(httpProtocol)`, `.maxDuration(maxRunSeconds.seconds)`, and `global.failedRequests.count.lt(1)` unchanged for max-limit. | No | N/A |
| TASK-007 | Verify by diff inspection that `load-5m` still uses `rampConcurrentUsers(0).to(loadUsers).during(60.seconds)`, `constantConcurrentUsers(loadUsers).during(180.seconds)`, and `rampConcurrentUsers(loadUsers).to(0).during(60.seconds)`. | No | N/A |
| TASK-008 | Verify by diff inspection that `stress-5m` still uses five `60.seconds` levels from `GATLING_STRESS_START_USERS` to `GATLING_STRESS_TARGET_USERS`. | No | N/A |
| TASK-009 | Verify by `rg -n "constantUsersPerSec|rampUsersPerSec|constantConcurrentUsers|rampConcurrentUsers" src/gatling/user-files/simulations/MetaSimulation.scala` that users/sec injectors appear only in the max-limit branch and concurrent injectors remain in load/stress branches. | No | N/A |

### Implementation Phase 2

- GOAL-002: Update max-limit wrapper and Jenkins-facing wording so the configured staircase is users/sec.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-010 | In `scripts/run-gatling-max-limit`, update summary text `virtual users` to `users/sec` for tested range, step, level schedule, ramp schedule, cutoff rule, highest passing level, first failing level, and lower-bound output. | No | N/A |
| TASK-011 | In `scripts/run-gatling-max-limit`, keep validation for `GATLING_MAX_BASE_USERS`, `GATLING_MAX_STEP_USERS`, `GATLING_MAX_DURATION_SECONDS`, `GATLING_MAX_RAMP_SECONDS`, and `GATLING_MAX_LIMIT_USERS` unchanged except for user-facing unit text. | No | N/A |
| TASK-012 | In `scripts/run-gatling-max-limit`, keep the single call to `scripts/run-gatling-container` with `GATLING_RUN_TYPE=max-limit` and the existing max-limit environment variables; do not reintroduce repeated flat single-level attempts. | No | N/A |
| TASK-013 | In `scripts/run-gatling-max-limit`, ensure `output/gatling/max-limit/raw/max-limit-discovery.log` records `command parameters`, `level schedule`, and `ramp schedule` using `users/sec` labels. | No | N/A |
| TASK-014 | In `scripts/run-gatling-container`, update the max-limit console start message from `virtual users` to `users/sec` while preserving the same base, step, limit, duration, and ramp values. | No | N/A |
| TASK-015 | In `Jenkinsfile`, update parameter descriptions for `GATLING_MAX_BASE_USERS`, `GATLING_MAX_STEP_USERS`, and `GATLING_MAX_LIMIT_USERS` so Jenkins UI users see users/sec terminology. | No | N/A |
| TASK-016 | In `Jenkinsfile`, keep parameter names and environment variable names unchanged to avoid breaking wrapper compatibility and existing tests. | No | N/A |
| TASK-017 | In `scripts/generate-pipeline-report`, update any max-limit explanatory wording that describes the method as virtual-user or concurrent-user based. | No | N/A |

### Implementation Phase 3

- GOAL-003: Update automated tests so they enforce the users/sec max-limit methodology and prevent accidental Playwright changes.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-018 | In `tests/scripts/test-gatling-assertions.sh`, replace max-limit assertions that require `constantConcurrentUsers(level)` and `rampConcurrentUsers(...)` with assertions that require `constantUsersPerSec(level.toDouble)` and `rampUsersPerSec(...)`. | No | N/A |
| TASK-019 | In `tests/scripts/test-gatling-assertions.sh`, keep assertions that verify `load-5m` and `stress-5m` still use concurrent-user injection profiles. | No | N/A |
| TASK-020 | In `tests/scripts/test-gatling-assertions.sh`, remove `assert_not_contains 'constantUsersPerSec'`, `assert_not_contains 'rampUsersPerSec'`, and `assert_not_contains 'incrementUsersPerSec'` because users/sec is now required for max-limit. | No | N/A |
| TASK-021 | In `tests/scripts/test-gatling-assertions.sh`, add a negative assertion that `constantConcurrentUsers(level).during(maxDurationSeconds.seconds)` is absent from the max-limit implementation. | No | N/A |
| TASK-022 | In `tests/scripts/test-run-gatling-max-limit.sh`, update expected console and discovery-log strings from `virtual users` to `users/sec`. | No | N/A |
| TASK-023 | In `tests/test_gatling_max_limit_summary.sh`, update expected final summary strings from `virtual users` to `users/sec`. | No | N/A |
| TASK-024 | In `tests/scripts/test-jenkinsfile-gatling-params.sh`, update expected Jenkins parameter descriptions from virtual-user terminology to users/sec terminology. | No | N/A |
| TASK-025 | In `tests/scripts/test-gatling-har-alignment.sh`, remove any assertion that rejects `highest tested users/sec` or users/sec methodology from Gatling docs. | No | N/A |
| TASK-026 | Run `git diff --name-only` after implementation and verify no file under `tests/playwright/`, `scripts/run-playwright-container`, or Playwright report generation changed. | No | N/A |

### Implementation Phase 4

- GOAL-004: Update source documentation and submission-facing methodology to match users/sec evidence.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-027 | In `docs/gatling.md`, replace max-limit method text that describes a closed workload, active-user graph, virtual-user levels, or concurrent-user staircase with users/sec arrival-rate terminology. | No | N/A |
| TASK-028 | In `docs/gatling.md`, document the exact max-limit method: slowly raise users/sec using stepped `constantUsersPerSec` levels, optionally ramp between levels with `rampUsersPerSec`, and use `KO=0` as the pass rule. | No | N/A |
| TASK-029 | In `docs/gatling.md`, keep the warning that Gatling assertions are evaluated after the simulation and the run must remain bounded by `GATLING_MAX_LIMIT_USERS`. | No | N/A |
| TASK-030 | In `docs/gatling.md`, update the main control descriptions so `GATLING_MAX_BASE_USERS`, `GATLING_MAX_STEP_USERS`, and `GATLING_MAX_LIMIT_USERS` are described as users/sec values for max-limit. | No | N/A |
| TASK-031 | In `docs/jenkins.md`, update the `Gatling Max Limit` stage description from virtual-user/concurrent-user wording to users/sec wording. | No | N/A |
| TASK-032 | In `docs/submission.md`, replace the current local max-limit conclusion that names `8300` virtual users and `8350` virtual users with a pending users/sec refresh note until new evidence exists. | No | N/A |
| TASK-033 | In `submission/local/j-gatling-max-limit/README.md` and `submission/local/j-gatling-max-limit/max-limit-explanation.md`, replace concurrent-user values with a pending users/sec refresh note or refreshed users/sec values after the user runs Jenkins. | No | N/A |
| TASK-034 | In `submission/local/l-gatling-result-pdfs/graph-explanations.md`, update the max-limit graph explanation to discuss users/sec arrival rate instead of active concurrent users after refreshed evidence exists. | No | N/A |
| TASK-035 | Add `docs/changelog/12-max-limit-staircase-refactor.changelog.md` entry or update the existing changelog file to record the users/sec refactor and validation commands. | No | N/A |

### Implementation Phase 5

- GOAL-005: Verify implementation without running real Gatling load, then define the evidence refresh handoff.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-036 | Run `sh -n scripts/run-gatling-container scripts/run-gatling-max-limit scripts/run-gatling-load-5m scripts/run-gatling-stress-5m scripts/export-gatling-pdfs scripts/generate-pipeline-report`. | No | N/A |
| TASK-037 | Run `sh tests/scripts/test-gatling-assertions.sh`. | No | N/A |
| TASK-038 | Run `sh tests/scripts/test-run-gatling-max-limit.sh`. | No | N/A |
| TASK-039 | Run `sh tests/test_gatling_max_limit_summary.sh`. | No | N/A |
| TASK-040 | Run `sh tests/scripts/test-jenkinsfile-gatling-params.sh`. | No | N/A |
| TASK-041 | Run `sh tests/scripts/test-gatling-har-alignment.sh`. | No | N/A |
| TASK-042 | Run `git diff --check`. | No | N/A |
| TASK-043 | Do not run `./scripts/run-gatling-max-limit` during implementation verification unless the user explicitly requests a real evidence refresh. | No | N/A |
| TASK-044 | After the user runs Jenkins with `RUN_GATLING_TESTS=true`, refresh `submission/local/j-gatling-max-limit/`, `submission/local/k-gatling-cmd-screenshots/`, `submission/local/l-gatling-result-pdfs/graph-explanations.md`, and `docs/submission.md` together using the new users/sec boundary. | No | N/A |

## 3. Alternatives

- **ALT-001**: Keep the current closed concurrent-user staircase. Rejected because the instructor explicitly directed the max-limit method to slowly raise the users/sec rate.
- **ALT-002**: Rename all max-limit variables from `GATLING_MAX_*_USERS` to `GATLING_MAX_*_USERS_PER_SEC`. Rejected for the quick refactor because it would increase Jenkins, wrapper, tests, and backward-compatibility churn; docs and UI text can define the unit as users/sec while names remain stable.
- **ALT-003**: Use one continuous `rampUsersPerSec(base).to(limit).during(totalDuration)` profile and infer the failure rate from timestamps. Rejected because discrete stepped `constantUsersPerSec` levels produce a clearer defensible answer: previous level passed, next level failed.
- **ALT-004**: Use Gatling `.throttle()` to cap requests per second instead of users/sec arrival rate. Rejected because the instructor asked for users/sec, not request throughput.
- **ALT-005**: Change load and stress tests to users/sec at the same time. Rejected because the user requested a quick Gatling max-limit methodology fix and said this should not affect Playwright; broadening the scope risks avoidable evidence churn.
- **ALT-006**: Keep old concurrent-user submission evidence and only change wording to users/sec. Rejected because that would be technically false and unsafe for grading.

## 4. Dependencies

- **DEP-001**: Existing Gatling container implementation from `docs/plans/08-gatling-container-tests.md`.
- **DEP-002**: Docker image `denvazh/gatling:3.2.1`.
- **DEP-003**: Docker network `meta` and reachable Tomcat target at the configured `APP_BASE_URL`.
- **DEP-004**: Jenkins `RUN_GATLING_TESTS=true` evidence flow.
- **DEP-005**: `scripts/export-gatling-pdfs` must continue exporting `output/gatling/max-limit/index.html` to `output/gatling/max-limit/max-limit-report.pdf`.
- **DEP-006**: Final local/public performance artifacts must come from user/Jenkins evidence runs, not invented values.
- **DEP-007**: Gatling Scala DSL in version 3.2.1 must support `constantUsersPerSec` and `rampUsersPerSec` in `scn.inject(...)`.

## 5. Files

- **FILE-001**: `docs/plans/12-max-limit-staircase-refactor.md` - this implementation plan.
- **FILE-002**: `src/gatling/user-files/simulations/MetaSimulation.scala` - replace max-limit closed concurrent-user injectors with open users/sec injectors.
- **FILE-003**: `scripts/run-gatling-max-limit` - relabel max-limit range, schedule, summary, and cutoff output as users/sec.
- **FILE-004**: `scripts/run-gatling-container` - relabel max-limit console start output as users/sec.
- **FILE-005**: `Jenkinsfile` - update max-limit parameter descriptions to users/sec terminology while preserving parameter names.
- **FILE-006**: `scripts/generate-pipeline-report` - update max-limit explanatory wording if it references virtual-user or concurrent-user methodology.
- **FILE-007**: `tests/scripts/test-gatling-assertions.sh` - enforce users/sec injectors for max-limit and preserve concurrent injectors for load/stress.
- **FILE-008**: `tests/scripts/test-run-gatling-max-limit.sh` - update wrapper behavior expectations and log text.
- **FILE-009**: `tests/test_gatling_max_limit_summary.sh` - update final summary expectations.
- **FILE-010**: `tests/scripts/test-jenkinsfile-gatling-params.sh` - update Jenkins parameter wording expectations.
- **FILE-011**: `tests/scripts/test-gatling-har-alignment.sh` - allow users/sec methodology in docs.
- **FILE-012**: `docs/gatling.md` - document users/sec max-limit semantics, commands, and safety bounds.
- **FILE-013**: `docs/jenkins.md` - document Jenkins max-limit users/sec behavior.
- **FILE-014**: `docs/submission.md` - remove stale concurrent-user max-limit claim and later record refreshed users/sec evidence.
- **FILE-015**: `submission/local/j-gatling-max-limit/README.md` - update packaged max-limit summary.
- **FILE-016**: `submission/local/j-gatling-max-limit/max-limit-explanation.md` - update assignment-ready max-limit explanation.
- **FILE-017**: `submission/local/l-gatling-result-pdfs/graph-explanations.md` - update graph explanation after refreshed users/sec evidence exists.
- **FILE-018**: `docs/changelog/12-max-limit-staircase-refactor.changelog.md` - record implementation and verification when completed.

## 6. Testing

- **TEST-001**: `sh -n scripts/run-gatling-container scripts/run-gatling-max-limit scripts/run-gatling-load-5m scripts/run-gatling-stress-5m scripts/export-gatling-pdfs scripts/generate-pipeline-report` must pass.
- **TEST-002**: `sh tests/scripts/test-gatling-assertions.sh` must pass.
- **TEST-003**: `sh tests/scripts/test-run-gatling-max-limit.sh` must pass.
- **TEST-004**: `sh tests/test_gatling_max_limit_summary.sh` must pass.
- **TEST-005**: `sh tests/scripts/test-jenkinsfile-gatling-params.sh` must pass.
- **TEST-006**: `sh tests/scripts/test-gatling-har-alignment.sh` must pass.
- **TEST-007**: `git diff --check` must pass.
- **TEST-008**: `git diff --name-only` must show no Playwright implementation files unless a separate user request explicitly changes Playwright.
- **TEST-009**: No real Gatling evidence run is allowed during implementation validation unless the user explicitly requests evidence refresh.
- **TEST-010**: After a later user/Jenkins evidence refresh, the local max-limit PDF, screenshot, log, discovery log, and submission explanation must all use the same users/sec boundary values.

## 7. Risks & Assumptions

- **RISK-001**: Users/sec is an arrival-rate metric. If response times rise, active concurrent users can grow beyond the configured users/sec rate, so docs must not call the result concurrent users.
- **RISK-002**: Gatling assertions are evaluated after the simulation, not immediately on the first failed request. The users/sec staircase must therefore use a safe configured upper ceiling.
- **RISK-003**: If the users/sec range is too wide, the public EC2 host can be overloaded after the first failing level. Final public runs must use tight bounds.
- **RISK-004**: Existing submission artifacts currently describe concurrent virtual users. Leaving any of those values in the final package after the refactor would create contradictory evidence.
- **RISK-005**: Report-derived boundary parsing can be wrong if the first KO occurs during a ramp window. The wrapper must map ramp failures conservatively to the next users/sec level and state this in the discovery log.
- **RISK-006**: The users/sec boundary will not match the previous `8300` virtual-user boundary. This is expected because the metric changed.
- **ASSUMPTION-001**: The instructor's current direction supersedes the previous concurrent-user methodology for the assignment max-limit answer.
- **ASSUMPTION-002**: The defended max-limit cutoff remains `KO=0`.
- **ASSUMPTION-003**: Load and stress tests can remain concurrent-user based because the requested change is max-limit methodology only.
- **ASSUMPTION-004**: The user will trigger final local/public Jenkins evidence builds after the code and docs change is implemented.

## 8. Related Specifications / Further Reading

[Gatling container tests plan](./08-gatling-container-tests.md)
[Gatling evidence guide](../gatling.md)
[Jenkins guide](../jenkins.md)
[Submission package plan](./11-submission-package.md)
[Gatling documentation](https://docs.gatling.io/)
