# 11 - Submission Package Changelog

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
