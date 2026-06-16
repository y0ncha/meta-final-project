# Max-Limit Final Changes Report

Current status: superseded for final submission wording. The current submission methodology states the max-limit result as an active-users count from a `Number of responses per second` graph tooltip with `KO=0`, not as a users/sec generator boundary. Keep this file only as historical context for the earlier users/sec refactor.

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
- Historical note: Jenkins build `#12` local and build `#13` public were used for the earlier users/sec-boundary recommendation. Do not reuse those values as the current final max-limit answer.
- Current submission note: require a `Number of responses per second` graph tooltip with `KO=0`; report max-limit as the active-users count at that selected point; report p95 as observed graph evidence, not as the max-limit cutoff.

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

The result is submission-ready only if the original report or graph screenshot identifies the selected active-users count with `KO=0`. If the run uses these historical defaults, refresh the max-limit screenshot, PDF, discovery log, and submission text together.

For refreshed load/stress evidence, use:

```sh
GATLING_LOAD_USERS=250 ./scripts/run-gatling-load-5m
GATLING_STRESS_START_USERS=250 GATLING_STRESS_TARGET_USERS=475 ./scripts/run-gatling-stress-5m
```

Treat `KO=0` as mandatory and p95 as observed graph evidence for those refreshed runs.

## Validation

- `sh tests/scripts/test-run-gatling-max-limit.sh`
- `sh tests/test_gatling_max_limit_summary.sh`
- `sh tests/scripts/test-gatling-assertions.sh`
- `sh tests/scripts/test-jenkinsfile-gatling-params.sh`
