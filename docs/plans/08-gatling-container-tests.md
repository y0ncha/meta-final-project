---
goal: Run Gatling Container Performance Tests and Produce Submission Evidence
version: 1.0
date_created: 2026-06-10
last_updated: 2026-06-10
owner: Yonatan
status: 'Evidence Pending'
tags:
  - devops
  - gatling
  - performance
  - docker
  - jenkins
  - evidence
  - submission
---

# Introduction

![Status: Evidence Pending](https://img.shields.io/badge/status-Evidence%20Pending-yellow)

This plan implements the Gatling deliverables required by `final-project.pdf` and `rules/compliance.md`. The result must run Gatling only through Docker, execute one max-limit discovery run, execute one 5-minute load test through Jenkins, execute one 5-minute stress test through Jenkins, save stable HTML reports under `output/gatling/`, export each report to PDF, capture terminal or Jenkins-console screenshots for all three runs, and document the actual graph interpretation without inventing performance numbers.

Follow-up update on 2026-06-10: Playwright, HAR, and Gatling validation runners no longer use profiled Compose runner services. Local validation scripts use direct disposable `docker run`; Jenkins starts Playwright and Gatling images through Docker Pipeline. Playwright functional validation and HAR capture intentionally use separate disposable containers so browser cache, filesystem state, and test output cannot leak between validation stages.

Follow-up update on 2026-06-10 after review: local `./scripts/export-gatling-pdfs` remains strict and requires all three Gatling reports, while Jenkins finalization runs it with `GATLING_PDF_REQUIRE_ALL=false` so the normal load/stress pipeline does not fail when optional max-limit discovery is skipped. The plan status is evidence pending, not completed, until the three Gatling terminal or Jenkins-console screenshots and live Jenkins build evidence are captured.

Follow-up update on 2026-06-11: the consolidated Pipeline HTML report now writes a companion `pipeline-report.css` file because Jenkins HTML Publisher can block inline styles. The report groups artifacts by evidence area, uses visible status badges, points artifact links at the current Jenkins job URL from `BUILD_URL`, labels missing max-limit artifacts as opt-in evidence requiring `RUN_GATLING_MAX_LIMIT=true`, and derives stage evidence state from generated artifacts where possible instead of claiming unavailable artifacts are available.

Follow-up update on 2026-06-11: the optional Jenkins `Gatling Max Limit` stage now runs the full `scripts/run-gatling-max-limit` discovery wrapper instead of the one-attempt primitive. The wrapper runs bounded complete stepped profiles until a normalized Gatling assertion-failure report is found or the configured attempt count is exhausted.

## 1. Requirements & Constraints

- **REQ-001**: Run Gatling through Docker only; do not require host `gatling`, host Scala, host sbt, or host Java for Gatling execution.
- **REQ-002**: Keep the target application URL configurable with `APP_BASE_URL`; default Gatling container execution to `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` on Docker network `meta`.
- **REQ-003**: Use Docker image `denvazh/gatling:3.2.1` by default through environment variable `GATLING_IMAGE="${GATLING_IMAGE:-denvazh/gatling:3.2.1}"`, because Docker Hub does not provide public image `gatlingcorp/gatling:3.15.0`.
- **REQ-003A**: Use Docker platform `linux/amd64` by default through environment variable `GATLING_PLATFORM="${GATLING_PLATFORM:-linux/amd64}"`, because `denvazh/gatling:3.2.1` is an amd64 image and the current Mac Docker host is arm64.
- **REQ-004**: Run Gatling containers on Docker network `meta` through direct local `docker run` or Jenkins Docker Pipeline.
- **REQ-005**: Add one shared runner script `scripts/run-gatling-container` that starts a disposable Gatling container locally and acts as the command body inside Jenkins Docker Pipeline when `GATLING_DOCKER_PIPELINE=1`.
- **REQ-006**: Add wrapper script `scripts/run-gatling-max-limit` for bounded full max-limit discovery and stable output directory `output/gatling/max-limit/`.
- **REQ-007**: Add wrapper script `scripts/run-gatling-load-5m` for the 5-minute load test and stable output directory `output/gatling/load-5m/`.
- **REQ-008**: Add wrapper script `scripts/run-gatling-stress-5m` for the 5-minute stress test and stable output directory `output/gatling/stress-5m/`.
- **REQ-009**: Create Gatling simulation source file `src/gatling/user-files/simulations/MetaSimulation.scala`.
- **REQ-010**: `MetaSimulation.scala` must execute an HTTP scenario against `/yonatan-csasznik-yoed-halberstam-niv-levin/`, request the app root, submit form data equivalent to `nameInput=Yonatan`, and validate successful HTTP responses.
- **REQ-011**: `MetaSimulation.scala` must select injection profiles from environment variable `GATLING_RUN_TYPE` with exact accepted values `max-limit`, `load-5m`, and `stress-5m`.
- **REQ-012**: The 5-minute load profile must run for exactly `300` seconds.
- **REQ-013**: The 5-minute stress profile must run for exactly `300` seconds.
- **REQ-014**: The max-limit profile must use deterministic stepped load levels and must not claim an exact maximum unless the generated Gatling evidence shows a failing threshold after a passing threshold.
- **REQ-015**: Use deterministic default load values: `GATLING_LOAD_USERS_PER_SEC=5`, `GATLING_STRESS_START_USERS_PER_SEC=5`, `GATLING_STRESS_TARGET_USERS_PER_SEC=50`, `GATLING_MAX_DISCOVERY_ATTEMPTS=3`, `GATLING_MAX_START_USERS_PER_SEC=5`, `GATLING_MAX_STEP_USERS_PER_SEC=5`, `GATLING_MAX_LEVEL_COUNT=10`, `GATLING_MAX_LEVEL_SECONDS=30`, and `GATLING_MAX_RAMP_SECONDS=10`.
- **REQ-016**: Use deterministic default pass criteria for max-limit analysis: failed request percentage must be less than `5`, and HTTP response time percentile 95 must be less than or equal to `2000` milliseconds for a load level to be treated as passing.
- **REQ-017**: Normalize every Gatling report so `index.html` exists directly at `output/gatling/max-limit/index.html`, `output/gatling/load-5m/index.html`, and `output/gatling/stress-5m/index.html`.
- **REQ-018**: Preserve raw Gatling run directories under `output/gatling/<run-type>/raw/`.
- **REQ-019**: Write combined stdout and stderr logs to `output/gatling/max-limit/max-limit-run.log`, `output/gatling/load-5m/load-5m-run.log`, and `output/gatling/stress-5m/stress-5m-run.log`.
- **REQ-020**: Export or print each stable Gatling HTML report to PDF at `output/gatling/max-limit/max-limit-report.pdf`, `output/gatling/load-5m/load-5m-report.pdf`, and `output/gatling/stress-5m/stress-5m-report.pdf`.
- **REQ-021**: Capture one terminal or Jenkins-console screenshot for each run at `output/gatling/screenshots/max-limit-terminal.png`, `output/gatling/screenshots/load-5m-terminal.png`, and `output/gatling/screenshots/stress-5m-terminal.png`.
- **REQ-022**: Document the actual run commands, result paths, graph interpretation, and max-limit conclusion in `docs/gatling.md`.
- **REQ-023**: Do not invent performance values. If max-limit evidence does not cross the defined failure threshold, document the result as a tested lower bound and rerun with larger values before claiming a maximum.
- **REQ-024**: Update `Jenkinsfile` so the required load and stress scripts run during non-timer CI/CD builds after deployment and before post-build archival.
- **REQ-025**: Add an optional Jenkins `Gatling Max Limit` stage controlled by boolean parameter `RUN_GATLING_MAX_LIMIT`, default `false`, so full max-limit discovery can be launched from Jenkins without running on every CI/CD build.
- **REQ-026**: Keep `Jenkinsfile` post-build HTML Publisher behavior compatible with stable report directories `output/gatling/max-limit/`, `output/gatling/load-5m/`, and `output/gatling/stress-5m/`.
- **REQ-027**: Keep generated Gatling reports, screenshots, PDFs, logs, and raw result directories ignored by Git under `output/`.
- **REQ-028**: Generate one final Jenkins Pipeline HTML report at `output/reports/pipeline-report.html` that summarizes stage evidence and links to archived Playwright, Gatling, HAR, and WAR artifacts when present.
- **REQ-028A**: The Pipeline stage table must not hard-code artifact-producing stages as available. It must derive artifact-backed stage evidence state from generated files and label console-only stages as console-log evidence.
- **REQ-029**: Keep `docker-compose.yml` limited to long-running services `tomcat` and `jenkins`; disposable validation containers must not be Compose services.
- **REQ-030**: Keep Playwright functional validation and HAR capture isolated by running them in separate fresh one-shot containers.
- **REQ-031**: Keep Gatling PDF export as Jenkins finalization work in `post { always { ... } }`, not as a separate validation stage.
- **SEC-001**: Do not mount `/var/run/docker.sock` into the Gatling container.
- **SEC-002**: Do not write GitHub tokens, Jenkins admin passwords, cookies, API keys, private keys, or other secrets into Gatling scripts, simulations, logs, documentation, screenshots, PDFs, or Jenkins configuration.
- **SEC-003**: Treat Gatling reports as generated evidence; review reports and logs before external sharing because request URLs, headers, or environment values may appear in output.
- **CON-001**: Read and obey `contribution.md` and `rules/compliance.md` before implementation; stop if any implementation step conflicts with the compliance rules.
- **CON-002**: Keep this work on branch `feature/08-gatling-container-tests` unless the user explicitly requests another branch.
- **CON-003**: Do not use host Tomcat, host Jenkins, `/usr/local/tomcat8`, `/Users/yonatan/.jenkins`, or any host Gatling installation.
- **CON-004**: Do not change Maven coordinate `mta.devops:meta:1.0.0`, Maven final name `yonatan-csasznik-yoed-halberstam-niv-levin`, Tomcat context path `/yonatan-csasznik-yoed-halberstam-niv-levin/`, Jenkins port `8081`, or Tomcat port `8080`.
- **CON-005**: Do not add Gatling, Playwright, or HAR runner services in `docker-compose.yml`; scripts and Jenkins Docker Pipeline must start disposable validation containers directly.
- **CON-006**: Do not install, upgrade, reinstall, or replace host tools while executing this plan.
- **GUD-001**: Prefer source-controlled scripts in `scripts/` over Jenkins UI-only shell commands so the defense workflow is repeatable.
- **GUD-002**: Prefer `rtk read`, `rtk grep`, `rtk diff`, and `rtk docker` for noisy inspection output when they preserve required detail.
- **PAT-001**: Follow the disposable-container runner pattern in `scripts/run-playwright-container`, `scripts/capture-har`, and `scripts/run-gatling-container`: project-root detection, configurable image, direct local Docker execution, explicit Docker Pipeline mode for Jenkins, and clear evidence paths.
- **PAT-002**: Follow the existing repository evidence pattern: source files are tracked, generated evidence is written under ignored `output/`, and plan completion is recorded in `docs/changelog/08-gatling-container-tests.changelog.md`.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Verify repository state, compliance constraints, and current Jenkins/Gatling hooks before editing implementation files.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Read `contribution.md` and confirm closeout branch, plan, and changelog requirements. | Yes | 2026-06-10 |
| TASK-002 | Read `rules/compliance.md` and confirm Docker-only Gatling evidence requirements. | Yes | 2026-06-10 |
| TASK-003 | Check `git status --short --branch` before closeout work. | Yes | 2026-06-10 |
| TASK-004 | Confirm work is on `feature/08-gatling-container-tests`. | Yes | 2026-06-10 |
| TASK-005 | Inspect `Jenkinsfile` Gatling stages and report publishing behavior. | Yes | 2026-06-10 |
| TASK-006 | Inspect the Playwright container runner pattern. | Yes | 2026-06-10 |
| TASK-007 | Inspect Compose service/network assumptions for Tomcat and Jenkins. | Yes | 2026-06-10 |
| TASK-008 | Inspect Jenkins documentation for Gatling report paths. | Yes | 2026-06-10 |

### Implementation Phase 2

- GOAL-002: Add Gatling simulation source and deterministic run-type configuration.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-009 | Create `src/gatling/user-files/simulations/`. | Yes | 2026-06-10 |
| TASK-010 | Create `MetaSimulation.scala`. | Yes | 2026-06-10 |
| TASK-011 | Import Gatling core, HTTP, and duration APIs. | Yes | 2026-06-10 |
| TASK-012 | Configure `APP_BASE_URL`, root URL, and submit URL. | Yes | 2026-06-10 |
| TASK-013 | Validate `GATLING_RUN_TYPE` values. | Yes | 2026-06-10 |
| TASK-014 | Add positive numeric environment helpers. | Yes | 2026-06-10 |
| TASK-015 | Configure HTTP protocol headers. | Yes | 2026-06-10 |
| TASK-016 | Define GET and POST JSP scenario checks. | Yes | 2026-06-10 |
| TASK-017 | Define 300-second load profile. | Yes | 2026-06-10 |
| TASK-018 | Define 300-second stress profile. | Yes | 2026-06-10 |
| TASK-019 | Define deterministic stepped max-limit profile. | Yes | 2026-06-10 |
| TASK-020 | Select injection profile and assertions by run type. | Yes | 2026-06-10 |
| TASK-021 | Confirm Gatling Docker image can run. | Yes | 2026-06-10 |

### Implementation Phase 3

- GOAL-003: Add local and Jenkins-compatible Gatling container runners.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-022 | Create executable `scripts/run-gatling-container`. | Yes | 2026-06-10 |
| TASK-023 | Add project-root detection and repository-root execution. | Yes | 2026-06-10 |
| TASK-024 | Validate `GATLING_RUN_TYPE` in the runner. | Yes | 2026-06-10 |
| TASK-025 | Define configurable Gatling image, platform, network, URL, and load values. | Yes | 2026-06-10 |
| TASK-026 | Define no-prefix evidence paths under `output/gatling/<run-type>/`. | Yes | 2026-06-10 |
| TASK-027 | Create output, raw, and screenshot directories. | Yes | 2026-06-10 |
| TASK-028 | Fail clearly when Docker is missing. | Yes | 2026-06-10 |
| TASK-029 | Run Gatling locally through one-shot Docker container. | Yes | 2026-06-10 |
| TASK-030 | Run Gatling from Jenkins with `--volumes-from meta-jenkins`. | Yes | 2026-06-10 |
| TASK-031 | Capture and print combined stdout/stderr logs. | Yes | 2026-06-10 |
| TASK-032 | Normalize newest raw report into stable output directory. | Yes | 2026-06-10 |
| TASK-033 | Print evidence paths after successful normalization. | Yes | 2026-06-10 |
| TASK-034 | Create max-limit wrapper script. | Yes | 2026-06-10 |
| TASK-035 | Create load 5m wrapper script. | Yes | 2026-06-10 |
| TASK-036 | Create stress 5m wrapper script. | Yes | 2026-06-10 |
| TASK-037 | Ensure Gatling scripts are executable. | Yes | 2026-06-10 |

### Implementation Phase 4

- GOAL-004: Add automated PDF export and deterministic evidence documentation.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-038 | Create executable `scripts/export-gatling-pdfs`. | Yes | 2026-06-10 |
| TASK-039 | Export reports through disposable Playwright container. | Yes | 2026-06-10 |
| TASK-040 | Create `tests/playwright/export-gatling-pdfs.js`. | Yes | 2026-06-10 |
| TASK-041 | Fail PDF export when required report HTML is missing. | Yes | 2026-06-10 |
| TASK-042 | Generate non-empty PDFs from each Gatling HTML report. | Yes | 2026-06-10 |
| TASK-043 | Create `docs/gatling.md`. | Yes | 2026-06-10 |
| TASK-044 | Document Gatling runtime image, platform, network, and URLs. | Yes | 2026-06-10 |
| TASK-045 | Document Gatling run and PDF export commands. | Yes | 2026-06-10 |
| TASK-046 | Document max-limit pass criteria and lower-bound rule. | Yes | 2026-06-10 |
| TASK-047 | Document log, report, raw, PDF, and screenshot evidence paths. | Yes | 2026-06-10 |
| TASK-048 | Document Jenkins Gatling integration. | Yes | 2026-06-10 |
| TASK-049 | Replace placeholder graph explanations with real report-backed explanations. | Yes | 2026-06-10 |

### Implementation Phase 5

- GOAL-005: Integrate Gatling execution with Jenkins while preserving the separate scheduled monitoring job.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-050 | Add `RUN_GATLING_MAX_LIMIT` Jenkins parameter. | Yes | 2026-06-10 |
| TASK-051 | Add optional `Gatling Max Limit` stage. | Yes | 2026-06-10 |
| TASK-052 | Keep `Gatling Load Test` stage wired to load wrapper. | Yes | 2026-06-10 |
| TASK-053 | Keep `Gatling Stress Test` stage wired to stress wrapper. | Yes | 2026-06-10 |
| TASK-054 | Publish Gatling HTML/PDF reports through HTML Publisher. | Yes | 2026-06-10 |
| TASK-055 | Create `scripts/generate-pipeline-report`. | Yes | 2026-06-10 |
| TASK-056 | Archive and publish consolidated pipeline report. | Yes | 2026-06-10 |
| TASK-057 | Update Jenkins documentation for Gatling and pipeline reports. | Yes | 2026-06-10 |

### Implementation Phase 6

- GOAL-006: Run local and Jenkins validations, produce evidence, and close the plan only after real artifacts exist.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-058 | Run shell syntax checks. | Yes | 2026-06-10 |
| TASK-059 | Run Node syntax check for PDF exporter. | Yes | 2026-06-10 |
| TASK-060 | Generate non-empty pipeline report. | Yes | 2026-06-10 |
| TASK-061 | Verify Docker Compose services are running. | Yes | 2026-06-10 |
| TASK-062 | Deploy WAR and verify Tomcat URL output. | Yes | 2026-06-10 |
| TASK-063 | Produce max-limit report and non-empty no-prefix log. | Yes | 2026-06-10 |
| TASK-064 | Produce load 5m report and non-empty no-prefix log. | Yes | 2026-06-10 |
| TASK-065 | Produce clean stress 5m report and non-empty no-prefix log. | Yes | 2026-06-10 |
| TASK-066 | Export all three Gatling PDFs. | Yes | 2026-06-10 |
| TASK-067 | Capture Gatling terminal or Jenkins-console screenshots. | Deferred for final submission screenshot capture | 2026-06-10 |
| TASK-068 | Validate Jenkins-container load execution path. | Source/docs verified; live Jenkins evidence deferred | 2026-06-10 |
| TASK-069 | Validate Jenkins-container stress execution path. | Source/docs verified; live Jenkins evidence deferred | 2026-06-10 |
| TASK-070 | Validate non-timer Jenkins load/stress build behavior. | Source/docs verified; live Jenkins evidence deferred | 2026-06-10 |
| TASK-071 | Validate optional Jenkins max-limit behavior. | Source/docs verified; live Jenkins evidence deferred | 2026-06-10 |
| TASK-072 | Update graph explanations from real Gatling reports. | Yes | 2026-06-10 |
| TASK-073 | Verify pipeline report exists. | Yes | 2026-06-10 |
| TASK-074 | Verify all three Gatling HTML reports exist. | Yes | 2026-06-10 |
| TASK-075 | Verify all three Gatling PDFs exist. | Yes | 2026-06-10 |
| TASK-076 | Verify all three Gatling terminal screenshots exist. | Deferred for final submission screenshot capture | 2026-06-10 |
| TASK-077 | Verify generated evidence remains ignored by Git. | Yes | 2026-06-10 |
| TASK-078 | Run compliance validator and inspect manual items. | Yes | 2026-06-10 |
| TASK-079 | Run `git diff --check`. | Yes | 2026-06-10 |
| TASK-080 | Create matching Plan 08 changelog. | Yes | 2026-06-10 |
| TASK-081 | Record evidence-pending status with screenshot and live Jenkins evidence deferral. | Yes | 2026-06-10 |

### Implementation Phase 7

- GOAL-007: Convert disposable runners from profiled Compose services to direct Docker local execution plus Jenkins Docker Pipeline.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-082 | Remove profiled runner services from `docker-compose.yml` so only `tomcat` and `jenkins` remain as Compose services. | Yes | 2026-06-10 |
| TASK-083 | Update Jenkins Playwright and Gatling stages to use `docker.image(...).inside(...)` with `--network meta`, `--volumes-from meta-jenkins`, and working directory `env.WORKSPACE` so containers run from the SCM checkout. | Yes | 2026-06-10 |
| TASK-084 | Update `scripts/run-playwright-container` to use direct local `docker run` and `PLAYWRIGHT_DOCKER_PIPELINE=1` inside Jenkins Docker Pipeline. | Yes | 2026-06-10 |
| TASK-085 | Update `scripts/capture-har` to use a separate direct Docker container, preserving validation isolation from the functional Playwright test. | Yes | 2026-06-10 |
| TASK-086 | Update `scripts/run-gatling-container` to use direct local Docker and `GATLING_DOCKER_PIPELINE=1` while preserving stable report normalization. | Yes | 2026-06-10 |
| TASK-087 | Update `scripts/export-gatling-pdfs` to use direct local Docker and Playwright Docker Pipeline mode for administrative PDF export. | Yes | 2026-06-10 |
| TASK-088 | Update `Jenkinsfile` post-build behavior so Gatling PDF export runs in a Playwright Docker Pipeline container before final report generation and publishing. | Yes | 2026-06-10 |
| TASK-089 | Update Playwright, HAR, Gatling, Jenkins, and Plan 05 documentation to describe Docker Pipeline/direct Docker execution and validation isolation. | Yes | 2026-06-10 |
| TASK-090 | Validate Compose configuration with `docker compose config --quiet`. | Yes | 2026-06-10 |
| TASK-091 | Validate script syntax and representative runner execution after the Docker Pipeline conversion. | Yes | 2026-06-10 |
| TASK-092 | Fix Jenkins Gatling PDF finalization so builds that skip optional max-limit discovery still export produced load/stress reports. | Yes | 2026-06-10 |
| TASK-093 | Clear stale generated evidence at the start of non-timer Jenkins builds and preserve Gatling reports when assertion failures produce useful evidence. | Yes | 2026-06-10 |

### Implementation Phase 8

- GOAL-008: Improve the consolidated Pipeline HTML report rendering without changing evidence semantics.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-094 | Add a regression test for generated report rendering, current Jenkins artifact URLs, and optional max-limit wording. | Yes | 2026-06-11 |
| TASK-095 | Generate external `pipeline-report.css` so Jenkins HTML Publisher can apply report styling under CSP restrictions. | Yes | 2026-06-11 |
| TASK-096 | Replace run-together summary labels with a semantic metadata grid. | Yes | 2026-06-11 |
| TASK-097 | Group published artifacts by build, Playwright, Gatling, and HAR evidence areas with status badges. | Yes | 2026-06-11 |
| TASK-098 | Keep max-limit evidence honest by marking missing max-limit artifacts as opt-in/not-run instead of an unexpected missing failure. | Yes | 2026-06-11 |
| TASK-099 | Derive the Pipeline stage table evidence state from produced artifacts where possible and label console-only stages as `Console log`. | Yes | 2026-06-11 |

### Implementation Phase 9

- GOAL-009: Make opt-in max-limit execution perform bounded full discovery.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-100 | Add a shell regression test for `scripts/run-gatling-max-limit` discovery attempts using a stubbed Gatling runner. | Yes | 2026-06-11 |
| TASK-101 | Update `scripts/run-gatling-max-limit` to run repeated complete stepped profiles and stop on the first normalized assertion-failure report. | Yes | 2026-06-11 |
| TASK-102 | Update `Jenkinsfile` so `RUN_GATLING_MAX_LIMIT=true` calls the max-limit wrapper instead of `scripts/run-gatling-container` directly. | Yes | 2026-06-11 |
| TASK-103 | Increase the Jenkins pipeline timeout to allow the opt-in full max-limit discovery plus the required load and stress stages. | Yes | 2026-06-11 |
| TASK-104 | Update Gatling docs, plan, and changelog with the bounded full-discovery behavior. | Yes | 2026-06-11 |

## 3. Alternatives

- **ALT-001**: Install Gatling on the host and run `gatling.sh` directly. Rejected because `rules/compliance.md` requires Gatling in Docker and forbids host Gatling as a project runtime dependency.
- **ALT-002**: Add Gatling or Playwright runner services in `docker-compose.yml`. Rejected because Compose now owns only regular services `tomcat` and `jenkins`; validation runners start as disposable direct Docker or Jenkins Docker Pipeline containers.
- **ALT-003**: Run Gatling only from the Jenkins UI with inline shell commands. Rejected because the workflow would not be reproducible from source control and would be harder to defend live.
- **ALT-004**: Use the Jenkins Gatling plugin `gatlingArchive()` immediately. Rejected until a real Plan 08 run proves that the generated Gatling output shape matches the plugin's expectations; HTML Publisher already satisfies report visibility for this coursework deliverable.
- **ALT-005**: Run max-limit discovery on every Jenkins CI/CD build. Rejected because max-limit discovery can be disruptive and is not required on every source change; it must be manually enabled with `RUN_GATLING_MAX_LIMIT=true`.
- **ALT-006**: Claim the highest configured max-limit step as the application maximum when no failure threshold is crossed. Rejected because `rules/compliance.md` forbids invented performance numbers; that result is only a tested lower bound.
- **ALT-007**: Export Gatling PDFs manually only through the browser print dialog. Rejected as the primary path because automated Playwright PDF export is repeatable; manual print remains an emergency fallback if automated PDF export is blocked and the blocker is documented.

## 4. Dependencies

- **DEP-001**: `final-project.pdf` is the authoritative assignment source; `rules/compliance.md` is the active operational checklist.
- **DEP-002**: `contribution.md` defines branch, implementation-plan, validation, and changelog workflow.
- **DEP-003**: Docker Engine must be running and able to start one-shot containers.
- **DEP-004**: Docker network `meta` must exist through `docker-compose.yml`.
- **DEP-005**: Docker Compose service `tomcat` must serve the deployed JSP app at internal URL `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **DEP-006**: Docker Compose service `jenkins` must mount `/var/run/docker.sock` so Jenkins can start disposable Gatling containers.
- **DEP-007**: Docker image `denvazh/gatling:3.2.1` must be available locally or pullable from the configured Docker registry.
- **DEP-008**: Docker image `mcr.microsoft.com/playwright:v1.60.0-noble` must be available locally or pullable for automated PDF export.
- **DEP-009**: `scripts/deploy-war` must exist, remain executable, and deploy `target/yonatan-csasznik-yoed-halberstam-niv-levin.war` before Gatling runs.
- **DEP-010**: `Jenkinsfile` must remain the source-controlled Pipeline job script for `meta-container-ci-cd`.
- **DEP-011**: Jenkins plugin `htmlpublisher` must remain installed in the custom Jenkins image so Gatling reports appear in build pages.
- **DEP-012**: Generated evidence under `output/` must remain ignored by `.gitignore`.

## 5. Files

- **FILE-001**: `docs/plans/08-gatling-container-tests.md` - this executable implementation plan.
- **FILE-002**: `docker-compose.yml` - Compose project with only regular services `tomcat` and `jenkins`.
- **FILE-003**: `src/gatling/user-files/simulations/MetaSimulation.scala` - Gatling simulation for max-limit, load, and stress profiles.
- **FILE-003A**: `scripts/run-playwright-container` - direct Docker local runner and Jenkins Docker Pipeline command body.
- **FILE-003B**: `scripts/capture-har` - direct Docker HAR capture runner using a separate Playwright container.
- **FILE-003C**: `scripts/run-gatling-container` - shared direct Docker local runner and Jenkins Docker Pipeline command body.
- **FILE-004**: `scripts/run-gatling-max-limit` - wrapper for max-limit discovery.
- **FILE-005**: `scripts/run-gatling-load-5m` - wrapper for the 5-minute load test.
- **FILE-006**: `scripts/run-gatling-stress-5m` - wrapper for the 5-minute stress test.
- **FILE-007**: `scripts/export-gatling-pdfs` - Dockerized Playwright PDF exporter for Gatling HTML reports.
- **FILE-008**: `tests/playwright/export-gatling-pdfs.js` - Node/Playwright helper that prints Gatling HTML reports to PDF.
- **FILE-009**: `Jenkinsfile` - Pipeline definition updated with optional max-limit execution and confirmed load/stress execution.
- **FILE-010**: `docs/jenkins.md` - Jenkins documentation updated with Gatling stages and report evidence paths.
- **FILE-011**: `docs/gatling.md` - Gatling runtime, commands, evidence, max-limit method, and graph explanations.
- **FILE-012**: `scripts/generate-pipeline-report` - shell-only generator for the consolidated Jenkins Pipeline HTML report.
- **FILE-013**: `docs/changelog/08-gatling-container-tests.changelog.md` - closeout changelog created after validation.
- **FILE-014**: `output/reports/pipeline-report.html` - ignored generated final Pipeline HTML report.
- **FILE-015**: `output/reports/pipeline-report.css` - ignored generated stylesheet for the final Pipeline HTML report.
- **FILE-016**: `tests/scripts/test-generate-pipeline-report.sh` - shell regression test for consolidated report rendering.
- **FILE-017**: `output/gatling/max-limit/` - ignored generated max-limit evidence directory.
- **FILE-018**: `output/gatling/load-5m/` - ignored generated load-test evidence directory.
- **FILE-019**: `output/gatling/stress-5m/` - ignored generated stress-test evidence directory.
- **FILE-020**: `output/gatling/screenshots/` - ignored generated terminal or Jenkins-console screenshots.

## 6. Testing

- **TEST-001**: `sh -n scripts/run-gatling-container scripts/run-gatling-max-limit scripts/run-gatling-load-5m scripts/run-gatling-stress-5m scripts/export-gatling-pdfs scripts/generate-pipeline-report` must pass.
- **TEST-002**: `node --check tests/playwright/export-gatling-pdfs.js` must pass.
- **TEST-003**: `./scripts/generate-pipeline-report` must create non-empty `output/reports/pipeline-report.html`.
- **TEST-003A**: `sh tests/scripts/test-generate-pipeline-report.sh` must pass and prove the generated report uses external CSS, current Jenkins artifact URLs, status badges, opt-in max-limit wording, and evidence-backed stage states for missing/present artifacts.
- **TEST-003B**: `sh tests/scripts/test-run-gatling-max-limit.sh` must pass and prove max-limit discovery repeats complete profiles, advances the user-per-second window, and stops on the first normalized threshold failure.
- **TEST-004**: `docker compose config --quiet` must pass.
- **TEST-004A**: `docker compose up -d tomcat jenkins` must start both services.
- **TEST-005**: `./scripts/deploy-war` must pass and print `Deployed URL: http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **TEST-006**: `./scripts/run-gatling-max-limit` must pass or fail only with a documented threshold failure; it must create `output/gatling/max-limit/max-limit-run.log`.
- **TEST-007**: `./scripts/run-gatling-load-5m` must pass and create `output/gatling/load-5m/index.html`.
- **TEST-008**: `./scripts/run-gatling-stress-5m` must pass and create `output/gatling/stress-5m/index.html`.
- **TEST-009**: `./scripts/export-gatling-pdfs` must create all three required Gatling PDF files.
- **TEST-009A**: `GATLING_PDF_REQUIRE_ALL=false ./scripts/export-gatling-pdfs` must allow Jenkins-style partial export when optional max-limit evidence is not present.
- **TEST-009B**: `scripts/run-gatling-container` must remove stale stable outputs before each run and normalize the latest raw report before returning a Gatling assertion failure status.
- **TEST-010**: Jenkins-compatible execution path must remain source-controlled through `Jenkinsfile` and `scripts/run-gatling-container`.
- **TEST-011**: Jenkins job `meta-container-ci-cd` should be rerun before final submission to capture live build-page evidence.
- **TEST-012**: Jenkins job `meta-container-ci-cd` should run `Gatling Load Test` and `Gatling Stress Test` successfully in a non-timer build before final submission.
- **TEST-013**: Jenkins job `meta-container-ci-cd` should run full `Gatling Max Limit` discovery successfully when `RUN_GATLING_MAX_LIMIT=true` before final submission.
- **TEST-014**: Jenkins HTML Publisher should expose `Pipeline Final Report`, `Gatling Max Limit Report`, `Gatling Load 5m Report`, and `Gatling Stress 5m Report` when the corresponding report files exist.
- **TEST-015**: `test -s output/reports/pipeline-report.html && test -s output/gatling/max-limit/index.html && test -s output/gatling/load-5m/index.html && test -s output/gatling/stress-5m/index.html` must pass.
- **TEST-016**: `test -s output/gatling/max-limit/max-limit-report.pdf && test -s output/gatling/load-5m/load-5m-report.pdf && test -s output/gatling/stress-5m/stress-5m-report.pdf` must pass.
- **TEST-017**: Gatling screenshot files are intentionally deferred; `docs/submission.md` lists them as required before final email submission.
- **TEST-018**: `git check-ignore output/reports/pipeline-report.html output/gatling/max-limit/index.html output/gatling/load-5m/index.html output/gatling/stress-5m/index.html output/gatling/max-limit/max-limit-report.pdf output/gatling/screenshots/max-limit-terminal.png` must report every path as ignored.
- **TEST-019**: `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md` must report no unreviewed failures before completion.
- **TEST-020**: `git diff --check` must pass before commit.
- **TEST-021**: `./scripts/run-playwright-container` and `./scripts/capture-har` must each launch a fresh disposable container rather than reusing the same Playwright container.

## 7. Risks & Assumptions

- **RISK-001**: `denvazh/gatling:3.2.1` is an older public Gatling image; use it only because the planned `gatlingcorp/gatling:3.15.0` repository is not public. If the lecturer requires a newer Gatling version, replace the runner with a Dockerized Maven or custom-image path and recapture evidence.
- **RISK-002**: The selected default discovery attempts may not reach the application's true failure point; in that case, the max-limit result is only a tested lower bound until the run is repeated with larger values or more attempts.
- **RISK-003**: Gatling container execution from Jenkins depends on Docker socket access and `--volumes-from meta-jenkins`; this is an accepted coursework tradeoff and not a production security pattern.
- **RISK-004**: The three Gatling runs can take longer than the current Jenkins pipeline timeout if Docker image pulls are slow or max-limit discovery uses many attempts; adjust the attempt count before raising timeout further.
- **RISK-005**: Gatling reports may use nested raw result directories by default; the runner must normalize the latest report to stable `index.html` paths before Jenkins HTML Publisher can expose them.
- **RISK-006**: Automated PDF export may fail if the Gatling HTML report depends on browser features blocked by local file URLs; document the blocker and use browser print as a fallback only after preserving the failed command evidence.
- **RISK-007**: The assignment asks for CMD screenshots; Jenkins-console screenshots are acceptable only if they clearly show the run summary and command context. If there is any grading doubt, capture host terminal screenshots for all three runs.
- **RISK-008**: Jenkins runner services depend on Docker socket access plus the existing Jenkins container volume mounts. This keeps browser/Gatling dependencies outside the Jenkins image, but it is not a production security pattern.
- **ASSUMPTION-001**: The app remains deployed at context path `/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **ASSUMPTION-002**: Docker Compose network name remains `meta`.
- **ASSUMPTION-003**: Jenkins job `meta-container-ci-cd` continues to use the repository `Jenkinsfile`.
- **ASSUMPTION-004**: Generated evidence remains ignored under `output/` and is attached to the final submission package outside Git.
- **ASSUMPTION-005**: The project continues using Playwright container `mcr.microsoft.com/playwright:v1.60.0-noble` for browser automation and PDF export support.

## 8. Related Specifications / Further Reading

- [Final project compliance rules](../../rules/compliance.md)
- [Contribution workflow](../../contribution.md)
- [Docker Compose foundation plan](./02-docker-compose-foundation.md)
- [Tomcat container deployment plan](./04-tomcat-container-deployment.md)
- [Jenkins container CI/CD plan](./05-jenkins-container-ci-cd.md)
- [Playwright container functional test plan](./06-playwright-container-functional-test.md)
- [HAR capture plan](./07-har-capture.md)
- [Monitoring and Jenkins schedule plan](./09-monitoring-and-jenkins-schedule.md)
- [Submission package plan](./11-submission-package.md)
- [Gatling documentation](https://docs.gatling.io/)
