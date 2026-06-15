# Max-Limit Final Changes Report

## Scope

This update keeps the max-limit methodology as one bounded users/sec arrival-rate staircase. It does not replace the model with separate single-level runs or an unbounded stress run.

## Final Changes

- Kept one users/sec staircase from `GATLING_MAX_BASE_USERS` through `GATLING_MAX_LIMIT_USERS`.
- Added `exitHereIfFailed` after each request in the maintained Gatling flow so a failed virtual user stops its remaining dependent requests.
- Added `.maxDuration(...)` to the max-limit setup. The value is calculated from the configured staircase schedule plus a 30-second grace window.
- Changed local and Jenkins max-limit defaults to a targeted `250-550` users/sec range in `25` users/sec steps.
- Kept `GATLING_MAX_DURATION_SECONDS=10` as the default. Longer `60-120` second holds should be used only after narrowing the range and accepting the longer runtime.
- Kept optional ramp support through `GATLING_MAX_RAMP_SECONDS`, defaulting to `1` so the active-users graph has short transitions between levels.
- Kept p95 and response-time graphs as supporting evidence. The cutoff rule remains `KO=0`.
- After Jenkins build `#12` local and build `#13` public, recommended SLA evidence values are load `250 users/sec`, stress `250-475 users/sec`, and max-limit confirmation `450-550 users/sec` in `25` users/sec steps.
- Recommended load/stress SLA gates are `KO=0` and global p95 `< 2000ms`; the p95 threshold comes from public build `#13` reaching p95 `1812ms` near its `550 users/sec` failure boundary.

## Deferred

- Per-level grouping was not added. It can make report inspection clearer, but it is not required for the current boundary proof because the wrapper already records level-to-time windows and derives the first failing level from `simulation.log`.

## How To Evaluate

For a final local confirmation run, use the Jenkins defaults or the equivalent local command:

```sh
GATLING_MAX_BASE_USERS=250 \
GATLING_MAX_STEP_USERS=25 \
GATLING_MAX_DURATION_SECONDS=10 \
GATLING_MAX_RAMP_SECONDS=1 \
GATLING_MAX_LIMIT_USERS=550 \
./scripts/run-gatling-max-limit
```

The result is submission-ready only if the report and wrapper summary show a zero-KO passing level followed by a failing level. If the run uses these new defaults, refresh the max-limit screenshot, PDF, discovery log, and submission text together.

For refreshed load/stress evidence, use:

```sh
GATLING_LOAD_USERS=250 ./scripts/run-gatling-load-5m
GATLING_STRESS_START_USERS=250 GATLING_STRESS_TARGET_USERS=475 ./scripts/run-gatling-stress-5m
```

Treat `KO=0` as mandatory and p95 `< 2000ms` as the recommended latency SLA for those refreshed runs.

## Validation

- `sh tests/scripts/test-run-gatling-max-limit.sh`
- `sh tests/test_gatling_max_limit_summary.sh`
- `sh tests/scripts/test-gatling-assertions.sh`
- `sh tests/scripts/test-jenkinsfile-gatling-params.sh`
