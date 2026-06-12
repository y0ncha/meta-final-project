---
goal: Fresh Final Submission Package Structure With Local And Public Evidence Separation
version: 2.0
date_created: 2026-06-10
last_updated: 2026-06-12
owner: Yonatan Csasznik
status: 'In progress'
tags:
  - documentation
  - submission
  - evidence
  - compliance
---

# Introduction

![Status: In progress](https://img.shields.io/badge/status-In_progress-yellow)

This plan defines a fresh `submission/` package structure for the MTA 2026 Semester B DevOps final project. The package must map exactly to the 12 required email items from `final-project.pdf` and `docs/final-project.txt`, preserve the existing evidence history, and separate required local evidence from optional public-IP bonus evidence.

The canonical local application URL is `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.

The current optional public application URL from `docs/public-app-bonus.md` is `http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.

## 1. Requirements & Constraints

- **REQ-001**: Rebuild the tracked `submission/` folder into a deterministic package layout rooted at `submission/local/`, `submission/public/`, `submission/email/`, and `submission/archive/`.
- **REQ-002**: The `submission/local/` folder must contain one numbered directory for each final email item `a` through `l` from `docs/final-project.txt`.
- **REQ-003**: The `submission/public/` folder must contain only optional public-IP bonus evidence and must never replace any required `submission/local/` evidence item.
- **REQ-004**: Every local evidence directory must contain a `README.md` file that states the assignment item, required evidence, source artifact, freshness command or capture method, and readiness status.
- **REQ-005**: The final package must include an email body draft at `submission/email/email-body.md` with the assignment recipient and subject `Final Exercise from: Yonatan Csasznik, Yoed Halberstam, Niv Levin`.
- **REQ-006**: The final package must include an attachment manifest at `submission/email/attachments-manifest.md` with one row per required local attachment and a separate section for optional public evidence attachments.
- **REQ-007**: Existing files currently under `submission/` must not be deleted. They must be moved to `submission/archive/pre-2026-06-12-structure/` or copied into the new local/public layout only after their source and freshness are confirmed.
- **REQ-008**: Evidence readiness must be derived from real files, screenshots, links, and logs, not from plan checkboxes or prose claims.
- **REQ-009**: The package must keep the Playwright-over-Selenium substitution explicit because `docs/final-project.txt` requests Selenium IDE `.side` evidence.
- **REQ-010**: The package must include written explanations for browser validations, HAR scenario, max-limit result, and Gatling graph interpretation.
- **REQ-011**: Public-IP bonus evidence is claimable only when all public evidence rows use the same `PUBLIC_APP_BASE_URL` value from `docs/public-app-bonus.md`.
- **REQ-012**: The final package must not include `.DS_Store`, stale placeholder files, fake screenshots, guessed Gatling numbers, or unreviewed HAR files.
- **CON-001**: `final-project.pdf` is the authoritative assignment contract; `docs/final-project.txt` is the searchable cache used for implementation.
- **CON-002**: `rules/compliance.md` is the active operational checklist for container, evidence, monitoring, browser automation, Gatling, HAR, submission, and defense constraints.
- **CON-003**: The local Tomcat screenshot for item `c` must visibly show `localhost:8080/...`; a public URL screenshot is bonus evidence only.
- **CON-004**: Gatling validation must not be run directly by the agent. If fresh Gatling evidence is required, the user must run the approved Jenkins or runner command and provide artifacts.
- **CON-005**: Monitoring is implemented as a separate Jenkins Freestyle job named `meta-monitoring`; it must stay separate from the CI/CD Pipeline job.
- **CON-006**: Jenkins local evidence must use `http://localhost:8081/` and must not claim public Jenkins exposure.
- **CON-007**: Public EC2 evidence must be collected during a short evidence window and followed by cleanup verification before bonus closeout.
- **PAT-001**: Use numbered assignment-aligned directories so graders and future agents can map email item letters directly to files.
- **PAT-002**: Keep generated runtime evidence under `output/`; copy only final reviewed evidence into `submission/`.
- **PAT-003**: Keep final human-facing submission instructions in `docs/submission.md`; keep packaged sendable files and manifests in `submission/`.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Replace the partial `submission/` layout with a fresh assignment-aligned directory contract while preserving existing evidence.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Create `submission/archive/pre-2026-06-12-structure/` and move the current directories `submission/github-repo/`, `submission/har-recording/`, `submission/playwright-tests/`, and `submission/tomcat-webapp/` into it without deleting evidence. | ✅ | 2026-06-12 |
| TASK-002 | Remove tracked macOS metadata files from the package by deleting `submission/.DS_Store` and `submission/playwright-tests/.DS_Store` only if they are tracked or present in the working tree. | ✅ | 2026-06-12 |
| TASK-003 | Create `submission/local/` with the exact directories `a-jsp-file/`, `b-github-screenshot/`, `c-tomcat-local-screenshot/`, `d-github-public-link/`, `e-monitoring-evidence/`, `f-browser-test-file/`, `g-browser-test-passed-run/`, `h-har-scenario/`, `i-har-file/`, `j-gatling-max-limit/`, `k-gatling-cmd-screenshots/`, and `l-gatling-result-pdfs/`. | ✅ | 2026-06-12 |
| TASK-004 | Create `submission/public/` with the exact directories `public-tomcat-screenshot/`, `public-monitoring-evidence/`, `public-jenkins-monitoring-check/`, `public-browser-test-passed-run/`, `public-gatling-max-limit/`, `public-gatling-load-5m/`, `public-gatling-stress-5m/`, and `aws-cleanup-verification/`. | ✅ | 2026-06-12 |
| TASK-005 | Create `submission/email/` with `email-body.md` and `attachments-manifest.md`; create `submission/README.md` that explains the local/public/archive split in no more than 80 lines. | ✅ | 2026-06-12 |

### Implementation Phase 2

- GOAL-002: Populate the required local package from fresh or reviewed evidence and keep every item mapped to the assignment text.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-006 | Copy `src/main/webapp/index.jsp` to `submission/local/a-jsp-file/index.jsp` and add `submission/local/a-jsp-file/README.md` naming assignment item `a`, source path `src/main/webapp/index.jsp`, and status `ready` only after the copy matches the source. | ✅ | 2026-06-12 |
| TASK-007 | Place the final GitHub screenshot at `submission/local/b-github-screenshot/github-jsp.png` and add `submission/local/b-github-screenshot/README.md` with the screenshot capture date, public repository URL `https://github.com/y0ncha/meta-final-project`, and status. | ✅ | 2026-06-12 |
| TASK-008 | Place the final browser-chrome Tomcat screenshot at `submission/local/c-tomcat-local-screenshot/tomcat-local-url.png` and add `submission/local/c-tomcat-local-screenshot/README.md` requiring the visible URL `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`. | ✅ | 2026-06-12 |
| TASK-009 | Create `submission/local/d-github-public-link/github-public-repo.link` containing exactly `https://github.com/y0ncha/meta-final-project` and add `submission/local/d-github-public-link/README.md` with the public accessibility check command or manual check result. | ✅ | 2026-06-12 |
| TASK-010 | Populate `submission/local/e-monitoring-evidence/` with the official monitor screenshot, `output/monitoring/latest-check.txt`, and the final `meta-monitoring` scheduled Jenkins build log; add a README documenting tool name, monitored target, 5-minute cadence, and pass state. | | |
| TASK-011 | Copy `tests/playwright/meta-functional.spec.js` to `submission/local/f-browser-test-file/meta-functional.spec.js` and add a README that explicitly states this is the Playwright substitute for the PDF's Selenium IDE `.side` item. | ✅ | 2026-06-12 |
| TASK-012 | Populate `submission/local/g-browser-test-passed-run/` with Playwright passed-run evidence from `output/playwright/`, including `playwright-run.log`, `junit.xml`, `screenshots/valid-submit.png`, `screenshots/empty-submit.png`, and a reviewed validation explanation. | ✅ | 2026-06-12 |
| TASK-013 | Copy or rewrite the HAR scenario into `submission/local/h-har-scenario/scenario-description.md` from `docs/har-scenario.md` and ensure it uses words matching the actual app flow. | ✅ | 2026-06-12 |
| TASK-014 | Copy the reviewed HAR file `output/har/meta-functional-flow.har` to `submission/local/i-har-file/meta-functional-flow.har` and add a README stating that the HAR was reviewed for sensitive headers, cookies, and irrelevant cached content. | | |
| TASK-015 | Populate `submission/local/j-gatling-max-limit/` with the max-limit conclusion, `output/gatling/max-limit/max-limit-run.log`, `output/gatling/max-limit/index.html`, and `output/gatling/max-limit/max-limit-report.pdf`; mark the result as a tested lower bound unless a real maximum is proven. | ✅ | 2026-06-12 |
| TASK-016 | Populate `submission/local/k-gatling-cmd-screenshots/` with exactly `max-limit-terminal.png`, `load-5m-terminal.png`, and `stress-5m-terminal.png`; if any screenshot is missing, keep the README status as `missing` and do not mark the item ready. | | |
| TASK-017 | Populate `submission/local/l-gatling-result-pdfs/` with exactly `max-limit-report.pdf`, `load-5m-report.pdf`, `stress-5m-report.pdf`, and `graph-explanations.md`, sourced from `output/gatling/` and `docs/gatling.md`. | ✅ | 2026-06-12 |

### Implementation Phase 3

- GOAL-003: Populate optional public-IP bonus evidence without weakening the required local package.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-018 | Create `submission/public/README.md` defining `PUBLIC_APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`, source file `docs/public-app-bonus.md`, and rule that public evidence is optional bonus evidence only. | ✅ | 2026-06-12 |
| TASK-019 | Place the public browser screenshot at `submission/public/public-tomcat-screenshot/public-tomcat-url.png` and require the visible public URL to match `PUBLIC_APP_BASE_URL`. | | |
| TASK-020 | Populate `submission/public/public-monitoring-evidence/` with UptimeRobot or approved monitor UI evidence that shows the public target, pass/up status, and 5-minute cadence. | | |
| TASK-021 | Populate `submission/public/public-jenkins-monitoring-check/` with Jenkins or script evidence showing `APP_BASE_URL=PUBLIC_APP_BASE_URL` for `meta-monitoring` or `scripts/run-monitoring-check`. | ✅ | 2026-06-12 |
| TASK-022 | Populate `submission/public/public-browser-test-passed-run/` with public-target Playwright evidence and a README proving the run used `PUBLIC_APP_BASE_URL`, not localhost or the Docker service URL. | ✅ | 2026-06-12 |
| TASK-023 | Populate `submission/public/public-gatling-max-limit/`, `submission/public/public-gatling-load-5m/`, and `submission/public/public-gatling-stress-5m/` only from user-run public-target Gatling artifacts; do not generate these artifacts directly as the agent. | | |
| TASK-024 | Populate `submission/public/aws-cleanup-verification/cleanup.md` with EC2 termination, Elastic IP release, and remaining paid-resource checks before marking the public evidence window closed. | | |

### Implementation Phase 4

- GOAL-004: Produce final send-ready manifests and keep documentation synchronized.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-025 | Create `submission/email/attachments-manifest.md` with one table for required local attachments `a` through `l`, one table for optional public attachments, and columns `Item`, `File`, `Source`, `Status`, `Freshness Check`, and `Notes`. | ✅ | 2026-06-12 |
| TASK-026 | Create `submission/email/email-body.md` with the assignment recipient, subject `Final Exercise from: Yonatan Csasznik, Yoed Halberstam, Niv Levin`, the 12 assignment items in order, and separate optional public-IP bonus notes. | ✅ | 2026-06-12 |
| TASK-027 | Update `docs/submission.md` so it points to the new `submission/local/`, `submission/public/`, and `submission/email/` structure without duplicating every packaged artifact path. | ✅ | 2026-06-12 |
| TASK-028 | Update `docs/changelog/11-submission-package.changelog.md` with the fresh structure implementation, exact validation commands, and remaining missing evidence rows. | ✅ | 2026-06-12 |

## 3. Alternatives

- **ALT-001**: Keep the current flat `submission/` structure. Rejected because it mixes source copies, evidence files, and partial screenshots without mapping directly to the 12 assignment items.
- **ALT-002**: Put public-IP bonus evidence beside the matching local evidence rows. Rejected because it creates grading risk by making optional public proof look like a replacement for required localhost evidence.
- **ALT-003**: Generate a ZIP-only final package outside the repository. Rejected because the repo needs a reviewable, versioned, deterministic package before any final ZIP is created.
- **ALT-004**: Move all generated `output/` artifacts into `submission/` automatically. Rejected because `output/` can contain stale or unreviewed artifacts; only reviewed final evidence belongs in `submission/`.

## 4. Dependencies

- **DEP-001**: `final-project.pdf` for authoritative assignment requirements.
- **DEP-002**: `docs/final-project.txt` for searchable assignment text and the exact 12 email items.
- **DEP-003**: `rules/compliance.md` for approved container, Playwright, monitoring, Gatling, HAR, and submission constraints.
- **DEP-004**: `docs/submission.md` for current submission workflow and open instructor questions.
- **DEP-005**: `docs/public-app-bonus.md` for the public target, EC2 details, and cleanup policy.
- **DEP-006**: `src/main/webapp/index.jsp` for the JSP source item.
- **DEP-007**: `tests/playwright/meta-functional.spec.js` and `output/playwright/` for browser automation evidence.
- **DEP-008**: `docs/har-scenario.md` and `output/har/meta-functional-flow.har` for HAR evidence.
- **DEP-009**: `docs/gatling.md` and `output/gatling/` for Gatling reports, PDFs, and graph explanations.
- **DEP-010**: User-captured screenshots for GitHub, Tomcat browser chrome, monitor UI, and Gatling terminal/CMD summaries.

## 5. Files

- **FILE-001**: `docs/plans/11-submission-package.md` is the source implementation plan rewritten by this change.
- **FILE-002**: `submission/README.md` will explain the package structure and readiness semantics.
- **FILE-003**: `submission/local/` will contain the 12 required local assignment evidence directories.
- **FILE-004**: `submission/public/` will contain optional public-IP bonus evidence only.
- **FILE-005**: `submission/email/email-body.md` will contain the final email draft.
- **FILE-006**: `submission/email/attachments-manifest.md` will contain the required and optional attachment checklist.
- **FILE-007**: `submission/archive/pre-2026-06-12-structure/` will preserve pre-structure evidence without deleting it.
- **FILE-008**: `docs/submission.md` will link to the fresh package structure and keep high-level submission workflow guidance.
- **FILE-009**: `docs/changelog/11-submission-package.changelog.md` will record implementation evidence, validation, and remaining risks.

## 6. Testing

- **TEST-001**: Run `find submission -name '.DS_Store' -print` and verify it prints no paths.
- **TEST-002**: Run `test -d submission/local/a-jsp-file && test -d submission/local/l-gatling-result-pdfs && test -d submission/public && test -d submission/email`.
- **TEST-003**: Run `test -f submission/email/attachments-manifest.md && test -f submission/email/email-body.md && test -f submission/README.md`.
- **TEST-004**: Run `rg -n "localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin|51\\.84\\.219\\.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin" submission docs/submission.md` and verify local and public URLs appear in the correct sections.
- **TEST-005**: Run `rg -n "PUBLIC_APP_BASE_URL" submission/public docs/public-app-bonus.md` and verify public evidence uses one public target.
- **TEST-006**: Run `rg -n "Selenium IDE|Playwright" submission/local/f-browser-test-file submission/local/g-browser-test-passed-run docs/submission.md` and verify the Playwright substitution is explicit.
- **TEST-007**: Run `git diff --check` and verify it exits with code `0`.
- **TEST-008**: Run the local compliance validator against `rules/compliance.md` after implementation and resolve every blocking issue before closeout.
- **TEST-009**: Do not run Gatling directly. If required Gatling screenshots or public-target artifacts are missing, ask the user to run the approved Jenkins or runner flow and provide the artifacts.

## 7. Risks & Assumptions

- **RISK-001**: The Playwright-over-Selenium substitution can still be challenged because the PDF names Selenium IDE `.side`; the package must explain the override clearly.
- **RISK-002**: Public-IP bonus evidence can become stale if the EC2 public IP changes or the instance is terminated before screenshots and reports are captured.
- **RISK-003**: HAR files can contain sensitive cookies, headers, URLs, or cached content; the HAR must be reviewed before packaging.
- **RISK-004**: Existing `output/` artifacts may be stale. Copying them blindly into `submission/` would create false readiness.
- **RISK-005**: Gatling terminal/CMD screenshots remain a likely blocker because they require user-run or manually captured evidence.
- **RISK-006**: UptimeRobot or approved monitor UI evidence may be missing even when Jenkins-side monitoring checks pass.
- **ASSUMPTION-001**: The final group names for the email subject are `Yonatan Csasznik, Yoed Halberstam, Niv Levin`.
- **ASSUMPTION-002**: The public GitHub repository remains `https://github.com/y0ncha/meta-final-project`.
- **ASSUMPTION-003**: The local final app context remains `yonatan-csasznik-yoed-halberstam-niv-levin`.
- **ASSUMPTION-004**: The current public app URL from `docs/public-app-bonus.md` remains valid only for the short public evidence window and must be rechecked before final bonus packaging.

## 8. Related Specifications / Further Reading

- [Final project PDF](../../final-project.pdf)
- [Searchable final project text](../final-project.txt)
- [Compliance rules](../../rules/compliance.md)
- [Submission guide](../submission.md)
- [Public app bonus tracker](../public-app-bonus.md)
- [Gatling evidence guide](../gatling.md)
- [HAR scenario guide](../har-scenario.md)
- [Playwright evidence guide](../playwright.md)
- [Plan 11 changelog](../changelog/11-submission-package.changelog.md)
