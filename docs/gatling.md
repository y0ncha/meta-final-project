# Gatling Container Tests

## Runtime

- Gatling image: `denvazh/gatling:3.2.1`
- Gatling image platform: `linux/amd64`
- Docker network: `meta`
- Default Gatling target from Docker: `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Host evidence URL: `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Simulation source: `src/gatling/user-files/simulations/MetaSimulation.scala`
- Shared runner: `scripts/run-gatling-container`
- Local container runner: direct disposable `docker run`
- Jenkins container runner: Jenkins Docker Pipeline using `docker.image(env.GATLING_IMAGE).inside(...)`

Gatling runs as a disposable container. Local scripts use direct `docker run`; Jenkins starts the same image through Docker Pipeline and runs the shared script body inside that container. Gatling is not installed on the host, it is not a long-running Compose service, and `/var/run/docker.sock` is not mounted into the Gatling container. The image is pinned to `denvazh/gatling:3.2.1` because the originally planned `gatlingcorp/gatling:3.15.0` image is not a public Docker Hub repository.

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

## Max-Limit Method

The default max-limit run starts at `5` users per second, increases by `5` users per second for `10` levels, keeps each level for `30` seconds, and uses `10` second ramps between levels.

A tested level is treated as passing only when both conditions hold:

- Failed request percentage is less than `5`.
- HTTP response time percentile 95 is less than or equal to `2000` milliseconds.

The max limit is the highest tested level that passes before the first tested level that fails. If no tested level fails, the result is a tested lower bound, not the true application maximum.

## Evidence Files

- Max-limit log: `output/gatling/max-limit/max-limit-run.log`
- Max-limit report: `output/gatling/max-limit/index.html`
- Max-limit raw reports: `output/gatling/max-limit/raw/`
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

`Jenkinsfile` runs Gatling only for non-timer builds:

- `Gatling Max Limit` runs only when the build parameter `RUN_GATLING_MAX_LIMIT=true`.
- `Gatling Load Test` runs `./scripts/run-gatling-load-5m`.
- `Gatling Stress Test` runs `./scripts/run-gatling-stress-5m`.

Monitoring is handled by the separate Jenkins Freestyle job `meta-monitoring`, which runs `./scripts/run-monitoring-check`; the Gatling stages are not part of that scheduled job. Jenkins publishes Gatling HTML/PDF evidence through HTML Publisher when `index.html` exists under `output/gatling/max-limit/`, `output/gatling/load-5m/`, or `output/gatling/stress-5m/`.

Jenkins finalization exports Gatling PDFs from completed HTML reports in the `post` block before generating the final pipeline report. PDF export uses a temporary Playwright Docker Pipeline container because it is administrative report generation, not application validation.

Local `./scripts/export-gatling-pdfs` remains strict and requires all three Gatling reports. Jenkins runs the same script with `GATLING_PDF_REQUIRE_ALL=false` so normal builds that skip optional max-limit discovery can still export the load and stress PDFs that were produced in that build.

## Graph Explanations

### Max Limit

The max-limit run completed the configured stepped profile from 5 to 50 users per second without crossing the failure threshold. Gatling recorded 21,450 requests, 21,450 successful responses, 0 failed responses, and a 95th percentile response time of 10 ms. Because no tested level failed, this is a tested lower bound through the highest configured step, not the true application maximum.

### Load 5m

The 5-minute load test held the default steady rate and completed with 3,000 successful requests and 0 failures. The 95th percentile response time was 20 ms and all requests were below 800 ms, so the graph should appear flat and stable with no visible saturation under this light sustained load.

### Stress 5m

The 5-minute stress test ramped from 5 to 50 users per second and completed with 16,500 successful requests and 0 failures. The 95th percentile response time was 14 ms, the 99th percentile was 117 ms, and all requests stayed below 800 ms. The request-rate graph should rise with the ramp while response-time graphs remain low, which indicates the local Tomcat container handled the configured ramp without visible bottlenecking.

## Submission Notes

- Attach the three terminal or Jenkins-console screenshots.
- Attach the three generated Gatling PDFs.
- Include the max-limit conclusion and graph explanations in the final submission package.
- Do not claim a precise max limit unless the run shows a passing level followed by a failing level.
- The three terminal or Jenkins-console screenshots are not captured yet and must be added before final submission.

## Troubleshooting

- If the Gatling container cannot resolve `tomcat`, confirm `docker compose up -d tomcat jenkins` has created Docker network `meta`.
- If Docker cannot pull `denvazh/gatling:3.2.1`, rerun when network access is available and keep the exact error in the changelog.
- If Jenkins cannot launch the Gatling container, confirm Jenkins has Docker socket access, the `docker-workflow` plugin, and a passing `Docker Pipeline Preflight` stage.
- If local PDF export fails, confirm the three `index.html` files exist before running `./scripts/export-gatling-pdfs`.
