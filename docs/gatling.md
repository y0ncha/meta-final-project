# Gatling Container Tests

## Runtime

- Gatling image: `denvazh/gatling:3.2.1`
- Gatling image platform: `linux/amd64`
- Docker network: `meta`
- Default Gatling target from Docker: `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Host evidence URL: `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Simulation source: `src/gatling/user-files/simulations/MetaSimulation.scala`
- HAR Converter reference: `src/gatling/user-files/simulations/reference/RecordedSimulationFromHar.scala`
- Shared runner: `scripts/run-gatling-container`
- Local container runner: direct disposable `docker run`
- Jenkins container runner: Jenkins Docker Pipeline using `docker.image(env.GATLING_IMAGE).inside(...)`

Gatling runs as a disposable container. Local scripts use direct `docker run`; Jenkins starts the same image through Docker Pipeline and runs the shared script body inside that container. Gatling is not installed on the host, it is not a long-running Compose service, and `/var/run/docker.sock` is not mounted into the Gatling container. The image is pinned to `denvazh/gatling:3.2.1` because the originally planned `gatlingcorp/gatling:3.15.0` image is not a public Docker Hub repository.

The HAR records the browser scenario. Gatling Recorder's HAR Converter generated the reference Scala simulation from `output/har/meta-functional-flow.har`; the maintained `MetaSimulation.scala` is the cleaned version used for repeatable max-limit, load, and stress runs. Gatling does not load the HAR file at runtime.

Each Gatling wrapper clears its stable output directory before starting a new run, preserves raw run directories under `raw/`, and normalizes the newest generated `index.html` into the stable path even when Gatling exits non-zero after producing an assertion-failure report. Jenkins also clears generated evidence directories at the start of non-timer builds so published artifacts come from the current build.

## Run Commands

Run these commands from the repository root after Tomcat is deployed:

```sh
./scripts/run-gatling-max-limit
./scripts/run-gatling-load-5m
./scripts/run-gatling-stress-5m
./scripts/export-gatling-pdfs
```

The target can be overridden when a real environment changes:

```sh
APP_BASE_URL=http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ ./scripts/run-gatling-load-5m
```

The maintained simulation uses closed virtual-user profiles:

- Load: 60 seconds ramping from 0 to `GATLING_LOAD_USERS`, 180 seconds holding that level, then 60 seconds ramping back down to 0.
- Stress: five 60-second staircase levels from `GATLING_STRESS_START_USERS` to `GATLING_STRESS_TARGET_USERS`. Jenkins defaults run from `5` to `50` virtual users, rounded across five levels.
- Max-limit: one bounded staircase simulation from `GATLING_MAX_BASE_USERS` through `GATLING_MAX_LIMIT_USERS`.

For max-limit staircase evidence, raise or bound the tested range with environment variables:

```sh
GATLING_MAX_BASE_USERS=8000 \
GATLING_MAX_STEP_USERS=20 \
GATLING_MAX_DURATION_SECONDS=10 \
GATLING_MAX_LIMIT_USERS=12000 \
./scripts/run-gatling-max-limit
```

## Max-Limit Method

The max-limit wrapper runs one Gatling simulation. Inside that simulation, one closed workload profile applies each staircase level sequentially, so the active-users graph increases from `GATLING_MAX_BASE_USERS` through `GATLING_MAX_LIMIT_USERS` without overlapping separate populations.

Each staircase level runs for `GATLING_MAX_DURATION_SECONDS`. If `GATLING_MAX_STEP_USERS` does not land exactly on `GATLING_MAX_LIMIT_USERS`, the final level is the configured limit and still runs for the full duration. Gatling assertions are evaluated after the simulation, not at the moment the first request fails, so the run must use a safe configured ceiling. The wrapper keeps the single staircase report and does not run repeated flat single-level attempts.

