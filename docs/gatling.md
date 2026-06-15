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

The maintained simulation uses two workload models:

- Load: 60 seconds ramping from 0 to `GATLING_LOAD_USERS` users/sec, 180 seconds holding that arrival rate, then 60 seconds ramping back down to 0.
- Stress: five 60-second users/sec staircase levels from `GATLING_STRESS_START_USERS` to `GATLING_STRESS_TARGET_USERS`. Jenkins defaults run from `5` to `50` users/sec, rounded across five levels.
- Max-limit: one bounded open users/sec arrival-rate staircase from `GATLING_MAX_START_USERS` through `GATLING_MAX_END_USERS`, with optional short ramps controlled by `GATLING_MAX_RAMP_SECONDS`.

For max-limit staircase evidence, raise or bound the tested range with environment variables:

```sh
GATLING_MAX_START_USERS=0 \
GATLING_MAX_STEP_USERS=25 \
GATLING_MAX_DURATION_SECONDS=10 \
GATLING_MAX_RAMP_SECONDS=1 \
GATLING_MAX_END_USERS=550 \
./scripts/run-gatling-max-limit
```

## Max-Limit Method

The max-limit wrapper runs one bounded Gatling simulation. Inside that simulation, the max-limit branch applies stepped `constantUsersPerSec(...)` levels, so `GATLING_MAX_START_USERS`, `GATLING_MAX_STEP_USERS`, and `GATLING_MAX_END_USERS` are interpreted as users/sec values even though the stable parameter names still contain `USERS`. If `GATLING_MAX_RAMP_SECONDS` is greater than `0`, transitions use `rampUsersPerSec(current).to(next)`; when it is `0`, levels switch directly. The scenario uses `exitHereIfFailed` after each request so a failed virtual user stops its remaining flow instead of continuing through follow-up requests that no longer add useful boundary evidence. The max-limit setup also applies `.maxDuration(...)` from the configured schedule plus a short grace window, so a bad run stays bounded. Set a small ramp, for example `1` or `2` seconds, when you want a smoother arrival-rate graph and can afford the added runtime.

Each staircase level runs for `GATLING_MAX_DURATION_SECONDS`. If `GATLING_MAX_STEP_USERS` does not land exactly on `GATLING_MAX_END_USERS`, the final level is the configured end value and still runs for the full duration. If ramps are enabled, the wrapper records both ramp windows and hold windows in the discovery log; a KO during a ramp is mapped conservatively to the next level. Gatling assertions are evaluated after the simulation, not at the moment the first request fails, so the run must use a safe configured end value. The wrapper keeps the single staircase report and does not run repeated flat single-level attempts.

The default `10` seconds per level is a practical confirmation setting for a targeted users/sec boundary search. Choose a narrow range around the expected failure region instead of sweeping far past it. For a stronger steady-state capacity claim, keep the same targeted range and increase `GATLING_MAX_DURATION_SECONDS` to `60`-`120`; do not combine long holds with a broad range unless the Jenkins timeout has been raised.

The class PDFs show Gatling evidence in terms of users, successes, failures, and graphs. They do not define a `p95 <= 2000 ms` service-level rule. For this project, max-limit pass/fail therefore follows the course-facing rule: a tested level passes only when Gatling reports `KO=0`. Response-time percentiles remain graph evidence for explaining degradation, especially p95, but latency alone does not define the max-limit failure point.

## SLA And Evidence Parameters

| Area | Current recommendation | Reason |
|---|---|---|
| Hard pass/fail SLA | `KO=0` for max-limit, load, and stress | Any failed request/check/timeout makes the tested max-limit users/sec level unacceptable. |
| Latency SLA for load/stress evidence | `p95 < 2000 ms` | Public build `#13` reached global p95 `1812 ms` near the public failure boundary, so `1000 ms` would be too brittle for public evidence. |
| Load evidence profile | `GATLING_LOAD_USERS=250` users/sec | Keeps the five-minute load evidence on the arrival-rate model. |
| Stress evidence profile | `GATLING_STRESS_START_USERS=250`, `GATLING_STRESS_TARGET_USERS=475` users/sec | Shows arrival-rate degradation over five minutes while the request arrival rate increases. |
| Max-limit confirmation profile | `0-550` users/sec, step `25`, `10s/level`, ramp `1s` | Searches the users/sec failure boundary without relying on request-throughput side effects. |

Older concurrent-user evidence is historical after the max-limit profile change. Refresh max-limit evidence before claiming a current capacity number.

The main controls are:

- `GATLING_MAX_START_USERS`: first users/sec level to test. The default is `0`.
- `GATLING_MAX_STEP_USERS`: users/sec increment after each level.
- `GATLING_MAX_DURATION_SECONDS`: how long each users/sec level is held.
- `GATLING_MAX_RAMP_SECONDS`: optional ramp time from 0 to the first level and between staircase levels. The default is `1`; `0` means instant transitions.
- `GATLING_MAX_END_USERS`: highest users/sec level to test before reporting a lower bound.
- `GATLING_RESTART_TOMCAT_BEFORE_RUN`: optional `true` / `false` switch for restarting local Compose Tomcat immediately before the max-limit run.

When `GATLING_RESTART_TOMCAT_BEFORE_RUN=true`, the max-limit wrapper restarts only local Docker targets such as `tomcat`, `localhost`, or `127.0.0.1` by running `docker compose restart tomcat` from the repository root. Public EC2 Tomcat restart is intentionally not automated from Gatling; restart the public instance manually through the AWS console or an operator SSH session before running public-target evidence. This keeps the performance runner from depending on broad SSH access.

Examples:

```sh
GATLING_RESTART_TOMCAT_BEFORE_RUN=true \
./scripts/run-gatling-max-limit
```

