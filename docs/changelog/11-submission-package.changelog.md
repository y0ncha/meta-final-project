# 11 - Submission Package Changelog

## 2026-06-12 Submission Package Structure Implementation Follow-Up

## Summary

Implemented the first phase of the fresh `submission/` package: archived the old partial layout, created the local/public/email split, copied evidence that already existed, and documented the manual evidence still required before sending the final email.

## Files Changed

- `submission/README.md`: Documents the package layout and readiness semantics.
- `submission/manual-actions.md`: Lists screenshots, external checks, user-run Gatling work, and AWS cleanup actions still required.
- `submission/local/`: Contains assignment-aligned evidence folders `a` through `l`, with copied JSP, GitHub screenshot, Tomcat screenshot, GitHub link, Playwright evidence, HAR scenario/file, Gatling max-limit artifacts, and Gatling PDFs.
- `submission/public/`: Contains optional public-IP bonus folders, public URL support, public script-monitoring checks, and public Playwright evidence where available.
- `submission/email/attachments-manifest.md`: Tracks required local evidence and optional public evidence readiness.
- `submission/email/email-body.md`: Drafts the final email with pending evidence called out.
- `submission/archive/pre-2026-06-12-structure/`: Preserves the previous package buckets and stale copied Jenkins/Gatling evidence.
- `docs/submission.md`: Points readers to the new `submission/` package structure.
- `docs/plans/11-submission-package.md`: Marks implemented tasks complete and leaves manual evidence tasks open.

## Validation

- `find submission -name '.DS_Store' -print`: passed; printed no paths.
- `cmp src/main/webapp/index.jsp submission/local/a-jsp-file/index.jsp`: passed.
- `test -d submission/local/a-jsp-file`: passed.
- `test -d submission/local/l-gatling-result-pdfs`: passed.
- `test -d submission/public`: passed.
- `test -d submission/email`: passed.
- `test -f submission/email/attachments-manifest.md`: passed.
- `test -f submission/email/email-body.md`: passed.
- `rg -n "localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin|51\\.84\\.219\\.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin" submission docs/submission.md`: passed.
- `rg -n "PUBLIC_APP_BASE_URL" submission/public docs/public-app-bonus.md`: passed.
- `rg -n "Selenium IDE|Playwright" submission/local/f-browser-test-file submission/local/g-browser-test-passed-run docs/submission.md`: passed.
- `rg -n "1 passed" submission/local/g-browser-test-passed-run/playwright-run.log submission/public/public-browser-test-passed-run/playwright-run.log`: passed.
- `./scripts/validate-har submission/local/i-har-file/meta-functional-flow.har`: passed with `entries=4 groupContextRequests=4`.
- `git diff --check`: passed.
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target submission --rules rules/compliance.md`: passed with `fail=0`, `pass=39`, `warn=31`, and `manual=9`. Warnings/manual items match known missing screenshots, monitor UI evidence, public Gatling evidence, and defense-readiness checks.

## Remaining Risks

- Local/base monitor UI evidence and final separate `meta-monitoring` Freestyle evidence are still missing.
- Gatling terminal/CMD summary screenshots for max-limit, load, and stress are still missing.
- HAR file is packaged but still needs a final sensitivity review before external sharing.
- Public-IP bonus evidence is incomplete: public browser screenshot, official public monitor UI screenshot, public Gatling artifacts, and AWS cleanup verification are still missing.

## 2026-06-12 Fresh Submission Folder Structure Planning Follow-Up

## Summary

Rewrote Plan 11 into the required implementation-plan template and refocused it on a fresh `submission/` package layout with hard separation between required local evidence and optional public-IP bonus evidence.

## Files Changed

- `docs/plans/11-submission-package.md`: Adds front matter, status badge, requirements, phased tasks, alternatives, dependencies, files, testing, risks, and related references.
- `docs/plans/11-submission-package.md`: Defines the target `submission/local/`, `submission/public/`, `submission/email/`, and `submission/archive/` structure.
- `docs/plans/11-submission-package.md`: Maps local evidence directories directly to assignment email items `a` through `l` from `docs/final-project.txt`.
- `docs/plans/11-submission-package.md`: Requires public evidence to stay optional and tied to the same `PUBLIC_APP_BASE_URL` from `docs/public-app-bonus.md`.

## Validation

- `git diff --check`: passed.
- Reviewed `AGENTS.md`, `contribution.md`, `rules/compliance.md`, `docs/plans/11-submission-package.md`, `docs/changelog/11-submission-package.changelog.md`, `docs/final-project.txt`, `docs/submission.md`, `docs/public-app-bonus.md`, and current `submission/` contents before editing.

## Remaining Risks

- The fresh `submission/` directory structure is planned but not yet implemented.
- Existing `submission/` evidence still needs classification, archiving, or copying into the new local/public structure.
- Final manual screenshots, official monitor evidence, Gatling terminal/CMD screenshots, and optional public-target evidence still need fresh readiness checks before final email submission.

## 2026-06-12 Public-Hosted Bonus Evidence Ownership Follow-Up

## Summary

Updated Plan 11 to own final evidence readiness, local base evidence, optional public-hosted bonus evidence, attachment readiness, and submission closeout. Plan 10 now owns only the EC2 public host setup and handoff details.

## Files Changed

- `docs/plans/11-submission-package.md`: Clarifies that local base evidence remains required even when public-hosted bonus evidence exists.
- `docs/plans/11-submission-package.md`: Adds a separate public-hosted bonus evidence checklist that must use the same `PUBLIC_APP_BASE_URL`.
- `docs/plans/11-submission-package.md`: Keeps pending evidence explicit and forbids marking rows ready from plan checkboxes alone.
- `docs/submission.md`: Moves the public-IP bonus section from home router port-forwarding to the selected AWS EC2 Tomcat-only path.
- `docs/public-app-bonus.md`: Supplies the public target, EC2 details, cost controls, and raw host facts for Plan 11 to classify later.

## Validation

- `git diff --check`: passed.
- Public-hosted bonus evidence remains pending until Plan 11 points every public-hosted row to real artifacts from the same public target.
- Local base evidence remains separate and required; public-hosted evidence does not replace the `localhost:8080/...` Tomcat screenshot.

## Remaining Risks

- Official UptimeRobot or SiteMonitorLite public monitor UI evidence is still pending.
- Public-target Gatling max-limit, load, and stress artifacts are still pending and must come from user-run Jenkins or runner evidence.
- AWS cleanup verification is still required before the public-hosted bonus evidence window can be closed.

## 2026-06-11 Group-Member Context Path Follow-Up

## Summary

Changed the final Tomcat WAR and context path to `yonatan-csasznik-yoed-halberstam-niv-levin` so the grading URL visibly includes all group members and removes the earlier short-context compliance risk.

## Files Changed

- `pom.xml`: Sets Maven `finalName` to `yonatan-csasznik-yoed-halberstam-niv-levin`.
- `scripts/deploy-war`: Defaults and validates `TOMCAT_CONTEXT=yonatan-csasznik-yoed-halberstam-niv-levin`, defaults `WAR_SOURCE` to the matching WAR, and removes stale `MeTA` and `meta` deployments.
- `Jenkinsfile`: Uses `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` and archives the renamed WAR.
- Playwright, HAR, Gatling, and monitoring defaults now target the group-member context path.
- `rules/compliance.md`, README, current docs, plans, and submission checklist now use the final local URL `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- `tests/scripts/test-context-path-defaults.sh`: Adds a focused regression check for the canonical context path.