The class PDFs show Gatling evidence in terms of users, successes, failures, and graphs. They do not define a `p95 <= 2000 ms` service-level rule. For this project, max-limit pass/fail therefore follows the course-facing rule: a tested level passes only when Gatling reports `KO=0`. Response-time percentiles remain graph evidence for explaining degradation, but latency alone does not define the max-limit failure point.

The main controls are:

- `GATLING_MAX_BASE_USERS`: first virtual-user level to test.
- `GATLING_MAX_STEP_USERS`: virtual-user increment after each passing level.
- `GATLING_MAX_DURATION_SECONDS`: how long each virtual-user level is held.
- `GATLING_MAX_LIMIT_USERS`: highest virtual-user level to test before reporting a lower bound.

With Jenkins defaults, max-limit evidence tests a staircase from `8000` through `12000` virtual users in `20`-user steps, holding each level for `10` seconds. Choose tighter local or public ranges when you already know the failure region; do not run a broad public staircase far past the expected failure point.

Legacy users/sec-named variables are accepted by the shell wrappers only as compatibility aliases for older local commands. The Jenkins UI and current documentation use virtual-user terminology.

A tested level is treated as passing only when Gatling reports zero failed requests/checks/timeouts.

The max limit is the highest tested virtual-user level that passes before the first tested level that fails. If a run fails after a report is normalized, the wrapper treats that assertion failure as usable staircase evidence, preserves the report under `output/gatling/max-limit/`, and exits successfully so Jenkins can publish the evidence. The summary prints exact cutoff values only when they can be derived safely from the report; otherwise, inspect the report's time-based failure/error graphs and map the first KO timestamp to the `level schedule` lines in `output/gatling/max-limit/raw/max-limit-discovery.log`. If no tested level fails, the result is a tested lower bound, not the true application maximum.

## Evidence Files

- Max-limit log: `output/gatling/max-limit/max-limit-run.log`
- Max-limit report: `output/gatling/max-limit/index.html`
- Max-limit raw reports: `output/gatling/max-limit/raw/`
- Max-limit discovery log: `output/gatling/max-limit/raw/max-limit-discovery.log`
- Max-limit PDF: `output/gatling/max-limit/max-limit-report.pdf`
- Max-limit screenshot: `output/gatling/screenshots/max-limit-terminal.png`
- Load log: `output/gatling/load-5m/load-5m-run.log`
- Load report: `output/gatling/load-5m/index.html`
- Load raw reports: `output/gatling/load-5m/raw/`
- Load PDF: `output/gatling/load-5m/load-5m-report.pdf`
- Load screenshot: `output/gatling/screenshots/load-5m-terminal.png`
- Stress log: `output/gatling/stress-5m/stress-5m-run.log`
- Stress report: `output/gatling/stress-5m/index.html`
- Stress raw reports: `output/gatling/stress-5m/raw/`
- Stress PDF: `output/gatling/stress-5m/stress-5m-report.pdf`
- Stress screenshot: `output/gatling/screenshots/stress-5m-terminal.png`

Generated evidence remains ignored by Git under `output/`.

## Jenkins Integration

`Jenkinsfile` exposes one checkbox per Gatling stage:

- `RUN_GATLING_MAX_LIMIT=true` runs the exploratory `Gatling Max Limit` staircase separately.
- `RUN_GATLING_LOAD_TEST=true` runs the clean five-minute `Gatling Load Test`.
- `RUN_GATLING_STRESS_TEST=true` runs the clean five-minute `Gatling Stress Test`.
- Leave all three unchecked for normal CI/CD runs. Check only the specific Gatling evidence stage you intend to run.
- `GATLING_CONSOLE_MODE=summary` keeps the Jenkins console compact while preserving the complete Gatling run log under `output/gatling/<run-type>/`. For all Gatling runs, the console prints Gatling's native `Global Information` summary block instead of wrapper parameter lines or custom rewritten metrics. For max-limit, Jenkins console output also prints the wrapper's final staircase summary and KO cutoff rule. Wrapper parameter lines are written only to `output/gatling/max-limit/raw/max-limit-discovery.log`.
- `GATLING_CONSOLE_MODE=full` prints the complete Gatling run log to the Jenkins console.

