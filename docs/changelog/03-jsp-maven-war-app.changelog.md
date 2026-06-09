# Plan 03 - JSP Maven WAR App

## Summary

Implemented the JSP application as a Maven WAR project for the MTA DevOps final project.

## Files Changed

- `pom.xml`: Added Maven WAR project metadata for `mta.devops:meta:1.0.0`, Java 17 compatibility, final WAR name `meta`, and `maven-war-plugin` configuration with `failOnMissingWebXml=false`.
- `src/main/webapp/index.jsp`: Added the JSP application page with one link, one button, one text input, server-side form handling, HTML escaping, and stable IDs for later Playwright validation.
- `README.md`: Updated the local Tomcat application URL to `http://localhost:8080/meta/`.
- `contribution.md`: Documented the accepted context-path override from group-member names to `/meta/`.
- `docs/plans/04-tomcat-container-deployment.md`, `docs/plans/05-jenkins-container-ci-cd.md`, `docs/plans/09-monitoring-and-jenkins-schedule.md`, and `docs/plans/10-public-vm-bonus.md`: Updated downstream deployment, CI, monitoring, and public VM references to use `/meta/`.
- `docs/changelog/03-jsp-maven-war-app.changelog.md`: Added this implementation and validation record.

## Tool Versions Observed

- Maven: `Apache Maven 3.9.15 (98b2cdbfdb5f1ac8781f537ea9acccaed7922349)`
- Maven Java runtime line: `Java version: 21.0.9, vendor: Oracle Corporation, runtime: /Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home`
- Java: `java version "21.0.9" 2025-10-21 LTS`
- Java runtime: `Java(TM) SE Runtime Environment (build 21.0.9+7-LTS-338)`
- Java VM: `Java HotSpot(TM) 64-Bit Server VM (build 21.0.9+7-LTS-338, mixed mode, sharing)`

## Build Output

- Maven command: `mvn clean package`
- Generated WAR: `target/meta.war`
- Intended Plan 04 deployment URL: `http://localhost:8080/meta/`

## Validation

| Command | Result |
|---------|--------|
| `mvn clean package` | Passed after Maven resolved `maven-war-plugin:3.4.0`; build produced `target/meta.war`. |
| `test -f target/meta.war` | Passed. |
| `jar tf target/meta.war` | Passed; output included `index.jsp` and did not include `WEB-INF/web.xml`. |
| `rtk grep -n "pageTitle\|aboutLink\|nameInput\|submitButton\|resultMessage\|validationMessage" src/main/webapp/index.jsp` | Passed; all stable selectors were present. |

## Notes

- The first sandboxed `mvn clean package` attempt failed because Maven could not write to `/Users/yonatan/.m2/repository`. The build passed when rerun with approval to use the normal Maven local repository.
- This plan does not deploy the WAR to Tomcat. Plan 04 owns copying or mounting `target/meta.war` into the containerized Tomcat `webapps` path and verifying the local URL.
- The Maven coordinate is `mta.devops:meta:1.0.0`. The `meta` artifact ID also defines the WAR name and Tomcat context path.
- The context name `meta` is deterministic for execution and is documented as an accepted context-path override in `contribution.md`. If the lecturer requires group member names in the URL, update the Maven `finalName`, later deployment paths, and captured evidence before submission.