## Validation

- `sh tests/scripts/test-context-path-defaults.sh`: passed after first failing against the old `MeTA` final name.
- `sh tests/scripts/test-run-monitoring-check.sh`: passed.
- `sh tests/scripts/test-generate-pipeline-report.sh`: passed.
- `sh tests/scripts/test-generate-playwright-jenkins-report.sh`: passed.
- `sh -n scripts/deploy-war scripts/run-monitoring-check scripts/run-playwright-container scripts/capture-har scripts/run-gatling-container scripts/generate-pipeline-report scripts/validate-har`: passed.
- `git diff --check`: passed.
- `mvn -q clean package`: passed and produced `target/yonatan-csasznik-yoed-halberstam-niv-levin.war`.
- `./scripts/deploy-war`: passed and printed `Deployed URL: http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- HTTP status checks after deploy: new context returned `200`; old `/MeTA/` and `/meta/` returned `404`.
- Tomcat filesystem check after deploy confirmed only `/usr/local/tomcat/webapps/yonatan-csasznik-yoed-halberstam-niv-levin.war` and the matching expanded directory remain; stale `MeTA` and `meta` artifacts are removed.
- `./scripts/run-playwright-container`: passed in the official Playwright container with `1 passed`.
- `./scripts/capture-har && ./scripts/validate-har output/har/meta-functional-flow.har`: passed with `groupContextRequests=2`.
- `APP_BASE_URL=http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ ./scripts/run-monitoring-check`: passed.
- Jenkins declarative linter for `/workspace/final-project/Jenkinsfile`: passed with `Jenkinsfile successfully validated.`

## Remaining Risks

- Gatling was not rerun directly because project instructions say not to run Gatling tests directly. The next SCM-backed Jenkins evidence run should use the renamed context path and refresh Gatling reports/screenshots there.
- The final manual Tomcat screenshot still needs a visible browser address bar with `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