Summary mode preserves Gatling's own report wording so Jenkins screenshots match the standard Gatling terminal summary expected for submission.

After this Jenkinsfile change is merged, run or reload the Pipeline once so Jenkins refreshes the Build with Parameters form.

For Jenkins max-limit staircase evidence, the build parameters expose the main bounds:

- `GATLING_MAX_BASE_USERS=8000`
- `GATLING_MAX_STEP_USERS=20`
- `GATLING_MAX_DURATION_SECONDS=10`
- `GATLING_MAX_LIMIT_USERS=12000`

With those defaults, Jenkins runs one staircase from 8000 through 12000 virtual users in 20-user steps. When any request/check/timeout fails, the console shows Gatling's native summary followed by the wrapper staircase summary. The tested range, exact command parameters, level-to-time schedule, KO cutoff rule, and report path are also recorded in `output/gatling/max-limit/raw/max-limit-discovery.log`.

Monitoring is handled by the separate Jenkins Freestyle job `meta-monitoring`, which runs `./scripts/run-monitoring-check`; the Gatling stages are not part of that scheduled job. Jenkins publishes Gatling HTML/PDF evidence through HTML Publisher when `index.html` exists under `output/gatling/max-limit/`, `output/gatling/load-5m/`, or `output/gatling/stress-5m/`.

Jenkins finalization exports Gatling PDFs from completed HTML reports in the `post` block before generating the final pipeline report. PDF export uses a temporary Playwright Docker Pipeline container because it is administrative report generation, not application validation.

Local `./scripts/export-gatling-pdfs` remains strict and requires all three Gatling reports. Jenkins runs the same script with `GATLING_PDF_REQUIRE_ALL=false` so normal builds that skip Gatling can still finish cleanly, while explicit Gatling evidence builds export the Gatling PDFs that were produced in that build.

## Graph Explanations

### Max Limit

The current packaged max-limit evidence must be refreshed after profile changes by the user or Jenkins. The refreshed max-limit PDF should show the active-users staircase increasing through the tested range. The max-limit conclusion must name the highest tested virtual-user level with `KO=0` and the first tested virtual-user level where Gatling reports any KO, using the discovery-log schedule to map report timestamps to levels when exact per-level counters are unavailable.

### Load 5m

The 5-minute load test ramps from 0 virtual users to `GATLING_LOAD_USERS` for 60 seconds, holds for 180 seconds, and ramps down to 0 for 60 seconds. After refreshing evidence, explain the active-users graph as ramp-up, plateau, and ramp-down; the request-rate graph as resulting throughput; and the response-time/KO graphs as system behavior under that load.

### Stress 5m

The 5-minute stress test uses five 60-second staircase levels from `GATLING_STRESS_START_USERS` to `GATLING_STRESS_TARGET_USERS`. After refreshing evidence, explain the active-users graph as those stepped levels, the request-rate graph as resulting throughput, and the response-time/KO graphs as the system response while load increases.

## Submission Notes

- Attach the three terminal or Jenkins-console screenshots.
- Attach the three generated Gatling PDFs.
- Include the max-limit conclusion and graph explanations in the final submission package.
- Do not claim a precise max limit unless the run shows a zero-KO passing level followed by a tested level with at least one KO.
- The max-limit, load, and stress terminal screenshots are packaged under `submission/local/k-gatling-cmd-screenshots/`.

## Troubleshooting

- If the Gatling container cannot resolve `tomcat`, confirm `docker compose up -d tomcat jenkins` has created Docker network `meta`.
- If Docker cannot pull `denvazh/gatling:3.2.1`, rerun when network access is available and keep the exact error in the changelog.
- If Jenkins cannot launch the Gatling container, confirm Jenkins has Docker socket access, the `docker-workflow` plugin, and a passing `Docker Pipeline Preflight` stage.
- If local PDF export fails, confirm the three `index.html` files exist before running `./scripts/export-gatling-pdfs`.
