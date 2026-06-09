# 00 - Update Project Constraints

## Status
Completed on 2026-06-09.

## Goal
Make the repository instructions match the instructor-approved container architecture before any implementation work starts.

## Deliverables
- Updated `AGENTS.md`.
- Updated `contribution.md`.
- `.agents/plans/` directory with the atomic implementation plans.
- Clear default runtime policy:
  - Tomcat 8.5.x container on `localhost:8080`.
  - Jenkins container on `localhost:8081`.
  - Gatling container.
  - Playwright runner container.
  - UptimeRobot SaaS for monitor evidence.

## Implementation
- Record that containers are approved for Tomcat, Jenkins, Gatling, and Playwright runner.
- Keep host Tomcat `/usr/local/tomcat8` as a fallback/reference only.
- Record current tool snapshots and missing-on-PATH tools.
- State that Git/GitHub remain real host/public source control.

## Validation
- `contribution.md` contains a container approval section.
- `contribution.md` states Tomcat owns `8080` and Jenkins uses `8081`.
- `contribution.md` says UptimeRobot is preferred for monitor evidence.

## Human Configuration Needed
- None.