With Jenkins defaults, max-limit evidence tests a staircase from `0` through `550` users/sec in `25` users/sec steps, holding each level for `10` seconds with `1` second ramps. Choose tighter local or public ranges when you already know the failure region; do not run a broad public staircase far past the expected failure point.

The old names `GATLING_MAX_START_USERS_PER_SEC`, `GATLING_MAX_STEP_USERS_PER_SEC`, `GATLING_MAX_END_USERS_PER_SEC`, `GATLING_MAX_BASE_USERS`, and `GATLING_MAX_LIMIT_USERS` are still accepted as compatibility aliases for older local commands.

A tested level is treated as passing only when Gatling reports zero failed requests/checks/timeouts.

The max limit is the highest tested users/sec level that passes before the first tested users/sec level that fails. If a run fails after a report is normalized, the wrapper treats that assertion failure as usable staircase evidence, preserves the report under `output/gatling/max-limit/`, and exits successfully so Jenkins can publish the evidence. The summary prints exact cutoff values only when they can be derived safely from the report; otherwise, inspect the report's time-based failure/error graphs and map the first KO timestamp to the `level schedule` lines in `output/gatling/max-limit/raw/max-limit-discovery.log`. If no tested level fails, the result is a tested lower bound, not the true application maximum.

Do not use Gatling's final `mean requests/sec` value as the max-limit level. That value is observed request throughput. Likewise, the active-users graph is an observed result of the open workload and response times. The configured max-limit levels are the users/sec staircase entries recorded in `max-limit-discovery.log`.

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
- `GATLING_CONSOLE_MODE=summary` is the default. It keeps the console compact while preserving the complete Gatling run log under `output/gatling/<run-type>/`. For all Gatling runs, the console prints Gatling's native `Global Information` summary block first, then a short wrapper summary with the app URL and parameters. Load and stress also print the wrapper completion status. Max-limit writes its detailed command parameters and users/sec level schedule to `output/gatling/max-limit/raw/max-limit-discovery.log`; evaluate the max-limit evidence from the users/sec staircase plus the `KO=0` outcome.
- `GATLING_CONSOLE_MODE=full` streams the complete Gatling run log to the console while also preserving the same log under `output/gatling/<run-type>/`. Set it explicitly only when you need live low-level Gatling progress.

Summary mode preserves Gatling's own report wording and keeps the wrapper summary short, so Jenkins screenshots show both the standard Gatling terminal summary and the repo-specific evidence context.

After this Jenkinsfile change is merged, run or reload the Pipeline once so Jenkins refreshes the Build with Parameters form.

For Jenkins max-limit staircase evidence, the build parameters expose the main bounds:

- `GATLING_MAX_START_USERS=0`
- `GATLING_MAX_STEP_USERS=25`
- `GATLING_MAX_DURATION_SECONDS=10`
- `GATLING_MAX_RAMP_SECONDS=1`
- `GATLING_MAX_END_USERS=550`

With those defaults, Jenkins runs one staircase from 0 through 550 users/sec in 25 users/sec steps with 1 second ramps. When any request/check/timeout fails, the console shows Gatling's native summary followed by the short wrapper staircase summary. The exact command parameters, level-to-time schedule, and ramp schedule when enabled are also recorded in `output/gatling/max-limit/raw/max-limit-discovery.log`.

Monitoring is handled by the separate Jenkins Freestyle job `meta-monitoring`, which runs `./scripts/run-monitoring-check`; the Gatling stages are not part of that scheduled job. Jenkins publishes Gatling HTML/PDF evidence through HTML Publisher when `index.html` exists under `output/gatling/max-limit/`, `output/gatling/load-5m/`, or `output/gatling/stress-5m/`.

Jenkins finalization exports Gatling PDFs from completed HTML reports in the `post` block before generating the final pipeline report. PDF export uses a temporary Playwright Docker Pipeline container because it is administrative report generation, not application validation.

Local `./scripts/export-gatling-pdfs` remains strict and requires all three Gatling reports. Jenkins runs the same script with `GATLING_PDF_REQUIRE_ALL=false` so normal builds that skip Gatling can still finish cleanly, while explicit Gatling evidence builds export the Gatling PDFs that were produced in that build.

## Graph Explanations

### Max Limit

After the users/sec profile change, rerun the max-limit evidence before packaging final screenshots/PDFs. Explain the users/sec injection graph as the configured arrival-rate staircase, the active-users graph as Gatling's resulting active users over time, the request-rate graph and final `mean requests/sec` line as observed throughput, and the response-time/KO graphs as system behavior at each users/sec level.

### Load 5m

The 5-minute load test ramps from 0 to `GATLING_LOAD_USERS` users/sec for 60 seconds, holds that arrival rate for 180 seconds, and ramps down to 0 for 60 seconds. For refreshed SLA evidence, use `GATLING_LOAD_USERS=250`, require `KO=0`, and treat `p95 < 2000 ms` as the latency SLA. Explain the active-users graph as Gatling's resulting active users over time, the request-rate graph as resulting throughput, and the response-time/KO graphs as system behavior under that arrival rate.

### Stress 5m

The 5-minute stress test uses five 60-second users/sec staircase levels from `GATLING_STRESS_START_USERS` to `GATLING_STRESS_TARGET_USERS`. For refreshed SLA evidence, use `GATLING_STRESS_START_USERS=250` and `GATLING_STRESS_TARGET_USERS=475`, require `KO=0`, and treat `p95 < 2000 ms` as the latency SLA. Explain the active-users graph as Gatling's resulting active users over time, the request-rate graph as resulting throughput, and the response-time/KO graphs as the system response while the arrival rate increases.

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
