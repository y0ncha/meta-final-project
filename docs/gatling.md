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

For max-limit discovery, raise or bound the search with environment variables:

```sh
GATLING_MAX_BASE_USERS=50 \
GATLING_MAX_STEP_USERS=50 \
GATLING_MAX_DURATION_SECONDS=30 \
GATLING_MAX_LIMIT_USERS=1000 \
./scripts/run-gatling-max-limit
```

## Max-Limit Method

The max-limit wrapper runs one virtual-user level at a time until a Gatling assertion failure is found or the configured upper bound is reached. This lets the wrapper report both the highest passing tested virtual-user level and the first failing tested level.

The class PDFs show Gatling evidence in terms of users, successes, failures, and graphs. They do not define a `p95 <= 2000 ms` service-level rule. For this project, max-limit pass/fail therefore follows the course-facing rule: a tested level passes only when Gatling reports `KO=0`. Response-time percentiles remain graph evidence for explaining degradation, but latency alone does not define the max-limit failure point.

The main controls are:

- `GATLING_MAX_BASE_USERS`: first virtual-user level to test.
- `GATLING_MAX_STEP_USERS`: virtual-user increment after each passing level.
- `GATLING_MAX_DURATION_SECONDS`: how long each virtual-user level is held.
- `GATLING_MAX_LIMIT_USERS`: highest virtual-user level to test before reporting a lower bound.

With Jenkins defaults, max-limit discovery tests `50`, `100`, `150`, and so on through `1000` virtual users unless a Gatling assertion threshold is crossed earlier. Each tested level lasts `30` seconds.

Legacy users/sec-named variables are accepted by the shell wrappers only as compatibility aliases for older local commands. The Jenkins UI and current documentation use virtual-user terminology.

A tested level is treated as passing only when Gatling reports zero failed requests/checks/timeouts.

The max limit is the highest tested virtual-user level that passes before the first tested level that fails. If a run fails after a report is normalized, the wrapper treats that assertion failure as successful discovery evidence, prints the exact first failing tested virtual-user level, and preserves the failing report under `output/gatling/max-limit/`. If no tested level fails, the result is a tested lower bound, not the true application maximum.

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

`Jenkinsfile` gates all Gatling evidence stages behind one build parameter:

- `RUN_GATLING_TESTS=false` skips all Gatling stages for normal CI/CD runs.
- `RUN_GATLING_TESTS=true` runs `Gatling Max Limit`, `Gatling Load Test`, and `Gatling Stress Test` when their runner scripts exist.
- Use `RUN_GATLING_TESTS=true` for final performance evidence collection.
- `GATLING_CONSOLE_MODE=summary` keeps the Jenkins console compact while preserving the complete Gatling run log under `output/gatling/<run-type>/`. For all Gatling runs, the console prints Gatling's native `Global Information` summary block instead of a custom rewritten metrics line. Each test starts with one short parameter line: `load test started : <users> virtual users | duration: 300s`, `stress test started : <start>-<target> virtual users | duration: 300s`, or `max limit tests started : <range> virtual users | step: <step> virtual users | duration: <seconds>s per level`. For max-limit discovery, each passing level prints one short `max limit level finished : <level> virtual users | duration: <seconds>s | passed` ping while artifact path lines stay out of the console. Per-level progress is kept in `output/gatling/max-limit/raw/max-limit-discovery.log`. When a failing level exists, the console prints only that failing level's native summary, followed by one final max-limit test summary with the tested range, step, duration, highest passing tested level, and first failing tested level. If no level fails, the final summary reports a tested lower bound.
- `GATLING_CONSOLE_MODE=full` prints the complete Gatling run log to the Jenkins console.

Summary mode preserves Gatling's own report wording so Jenkins screenshots match the standard Gatling terminal summary expected for submission.

After this Jenkinsfile change is merged, run or reload the Pipeline once so Jenkins refreshes the Build with Parameters form. The old `RUN_GATLING_MAX_LIMIT` parameter is obsolete and should not be used for new evidence runs.

For Jenkins max-limit discovery, the build parameters expose the main discovery bounds:

- `GATLING_MAX_BASE_USERS=50`
- `GATLING_MAX_STEP_USERS=50`
- `GATLING_MAX_DURATION_SECONDS=30`
- `GATLING_MAX_LIMIT_USERS=1000`

With those defaults, Jenkins tests single levels from 50 through 1000 virtual users in 50-user steps unless a Gatling assertion threshold is crossed earlier. When a threshold is crossed, the console log reports the highest passing tested level and the first failing tested level.

Monitoring is handled by the separate Jenkins Freestyle job `meta-monitoring`, which runs `./scripts/run-monitoring-check`; the Gatling stages are not part of that scheduled job. Jenkins publishes Gatling HTML/PDF evidence through HTML Publisher when `index.html` exists under `output/gatling/max-limit/`, `output/gatling/load-5m/`, or `output/gatling/stress-5m/`.

Jenkins finalization exports Gatling PDFs from completed HTML reports in the `post` block before generating the final pipeline report. PDF export uses a temporary Playwright Docker Pipeline container because it is administrative report generation, not application validation.

Local `./scripts/export-gatling-pdfs` remains strict and requires all three Gatling reports. Jenkins runs the same script with `GATLING_PDF_REQUIRE_ALL=false` so normal builds that skip Gatling can still finish cleanly, while explicit `RUN_GATLING_TESTS=true` evidence builds export the Gatling PDFs that were produced in that build.

## Graph Explanations

### Max Limit

The current packaged max-limit evidence was produced before the HAR-derived scenario and virtual-user terminology were adopted. It remains historical graph evidence only. Refresh with `RUN_GATLING_TESTS=true` before final submission. Under the current rule, the max-limit conclusion must name the highest tested virtual-user level with `KO=0` and the first tested virtual-user level where Gatling reports any KO.

### Load 5m

The 5-minute load test holds the default fixed virtual-user level for 300 seconds. After refreshing evidence, explain the active-users graph as a stable concurrent-user level, the request-rate graph as resulting throughput, and the response-time/KO graphs as system behavior under that load.

### Stress 5m

The 5-minute stress test ramps concurrent virtual users from the configured start level to the target level over 300 seconds. After refreshing evidence, explain the active-users graph as the configured ramp, the request-rate graph as resulting throughput, and the response-time/KO graphs as the system response while load increases.

## Submission Notes

- Attach the three terminal or Jenkins-console screenshots.
- Attach the three generated Gatling PDFs.
- Include the max-limit conclusion and graph explanations in the final submission package.
- Do not claim a precise max limit unless the run shows a zero-KO passing level followed by a tested level with at least one KO.
- The stress terminal screenshot is packaged under `submission/local/k-gatling-cmd-screenshots/`; the max-limit and load terminal screenshots must still be added before final submission.

## Troubleshooting

- If the Gatling container cannot resolve `tomcat`, confirm `docker compose up -d tomcat jenkins` has created Docker network `meta`.
- If Docker cannot pull `denvazh/gatling:3.2.1`, rerun when network access is available and keep the exact error in the changelog.
- If Jenkins cannot launch the Gatling container, confirm Jenkins has Docker socket access, the `docker-workflow` plugin, and a passing `Docker Pipeline Preflight` stage.
- If local PDF export fails, confirm the three `index.html` files exist before running `./scripts/export-gatling-pdfs`.
