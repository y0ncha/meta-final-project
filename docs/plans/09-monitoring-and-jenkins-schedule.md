# 09 - Monitoring And Jenkins Schedule

## Goal
Provide official availability monitor evidence and prove Jenkins triggers availability checks every 5 minutes.

## Deliverables
- UptimeRobot monitor.
- Jenkins scheduled availability job.
- `docs/monitoring.md`.
- Monitor passed screenshot.
- Jenkins scheduled job log evidence.

## Implementation
- Use UptimeRobot as the official monitor.
- Monitor target:
  - Local evidence phase: `http://localhost:8080/meta/` if reachable by the monitor setup.
  - Bonus phase: `http://<public-ip>:8080/meta/`.
- Add Jenkins job/stage that runs every 5 minutes and checks the same target with `curl`.
- Document monitor name, target URL, interval, and pass/fail evidence.

## Validation
- UptimeRobot shows the monitor is up.
- Jenkins has a scheduled job with a 5-minute cadence.
- Jenkins logs show successful checks.

## Human Configuration Needed
- Create or log into UptimeRobot account.
- Create the monitor.
- Capture screenshot showing monitor passed.
