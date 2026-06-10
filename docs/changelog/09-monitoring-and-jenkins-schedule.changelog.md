# Plan 09 Changelog - Monitoring And Jenkins Schedule

## 2026-06-10 Separate Jenkins Monitoring Job

### What Changed

- Split Jenkins monitoring out of `meta-container-ci-cd`.
- Removed `cron('H/5 * * * *')` and all `TimerTrigger` gating from `Jenkinsfile`.
- Renamed the CI/CD reachability stage from `Availability Check` to `Verify Tomcat`.
- Added separate Jenkins monitoring job documentation and monitoring evidence path `output/monitoring/latest-check.txt`.
- Updated compliance policy, Jenkins documentation, architecture documentation, submission checklist, Gatling documentation, Plan 05, Plan 08, and the pipeline report generator to reflect the two-job design.

### Why It Changed

- The instructor confirmed that monitoring should be a separate Jenkins job.
- The previous trigger-aware design kept monitoring inside the CI/CD job and was harder to defend after the instructor clarification.

## 2026-06-11 Freestyle Monitoring Correction

### What Changed

- Removed the old monitoring Pipeline file because Jenkins Freestyle jobs do not execute Jenkinsfiles.
- Added `scripts/run-monitoring-check` as the source-controlled shell command for Freestyle job `meta-monitoring`.
- Updated `rules/compliance.md` to require separate Jenkins Freestyle monitoring job `meta-monitoring`.
- Updated `docs/monitoring.md`, `docs/jenkins.md`, `docs/architecture.md`, `docs/submission.md`, and `docs/gatling.md` to document Freestyle setup.
- Rewrote `docs/plans/09-monitoring-and-jenkins-schedule.md` so the current plan says Freestyle + UptimeRobot/SiteMonitorLite, not Pipeline.
- Updated Plan 05 references to point to Freestyle monitoring through `scripts/run-monitoring-check`.

### Why It Changed

- Freestyle is the better fit for the simple instructor-facing requirement: one separate Jenkins job that checks monitoring every 5 minutes.
- Keeping the shell command in `scripts/run-monitoring-check` preserves source-controlled reviewability while avoiding the false implication that a Freestyle job reads a Jenkinsfile.
- UptimeRobot remains the preferred official monitor screenshot source, while SiteMonitorLite stays allowed as a documented fallback.

### Validation

- `rtk git status`: confirmed branch `feature/09-monitoring-and-jenkins-schedule` with scoped Plan 09 changes.
- Removed-file check for the old monitoring Pipeline file: passed.
- `test -x scripts/run-monitoring-check`: passed.
- `sh -n scripts/run-monitoring-check`: passed.
- Stale-reference scan for the removed monitoring Pipeline file, the old monitor job name, and the old Pipeline-monitoring setup: passed with no current required setup references.
- `rg -n "meta-monitoring|scripts/run-monitoring-check|Freestyle|UptimeRobot|SiteMonitorLite" docs rules scripts`: passed and showed the new monitoring setup.
- `docker compose config --quiet`: passed.
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md`: passed with zero failures; 9 manual review items remain for negative or defense-readiness rules.
- Optional local runtime check `APP_BASE_URL=http://localhost:8080/meta/ ./scripts/run-monitoring-check`: blocked because no service was listening on localhost port 8080 during validation.

### Evidence Paths

- `scripts/run-monitoring-check`
- `docs/monitoring.md`
- `docs/jenkins.md`
- `docs/plans/09-monitoring-and-jenkins-schedule.md`
- Future Jenkins monitoring artifact path: `output/monitoring/latest-check.txt`

### Remaining Risks

- Final submission still needs a real UptimeRobot or documented SiteMonitorLite passed screenshot.
- Jenkins UI must be configured with Freestyle job `meta-monitoring`, trigger `H/5 * * * *`, Execute shell command `./scripts/run-monitoring-check`, and archive pattern `output/monitoring/**/*`.
- The live scheduled monitoring build evidence must be captured from Jenkins after the Freestyle job is configured.
- Local script runtime evidence still needs to be captured after Tomcat is running at `http://localhost:8080/meta/`.

## 2026-06-11 Monitoring Timeout Follow-Up

### What Changed

- Added bounded curl behavior to `scripts/run-monitoring-check` with `--connect-timeout 5` and `--max-time 15`.
- Added `tests/scripts/test-run-monitoring-check.sh` to intercept curl, assert the timeout flags, and verify `output/monitoring/latest-check.txt` is still written.
- Updated `docs/monitoring.md` and `docs/plans/09-monitoring-and-jenkins-schedule.md` so the documented Freestyle command behavior matches the script.

### Why It Changed

- A Jenkins Freestyle Execute shell step does not inherit the old Pipeline-level timeout from the deleted monitoring Jenkinsfile.
- Without an explicit curl bound, a stalled HTTP connection could occupy the scheduled monitoring executor and delay fresh 5-minute evidence.

### Validation

- `sh tests/scripts/test-run-monitoring-check.sh`: passed.
- `sh -n scripts/run-monitoring-check`: passed.

### Remaining Risks

- Jenkins UI must still run the updated source-controlled `./scripts/run-monitoring-check` from a fresh SCM checkout for live scheduled evidence.
