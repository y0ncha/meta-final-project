# 12 - Max-Limit Staircase Refactor Changelog

## 2026-06-16 Jenkins MAX_LIMIT PER_SEC Parameters

## Summary

Renamed the Jenkins-facing max-limit rate build parameters with uppercase `_PER_SEC` suffixes and the UI-only `MAX_LIMIT` prefix: `MAX_LIMIT_START_USERS_PER_SEC`, `MAX_LIMIT_STEP_USERS_PER_SEC`, and `MAX_LIMIT_END_USERS_PER_SEC`. The pipeline still normalizes those UI values into the existing runner variables so the shell wrappers and Gatling simulation contract stay compatible.

## Files Changed

- `Jenkinsfile`: Exposes the three max-limit rate fields with uppercase `_PER_SEC` suffixes and maps them into the existing environment variables.
- `tests/scripts/test-jenkinsfile-gatling-params.sh`: Enforces the new Jenkins build parameter names and the internal normalization.
- `docs/gatling.md` and `docs/jenkins.md`: Document the Jenkins-facing parameter names.

## 2026-06-16 SLA Parameter Documentation

## Summary

Documented the recommended Gatling SLA profile after inspecting local Jenkins build `#12` and public Jenkins build `#13`: keep `KO=0` as the hard gate, use p95 `< 2000ms` for refreshed load/stress evidence, run load at `250 users/sec`, run stress from `250` to `475 users/sec`, and confirm max-limit with a focused `450-550 users/sec` range.

## Files Changed

- `docs/gatling.md`, `docs/jenkins.md`, `docs/submission.md`, `docs/public-app-bonus.md`, and `docs/max-limit-final-changes-report.md`: Added SLA/parameter guidance and clarified the evidence basis.
- `submission/email/email-body.md`, `submission/local/j-gatling-max-limit/max-limit-explanation.md`, `submission/local/l-gatling-result-pdfs/README.md`, `submission/local/l-gatling-result-pdfs/graph-explanations.md`, `submission/local/g-browser-test-passed-run/validation-explanation.md`, and `submission/public/public-gatling-max-limit/`: Aligned packaged explanation text with the recommended SLA profile.
- `tests/scripts/test-submission-readiness.sh`: Protects the new submission-facing SLA wording.

## 2026-06-15 Users/Sec Load And Stress Profiles

## Summary

Changed the 5-minute load and stress Gatling profiles from closed concurrent-user injection to open users/sec arrival-rate injection. The existing environment variable names remain for compatibility, but `GATLING_LOAD_USERS`, `GATLING_STRESS_START_USERS`, and `GATLING_STRESS_TARGET_USERS` now control users/sec rates for those runs. Existing load/stress evidence must be refreshed before being submitted as current evidence.

## Files Changed

- `src/gatling/user-files/simulations/MetaSimulation.scala`: Replaced load/stress `rampConcurrentUsers` / `constantConcurrentUsers` injectors with `rampUsersPerSec` / `constantUsersPerSec`.
- `scripts/run-gatling-container`: Relabeled load/stress console summaries as users/sec.
- `tests/scripts/test-gatling-assertions.sh` and `tests/test_gatling_max_limit_summary.sh`: Enforce users/sec load/stress profiles and summary text.
- `docs/gatling.md`, `docs/jenkins.md`, and `docs/submission.md`: Document users/sec load/stress behavior and mark old load/stress evidence stale.

## Validation

- `sh -n scripts/run-gatling-container scripts/run-gatling-max-limit scripts/run-gatling-load-5m scripts/run-gatling-stress-5m scripts/export-gatling-pdfs scripts/generate-pipeline-report`: passed.
- `sh tests/scripts/test-gatling-assertions.sh`: passed.
- `sh tests/test_gatling_max_limit_summary.sh`: passed.
- `sh tests/scripts/test-submission-readiness.sh`: passed.
- `sh tests/scripts/test-run-gatling-console-mode.sh`: passed.
- `sh tests/scripts/test-run-gatling-max-limit.sh`: passed.
- `sh tests/scripts/test-gatling-har-alignment.sh`: passed.
- `git diff --check`: passed.

## 2026-06-15 Clear Users/Sec Parameter Names

## Summary

Renamed Jenkins-facing max-limit users/sec controls from the legacy `BASE` / `LIMIT` names to clearer `START` / `END` names. Shell wrappers still accept the old names as compatibility aliases and normalize them into the internal variables used by the Gatling simulation.

## Files Changed

