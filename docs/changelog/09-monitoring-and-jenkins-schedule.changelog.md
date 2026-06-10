# Plan 09 Changelog - Monitoring And Jenkins Schedule

## 2026-06-10 Separate Jenkins Availability Monitoring Job

### What Changed

- Split Jenkins availability monitoring out of `meta-container-ci-cd`.
- Removed `cron('H/5 * * * *')` and all `TimerTrigger` gating from `Jenkinsfile`.
- Renamed the CI/CD reachability stage from `Availability Check` to `Verify Tomcat`.
- Added `Jenkinsfile.availability` for separate Jenkins job `meta-availability-monitor`.
- Configured `Jenkinsfile.availability` to run `curl -fsS "$APP_BASE_URL" >/dev/null` every 5 minutes against `http://tomcat:8080/meta/`.
- Added archived monitoring evidence at `output/monitoring/latest-check.txt`.
- Updated compliance policy, Jenkins documentation, architecture documentation, submission checklist, Gatling documentation, Plan 05, Plan 08, and the pipeline report generator to reflect the two-job design.
- Added `docs/monitoring.md` as the defense reference for the monitoring job.

### Why It Changed

- The instructor confirmed that availability monitoring should be a separate Jenkins job.
- The previous trigger-aware design kept monitoring inside the CI/CD job and was therefore harder to defend against the instructor's clarification.
- A separate source-controlled Pipeline job keeps the monitoring implementation reproducible without adding Job DSL, JCasC, freestyle jobs, or UI-only shell scripts.

### Validation

- `rtk git status`: confirmed branch `feature/09-monitoring-and-jenkins-schedule` with scoped tracked changes.
- `docker compose config --quiet`: passed.
- `sh -n scripts/generate-pipeline-report`: passed.
- `if rg -n "cron\\('H/5|TimerTrigger" Jenkinsfile; then exit 1; fi`: passed; no matches.
- `rg -n "cron\\('H/5 \\* \\* \\* \\*'\\)" Jenkinsfile.availability`: passed; found the monitoring cron.
- `if rg -n "mvn -B clean package|scripts/deploy-war|run-playwright|run-gatling|RUN_GATLING" Jenkinsfile.availability; then exit 1; fi`: passed; no matches.
- `docker compose ps jenkins`: passed after Docker socket approval; `meta-jenkins` was running on `0.0.0.0:8081->8080/tcp`.
- Jenkins declarative linter for `/workspace/final-project/Jenkinsfile`: passed with `Jenkinsfile successfully validated.`
- Jenkins declarative linter for `/workspace/final-project/Jenkinsfile.availability`: passed with `Jenkinsfile successfully validated.`
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md`: passed with `pass=71`, `warn=0`, `fail=0`, and `manual=9`.
- `git diff --check`: passed.

### Evidence Paths

- `Jenkinsfile`
- `Jenkinsfile.availability`
- `docs/monitoring.md`
- `docs/jenkins.md`
- `docs/plans/09-monitoring-and-jenkins-schedule.md`
- Future Jenkins monitoring artifact path: `output/monitoring/latest-check.txt`

### Remaining Risks

- Final submission still needs a real UptimeRobot or approved monitor passed screenshot.
- Jenkins UI must be configured with separate Pipeline job `meta-availability-monitor`, script path `Jenkinsfile.availability`, and the same branch as the CI/CD job during branch validation.
- The live scheduled monitoring build evidence must be captured after the branch is committed and the Jenkins monitoring job checks out the updated source.
