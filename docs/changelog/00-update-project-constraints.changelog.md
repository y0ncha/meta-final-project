# 00-update-project-constraints

## Completed Plan

- Plan: `.agents/plans/00-update-project-constraints.md`
- Completed: 2026-06-09

## What Changed

- Moved the detailed project compliance rules into `contribution.md` so implementation work has one active source for assignment constraints, tool policy, runtime topology, evidence standards, and submission requirements.
- Reduced `AGENTS.md` to project operating guidance plus a direct instruction to read `contribution.md` before implementation work.
- Created the atomic implementation plan set under `.agents/plans/`, covering the Git baseline, Docker Compose foundation, JSP/Maven app, Tomcat deployment, Jenkins CI/CD, Playwright, HAR, Gatling, monitoring, optional public VM work, and submission package.
- Recorded the container-first runtime policy: Tomcat 8.5.x on `localhost:8080`, Jenkins on `localhost:8081`, Gatling in Docker, Playwright runner in Docker, and UptimeRobot for monitor evidence.

## Why

Plan 00 makes the repository instructions match the instructor-approved container architecture before later implementation work starts. It also prevents duplicated or drifting compliance rules by making `contribution.md` the active source of truth.

## Validation

- `rtk read contribution.md`: confirmed the active project constraints and compliance source exists and includes branch policy, tool version policy, container topology, Playwright, Gatling, monitoring, submission, and evidence standards.
- `rtk read .agents/rules/contribution.md`: confirmed completed plans require a matching `docs/changelog/` entry with exact validation evidence and remaining risks.
- `rtk read .agents/plans/00-update-project-constraints.md`: confirmed the plan deliverables and validation expectations.
- `rg -n "Container Approval|Tomcat.*8080|Jenkins.*8081|UptimeRobot|Playwright|Gatling|completed|changelog|plans" contribution.md AGENTS.md .agents/rules/contribution.md`: confirmed `contribution.md` contains the required container, port, monitoring, Playwright, and Gatling policy text.
- `rg --files .agents/plans`: confirmed the atomic plan directory exists and includes plans `00` through `11`.
- `git diff --cached --name-status`: confirmed the tracked closeout includes `AGENTS.md`, `contribution.md`, `docs/changelog/01-git-and-repo-baseline.changelog.md`, and `docs/repository-baseline.md` before this 00 changelog was added.

## Remaining Risks And Follow-Up

- `.agents/plans/` remains ignored local agent metadata by design, so the plan status marker is updated locally but not force-added to Git.
- No GitHub remote is configured yet; later repository publication work still needs the real public repository URL.