- `Jenkinsfile`: Replaced max-limit UI parameters with `GATLING_MAX_START_USERS_PER_SEC`, `GATLING_MAX_STEP_USERS_PER_SEC`, and `GATLING_MAX_END_USERS_PER_SEC`.
- `scripts/run-gatling-max-limit` and `scripts/run-gatling-container`: Prefer the clear users/sec names while preserving old-name fallbacks.
- `docs/gatling.md` and `docs/jenkins.md`: Document the clearer names as the preferred interface.
- `tests/scripts/test-jenkinsfile-gatling-params.sh`, `tests/scripts/test-run-gatling-max-limit.sh`, and `tests/test_gatling_max_limit_summary.sh`: Verify the new names and compatibility behavior.

## 2026-06-15 Concise Max-Limit Summary

## Summary

Shortened the final max-limit wrapper summary so Jenkins screenshots show only the app URL, pipe-separated test parameters, and the key boundary result. If Gatling reports a KO but the wrapper cannot parse boundary levels from `simulation.log`, the summary now flags that missing boundary data explicitly instead of printing fallback inspection text.

## Files Changed

- `scripts/run-gatling-max-limit`: Replaced the long final summary with concise `parameters` and `key result` lines.
- `tests/scripts/test-run-gatling-max-limit.sh` and `tests/test_gatling_max_limit_summary.sh`: Updated wrapper-output assertions for the shorter summary and missing-boundary flag.
- `docs/gatling.md` and `docs/jenkins.md`: Updated Jenkins summary documentation.

## Validation

- `sh tests/scripts/test-run-gatling-max-limit.sh`: passed.
- `sh tests/test_gatling_max_limit_summary.sh`: passed.

## 2026-06-15 Users/Sec Max-Limit Refactor

## Summary

Changed only the Gatling max-limit workload from a closed concurrent-user staircase to an open users/sec arrival-rate staircase. The existing `GATLING_MAX_*_USERS` variable names remain for compatibility, but wrapper output, Jenkins parameter descriptions, docs, tests, and submission notes now define those max-limit values as users/sec. Existing concurrent-user max-limit evidence is marked pending refresh instead of being reused as users/sec evidence.

## Files Changed

- `src/gatling/user-files/simulations/MetaSimulation.scala`: Replaced max-limit `constantConcurrentUsers` / `rampConcurrentUsers` injectors with `constantUsersPerSec` / `rampUsersPerSec`; at this point in the history, load and stress profiles still remained concurrent-user based.
- `scripts/run-gatling-max-limit` and `scripts/run-gatling-container`: Relabeled max-limit tested range, step, schedules, and parsed boundary summaries as users/sec while preserving stable output paths and environment variable names.
- `Jenkinsfile`: Updated max-limit parameter descriptions to users/sec terminology without renaming parameters.
- `tests/scripts/test-gatling-assertions.sh`, `tests/scripts/test-run-gatling-max-limit.sh`, `tests/test_gatling_max_limit_summary.sh`, `tests/scripts/test-jenkinsfile-gatling-params.sh`, `tests/scripts/test-gatling-har-alignment.sh`, and `tests/scripts/test-submission-readiness.sh`: Enforce users/sec max-limit behavior and keep HAR/load/stress/submission guardrails aligned.
- `docs/gatling.md`, `docs/jenkins.md`, `docs/submission.md`, `submission/local/j-gatling-max-limit/README.md`, `submission/local/j-gatling-max-limit/max-limit-explanation.md`, and `submission/local/l-gatling-result-pdfs/graph-explanations.md`: Document users/sec methodology and mark max-limit submission evidence pending refresh.

## Validation

- `sh -n scripts/run-gatling-container scripts/run-gatling-max-limit scripts/run-gatling-load-5m scripts/run-gatling-stress-5m scripts/export-gatling-pdfs scripts/generate-pipeline-report`: passed.
- `sh tests/scripts/test-gatling-assertions.sh`: passed.
- `sh tests/scripts/test-run-gatling-max-limit.sh`: passed.
- `sh tests/test_gatling_max_limit_summary.sh`: passed.
- `sh tests/scripts/test-jenkinsfile-gatling-params.sh`: passed.
- `sh tests/scripts/test-gatling-har-alignment.sh`: passed.
- `sh tests/scripts/test-submission-readiness.sh`: passed.
- `sh tests/scripts/test-run-gatling-console-mode.sh`: passed.
- `git diff --check`: passed.

## Not Run

- Gatling max-limit, load, and stress evidence runs were not executed. The refreshed users/sec boundary must come from a later user/Jenkins evidence run.

## Remaining Risks

- Submission item `j`, the max-limit terminal/Jenkins screenshot, the max-limit PDF, and max-limit graph explanation must be refreshed together before final submission.

## 2026-06-15 Final Max-Limit Hardening

## Summary

Kept the single closed-concurrency staircase and hardened it for final evidence runs. The profile now exits failed virtual users early, has a calculated max-duration guard, keeps optional ramp timing, and defaults to a targeted `8250` to `8350` local range around the packaged `8300` pass / `8350` fail boundary instead of a broad `8000` to `12000` sweep.

