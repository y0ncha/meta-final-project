# 09 - Monitoring And Jenkins Schedule

## Goal
Provide official availability monitor evidence and prove Jenkins triggers availability checks every 5 minutes without running the full CI/CD deployment path on that timer.

## Deliverables
- UptimeRobot monitor.
- Jenkins scheduled availability job.
- `docs/monitoring.md`.
- Monitor passed screenshot.
- Jenkins scheduled job log evidence showing only the availability check ran.

## Implementation
- Use UptimeRobot as the official monitor.
- Monitor target:
  - Local evidence phase: `http://localhost:8080/meta/` if reachable by the monitor setup.
  - Bonus phase: `http://<public-ip>:8080/meta/`.
- Add or verify a Jenkins job/stage that runs every 5 minutes and checks the same target with `curl`.
- Keep the 5-minute schedule scoped to availability monitoring. Build, deploy, Playwright, and Gatling stages should run on SCM/manual CI/CD builds, not on the monitor timer.
- Document monitor name, target URL, interval, and pass/fail evidence.

## Validation
- UptimeRobot shows the monitor is up.
- Jenkins has a scheduled availability job or timer-gated availability stage with a 5-minute cadence.
- Jenkins logs show successful checks and do not show Maven build, Tomcat deploy, Playwright, or Gatling execution for timer-triggered runs.

## Human Configuration Needed
- Create or log into UptimeRobot account.
- Create the monitor.
- Capture screenshot showing monitor passed.
