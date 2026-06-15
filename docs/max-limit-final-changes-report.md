# Max-Limit Final Changes Report

## Scope

This update keeps the max-limit methodology as one bounded closed-concurrency staircase. It does not replace the model with separate single-level runs or an unbounded stress run.

## Final Changes

- Kept one closed-concurrency staircase from `GATLING_MAX_BASE_USERS` through `GATLING_MAX_LIMIT_USERS`.
- Added `exitHereIfFailed` after each request in the maintained Gatling flow so a failed virtual user stops its remaining dependent requests.
- Added `.maxDuration(...)` to the max-limit setup. The value is calculated from the configured staircase schedule plus a 30-second grace window.
- Changed local and Jenkins max-limit defaults from the broad `8000-12000` sweep to a targeted `8250-8350` range in `50`-user steps.
- Kept `GATLING_MAX_DURATION_SECONDS=10` as the default. Longer `60-120` second holds should be used only after narrowing the range and accepting the longer runtime.
- Kept optional ramp support through `GATLING_MAX_RAMP_SECONDS`, defaulting to `0` so existing evidence remains comparable unless the user opts in.
- Kept p95 and response-time graphs as supporting evidence. The cutoff rule remains `KO=0`.

## Deferred

- Per-level grouping was not added. It can make report inspection clearer, but it is not required for the current boundary proof because the wrapper already records level-to-time windows and derives the first failing level from `simulation.log`.

## How To Evaluate

For a final local confirmation run, use the Jenkins defaults or the equivalent local command:

```sh
GATLING_MAX_BASE_USERS=8250 \
GATLING_MAX_STEP_USERS=50 \
GATLING_MAX_DURATION_SECONDS=10 \
GATLING_MAX_RAMP_SECONDS=0 \
GATLING_MAX_LIMIT_USERS=8350 \
./scripts/run-gatling-max-limit
```

The result is submission-ready only if the report and wrapper summary show a zero-KO passing level followed by a failing level. If the run uses these new defaults, refresh the max-limit screenshot, PDF, discovery log, and submission text together.

## Validation

- `sh tests/scripts/test-run-gatling-max-limit.sh`
- `sh tests/test_gatling_max_limit_summary.sh`
- `sh tests/scripts/test-gatling-assertions.sh`
- `sh tests/scripts/test-jenkinsfile-gatling-params.sh`
