# 11 - Submission Package

## Goal
Assemble the final email package with all required assignment items and real evidence, with a clean separation between local base evidence and optional public-hosted bonus evidence.

Canonical local application URL for final evidence: `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.

Public-hosted bonus URL source: `docs/public-app-bonus.md`.

Plan 11 owns the final evidence checklist, evidence readiness status, attachment list, and submission closeout. Other plans may generate artifacts or prepare infrastructure, but they must hand evidence readiness back to this plan.

## Deliverables
- `docs/submission.md`.
- Local base evidence grouped by the 12 required assignment items.
- Optional public-hosted bonus evidence grouped separately from the local base package.
- Written explanations for Playwright validations, HAR scenario, max limit, and Gatling graphs.
- Jenkins monitoring evidence for Freestyle job `meta-monitoring`, including the scheduled build log and archived `output/monitoring/latest-check.txt`.
- Final submission-ready attachment list with no placeholder-only rows.

## Implementation
### Local Base Evidence

Create a checklist mapping each required assignment item to a real local artifact, link, or screenshot:

  1. JSP file.
  2. GitHub screenshot showing the JSP/app.
  3. Tomcat screenshot with `localhost:8080/...` visible.
  4. Public GitHub repository link.
  5. Monitor tool name, monitored target, passed screenshot, Jenkins `meta-monitoring` scheduled build log, and archived `output/monitoring/latest-check.txt`.
  6. Playwright test file.
  7. Playwright passed-run evidence, screenshot, and validation explanation.
  8. Written HAR scenario.
  9. HAR file.
  10. Max-limit result and explanation.
  11. Three Gatling CMD screenshots.
  12. Three Gatling result PDFs with graph explanations.

The local base package remains required even when public-hosted bonus evidence exists. Do not replace the local Tomcat `localhost:8080/...` screenshot with a public URL screenshot.

### Public-Hosted Bonus Evidence

Track optional public-hosted bonus evidence in a separate section of `docs/submission.md`. Use `docs/public-app-bonus.md` only as the source for the selected public target, EC2 details, cost controls, and raw public run notes.

Public-hosted bonus evidence is claimable only when every row below points to real artifacts from the same public target:

- Public Tomcat browser screenshot with the public URL visible.
- Official UptimeRobot or documented SiteMonitorLite screenshot showing the public target, 5-minute cadence, and up/pass state.
- Jenkins or local runner evidence showing browser automation against `APP_BASE_URL=<PUBLIC_APP_BASE_URL>`.
- User-run Gatling max-limit evidence against `APP_BASE_URL=<PUBLIC_APP_BASE_URL>`.
- User-run Gatling 5-minute load evidence against `APP_BASE_URL=<PUBLIC_APP_BASE_URL>`.
- User-run Gatling 5-minute stress evidence against `APP_BASE_URL=<PUBLIC_APP_BASE_URL>`.
- AWS cleanup verification showing the EC2 evidence window was closed and no unnecessary paid public resource remains.

### Submission Rules

- Do not include fake or placeholder evidence in the final package.
- Keep public-hosted bonus evidence separate from local base evidence.
- Keep pending evidence rows explicit; do not mark a row ready from a plan checkbox alone.
- Do not run Gatling directly as the agent. Public-hosted Gatling evidence must come from user-run Jenkins or runner artifacts.

## Validation
- Every checklist line points to a real artifact or real URL.
- The monitoring checklist item is not complete unless it includes both the official UptimeRobot or documented SiteMonitorLite passed screenshot and Jenkins-side evidence from Freestyle job `meta-monitoring`.
- Jenkins-side monitoring evidence includes a scheduled `meta-monitoring` build log and archived `output/monitoring/latest-check.txt`.
- Public-hosted bonus evidence is not claimable unless all public-hosted rows use the same `PUBLIC_APP_BASE_URL`.
- Public-hosted bonus evidence does not replace any required local base evidence row.
- Email subject is `Final Exercise from: <yournames>`.
- No required item remains placeholder-only.

## Human Configuration Needed
- Final names for `<yournames>`.
- Final public GitHub repository link.
- Final email send to `mosh.mta2@gmail.com`.
