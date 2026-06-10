# 11 - Submission Package

## Goal
Assemble the final email package with all 12 required assignment items and real evidence.

## Deliverables
- `docs/submission.md`.
- Final screenshots and files grouped by requirement.
- Written explanations for Playwright validations, HAR scenario, max limit, and Gatling graphs.
- Jenkins monitoring evidence for Freestyle job `meta-monitoring`, including the scheduled build log and archived `output/monitoring/latest-check.txt`.

## Implementation
- Create a checklist mapping each required item to a real file/link/screenshot:
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
- Do not include fake or placeholder evidence in the final package.
- Keep public-IP bonus evidence separate from base local evidence.

## Validation
- Every checklist line points to a real artifact or real URL.
- The monitoring checklist item is not complete unless it includes both the official UptimeRobot or documented SiteMonitorLite passed screenshot and Jenkins-side evidence from Freestyle job `meta-monitoring`.
- Jenkins-side monitoring evidence includes a scheduled `meta-monitoring` build log and archived `output/monitoring/latest-check.txt`.
- Email subject is `Final Exercise from: <yournames>`.
- No required item remains placeholder-only.

## Human Configuration Needed
- Final names for `<yournames>`.
- Final public GitHub repository link.
- Final email send to `mosh.mta2@gmail.com`.
