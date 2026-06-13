# 12 - Max-Limit Staircase Refactor Changelog

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
