# Plan 03 - JSP Maven WAR App

## Summary

Implemented the JSP application as a Maven WAR project for the MTA DevOps final project.

## Files Changed

- `pom.xml`: Added Maven WAR project metadata for `mta.devops:meta:1.0.0`, Java 17 compatibility, final WAR name `MeTA`, and `maven-war-plugin` configuration with `failOnMissingWebXml=false`.
- `src/main/webapp/index.jsp`: Added the JSP application page with one link, one button, one text input, server-side form handling, HTML escaping, and stable IDs for later Playwright validation.
- `README.md`: Updated the local Tomcat application URL to `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- `rules/compliance.md`: Documents the group-member context path `/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- `docs/plans/04-tomcat-container-deployment.md`, `docs/plans/05-jenkins-container-ci-cd.md`, `docs/plans/09-monitoring-and-jenkins-schedule.md`, and `docs/plans/10-aws-ec2-public-vm-bonus.md`: Updated downstream deployment, CI, monitoring, and public VM references to use `/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- `docs/changelog/03-jsp-maven-war-app.changelog.md`: Added this implementation and validation record.

## Tool Versions Observed

- Maven: `Apache Maven 3.9.15 (98b2cdbfdb5f1ac8781f537ea9acccaed7922349)`
- Maven Java runtime line: `Java version: 21.0.9, vendor: Oracle Corporation, runtime: /Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home`
- Java: `java version "21.0.9" 2025-10-21 LTS`
- Java runtime: `Java(TM) SE Runtime Environment (build 21.0.9+7-LTS-338)`
- Java VM: `Java HotSpot(TM) 64-Bit Server VM (build 21.0.9+7-LTS-338, mixed mode, sharing)`

## Build Output

- Maven command: `mvn clean package`
- Generated WAR: `target/yonatan-csasznik-yoed-halberstam-niv-levin.war`
- Intended Plan 04 deployment URL: `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

## Validation

| Command | Result |
|---------|--------|
| `mvn clean package` | Passed after Maven resolved `maven-war-plugin:3.4.0`; build produced `target/yonatan-csasznik-yoed-halberstam-niv-levin.war`. |
| `test -f target/yonatan-csasznik-yoed-halberstam-niv-levin.war` | Passed. |
| `jar tf target/yonatan-csasznik-yoed-halberstam-niv-levin.war` | Passed; output included `index.jsp` and did not include `WEB-INF/web.xml`. |
| `rtk grep -n "pageTitle\|aboutLink\|nameInput\|submitButton\|resultMessage\|validationMessage" src/main/webapp/index.jsp` | Passed; all stable selectors were present. |

## Notes

- The first sandboxed `mvn clean package` attempt failed because Maven could not write to `/Users/yonatan/.m2/repository`. The build passed when rerun with approval to use the normal Maven local repository.
- This plan does not deploy the WAR to Tomcat. Plan 04 owns copying or mounting `target/yonatan-csasznik-yoed-halberstam-niv-levin.war` into the containerized Tomcat `webapps` path and verifying the local URL.
- The Maven coordinate is `mta.devops:meta:1.0.0`. The artifact ID remains `meta`, while Maven `finalName` defines the WAR name and Tomcat context path as `yonatan-csasznik-yoed-halberstam-niv-levin`.
- The context name is now the group-member slug `yonatan-csasznik-yoed-halberstam-niv-levin`, removing the earlier short-name compliance risk.

## Follow-Up - 2026-06-11

- Updated `src/main/webapp/index.jsp` with assignment-safe MeTA Corporate humor while preserving the required link, button, text input, stable IDs, and server-side escaping.
- Updated exact Playwright, HAR capture, Gatling, and documentation assertions for the new deterministic success and validation messages.
- Validation: `node --check tests/playwright/meta-functional.spec.js` passed.
- Validation: `node --check tests/playwright/capture-har.js` passed.
- Validation: `mvn -q -DskipTests package` passed.
- Deployment: `./scripts/deploy-war` passed after Docker access approval and printed `Deployed URL: http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- Browser verification: `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` showed the new MeTA Corporate lead/about copy, the valid-submit success message, and the empty-submit validation message.

## Follow-Up - 2026-06-11 Context Path

- Changed the JSP Tomcat context from the short project context to `/yonatan-csasznik-yoed-halberstam-niv-levin/` so the local URL visibly includes all group members.
- Updated Maven `finalName`, `scripts/deploy-war`, `Jenkinsfile`, Playwright, HAR, monitoring, Gatling, report generation, compliance docs, and submission docs to use `target/yonatan-csasznik-yoed-halberstam-niv-levin.war` and `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- Hardened `scripts/deploy-war` to remove stale legacy `meta` deployment artifacts before copying `yonatan-csasznik-yoed-halberstam-niv-levin.war`, so the old lowercase context does not remain active after deployment.
- Validation: `mvn -q clean package` passed and produced `target/yonatan-csasznik-yoed-halberstam-niv-levin.war`.
- Deployment: `./scripts/deploy-war` passed after Docker access approval and printed `Deployed URL: http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- Browser verification: `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` loaded the MeTA page, while `http://localhost:8080/meta/` returned Tomcat 404.

## Follow-Up - 2026-06-11 Browser Copy Comment

- Updated the JSP lead paragraph to keep the `final-project.pdf` evidence wink while adding meeting-themed jokes about DevOps being unavailable and AI replacing the team.
- Added Playwright assertions for the new `DevOps is unavailable` and `AI will replace us` phrases so the visible copy stays covered by the functional browser flow.
- Validation: `./scripts/run-playwright-container` failed before the JSP copy update because Tomcat still served the old lead paragraph.
- Deployment: `./scripts/deploy-war` passed after Docker access approval and printed `Deployed URL: http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- Validation: `./scripts/run-playwright-container` passed with `1 passed`.
- Browser verification: the in-app browser at `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` showed the updated lead paragraph.

## Follow-Up - 2026-06-11 Browser Copy Revision

- Replaced the JSP lead paragraph with the shorter ticket/SLA joke: DevOps got a ticket two weeks ago, the SLA is 3 weeks, and hopefully AI will not replace half of the company before then.
- Updated Playwright assertions to cover `opened a ticket for DevOps two weeks ago` and `AI won't replace half of the company`.
- Validation: `./scripts/run-playwright-container` failed before the JSP copy update because Tomcat still served the previous lead paragraph.
- Deployment: `./scripts/deploy-war` passed after Docker access approval and printed `Deployed URL: http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- Validation: `./scripts/run-playwright-container` passed with `1 passed`.
- Browser verification: the in-app browser at `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` showed the revised lead paragraph.