## Files Changed

- `src/gatling/user-files/simulations/MetaSimulation.scala`: Adds `exitHereIfFailed`, a calculated `.maxDuration(...)` guard, `GATLING_MAX_RAMP_SECONDS`, optional initial ramp from 0 to the first max-limit level, and optional ramps between levels.
- `scripts/run-gatling-max-limit`: Uses targeted local defaults, validates the ramp setting, logs ramp windows, maps KO timestamps across hold and ramp windows, and records p95 as supporting evidence rather than the cutoff.
- `scripts/run-gatling-container` and `Jenkinsfile`: Pass `GATLING_MAX_RAMP_SECONDS` through local and Jenkins Gatling execution, default max-limit runs to `8250-8350` in `50`-user steps, and stream full-mode Gatling logs live to the console while preserving the run log file.
- `docs/gatling.md` and `docs/jenkins.md`: Document the staircase rationale, optional ramps, steady-state duration tradeoff, fail-fast behavior, max-duration guard, targeted defaults, and latency-review role.
- `docs/max-limit-final-changes-report.md`: Records the final accepted and deferred review recommendations.
- `tests/scripts/test-run-gatling-max-limit.sh`, `tests/test_gatling_max_limit_summary.sh`, `tests/scripts/test-gatling-assertions.sh`, and `tests/scripts/test-jenkinsfile-gatling-params.sh`: Cover the new parameter, schedule logging, summary wording, and Jenkins parameter propagation.

## Validation

- `sh tests/scripts/test-run-gatling-max-limit.sh`: passed.
- `sh tests/test_gatling_max_limit_summary.sh`: passed.
- `sh tests/scripts/test-gatling-assertions.sh`: passed.
- `sh tests/scripts/test-jenkinsfile-gatling-params.sh`: passed.
- `sh tests/scripts/test-run-gatling-console-mode.sh`: passed.

## Not Run

- Gatling max-limit, load, and stress evidence runs were not executed. Per project constraint, those runs must be triggered by the user or Jenkins, not by the assistant.

## Remaining Risks

- Any enabled ramp or changed default range changes the active-users graph and timing windows, so packaged max-limit evidence should be refreshed before submission if this new profile is used as replacement evidence.

## 2026-06-14 Single Staircase Max-Limit Implementation

## Summary

Refactored Gatling max-limit evidence from repeated flat single-level wrapper attempts into one bounded staircase simulation. The wrapper now launches Gatling once with base, step, limit, and duration parameters, preserves the normalized report path, and prints an honest KO-based cutoff summary without inventing exact levels when report parsing is not reliable.

## Files Changed

- `src/gatling/user-files/simulations/MetaSimulation.scala`: Adds `steppedLevels` and one sequential closed max-limit staircase profile while preserving load and stress profiles.
- `scripts/run-gatling-max-limit`: Removes the repeated discovery loop, validates staircase bounds, writes exact command parameters and level time windows to `max-limit-discovery.log`, and accepts assertion-failure reports as publishable evidence.
- `scripts/run-gatling-container`: Passes `GATLING_MAX_LIMIT_USERS` through local Docker and Jenkins Docker Pipeline modes and prints staircase parameters for direct max-limit runs.
- `tests/scripts/test-run-gatling-max-limit.sh`: Verifies one staircase runner invocation, limit propagation, and non-zero-with-report wrapper success.
- `tests/test_gatling_max_limit_summary.sh`: Verifies staircase report wording, KO cutoff wording, and compact summary behavior.
- `tests/scripts/test-gatling-assertions.sh`: Verifies the max-limit staircase source contract and protects existing load/stress profiles.
- `docs/gatling.md`, `docs/jenkins.md`, and `scripts/generate-pipeline-report`: Replace flat discovery wording with bounded staircase wording.
- `docs/plans/12-max-limit-staircase-refactor.md`: Removes assistant-run evidence refresh from implementation scope and records evidence refresh as a user/Jenkins handoff.

## Validation

- `sh tests/scripts/test-run-gatling-max-limit.sh`: passed.
- `sh tests/test_gatling_max_limit_summary.sh`: passed.
- `sh tests/scripts/test-gatling-assertions.sh`: passed.

## Not Run

- Gatling max-limit, load, and stress evidence runs were not executed. Per project constraint, those runs must be triggered by the user or Jenkins, not by the assistant.

## Remaining Risks

- The refreshed HTML/PDF evidence still needs a user/Jenkins run to visually confirm the active-users graph shows the intended staircase and is not cropped in PDF export.
- Exact final max-limit values still need to come from refreshed evidence inspection using the `KO=0` cutoff rule and the discovery-log level schedule when per-level counters are unavailable.
