---
goal: JSP Maven WAR Application for Containerized Tomcat
version: 1.0
date_created: 2026-06-10
last_updated: 2026-06-11
owner: Project team
status: "Completed"
tags:
  - feature
  - jsp
  - maven
  - war
  - tomcat
  - devops-final-project
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

This plan creates the required MTA DevOps final-project JSP application as a Maven WAR project. The implementation creates a deterministic Tomcat context named `yonatan-csasznik-yoed-halberstam-niv-levin`, a single JSP page with one link, one button, and one text input, and local Maven build validation that produces `target/yonatan-csasznik-yoed-halberstam-niv-levin.war`. Deployment into the Tomcat Docker container is intentionally handled by Plan 04.

## 1. Requirements & Constraints

- **REQ-001**: Create a Maven WAR project at the repository root with `pom.xml` as the build descriptor.
- **REQ-002**: Configure Maven group ID `mta.devops`, artifact ID `meta`, version `1.0.0`, packaging `war`, and final WAR name `yonatan-csasznik-yoed-halberstam-niv-levin`.
- **REQ-003**: Create JSP source file `src/main/webapp/index.jsp` as the primary application page and final-submission JSP artifact.
- **REQ-004**: The JSP page must contain exactly one primary text input with `id="nameInput"` and `name="nameInput"`.
- **REQ-005**: The JSP page must contain at least one clickable link with `id="aboutLink"` and visible text `About this app`.
- **REQ-006**: The JSP page must contain at least one button with `id="submitButton"` and visible text `Submit`.
- **REQ-007**: The JSP page must render a deterministic heading with `id="pageTitle"` and visible text `MeTA`.
- **REQ-008**: The JSP page must implement deterministic visible behavior for five future Playwright validations: heading loads, link reveals an about section, text input accepts a value, submit with a non-empty value shows a success result, and submit with an empty value shows a validation message.
- **REQ-009**: The generated WAR file must be `target/yonatan-csasznik-yoed-halberstam-niv-levin.war`.
- **REQ-010**: The intended local Tomcat URL after Plan 04 deployment must be `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **REQ-011**: The JSP must require no backend database, no external SaaS call, no Java servlet class, and no runtime secrets.
- **REQ-012**: The JSP must be simple enough to defend live and modify quickly during the 15-20 minute project defense.
- **CON-001**: Read `contribution.md` from the repository root before implementation and stop if any task conflicts with it.
- **CON-002**: Use the containerized project runtime defined by `rules/compliance.md`; do not document or depend on host Tomcat or host Jenkins.
- **CON-003**: Do not deploy the WAR to Tomcat in this plan; Plan 04 owns deployment into Docker-managed Tomcat `webapps`.
- **CON-004**: Do not add Playwright, Gatling, HAR, Jenkins, monitoring, or public VM implementation files in this plan.
- **CON-005**: Do not install, upgrade, reinstall, or replace Java, Maven, Docker, Tomcat, Jenkins, Playwright, Gatling, Node, Bun, or other tools while executing this plan.
- **CON-006**: Generated Maven output under `target/` and generated `*.war` files must remain untracked because `.gitignore` already ignores them.
- **SEC-001**: Do not add credentials, tokens, cookies, private keys, or personally sensitive data to `pom.xml`, `index.jsp`, documentation, or generated output.
- **SEC-002**: Escape every user-provided value displayed by JSP scriptlet code before writing it into the HTML response.
- **GUD-001**: Prefer `mvn clean package` for Maven validation because Maven is already installed locally.
- **GUD-002**: Use `rtk read`, `rtk grep`, `rtk find`, and `rtk diff` for noisy file reads, searches, and diffs when those wrappers preserve required detail.
- **PAT-001**: Keep Plan 03 source code minimal and explicit so later Plan 06 Playwright tests can target stable element IDs.
- **PAT-002**: Keep application source under standard Maven WAR paths: `src/main/webapp/` for JSP and `src/main/webapp/WEB-INF/` only if a descriptor becomes necessary.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Verify execution context and prepare to edit only the Maven WAR application files.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Run `rtk read contribution.md` and `rtk read rules/compliance.md` from the repository root and confirm Plan 03 uses containerized Tomcat only as the later runtime, creates a JSP app with one link, one button, and one text input, and does not conflict with `rules/compliance.md`. | ✅ | 2026-06-10 |
| TASK-002 | Run `git status --short --branch` from the repository root. If unrelated uncommitted changes exist outside `docs/plans/`, stop and report the exact output before creating a branch or editing implementation files. | ✅ | 2026-06-10 |
| TASK-003 | Create or switch to branch `feature/plan-03-jsp-maven-war-app` before mutating tracked implementation files. If branch creation is blocked by uncommitted work, stop and report the exact `git status --short --branch` output. | ✅ | 2026-06-10 |
| TASK-004 | Run `mvn --version` and `java -version`; record the exact observed Maven and Java versions in `docs/changelog/03-jsp-maven-war-app.changelog.md` during closeout. | ✅ | 2026-06-10 |
| TASK-005 | Run `rtk find . -maxdepth 4 -type f` and confirm whether `pom.xml`, `src/main/webapp/index.jsp`, or `src/main/webapp/WEB-INF/web.xml` already exist before creating new files. | ✅ | 2026-06-10 |

### Implementation Phase 2

- GOAL-002: Create the Maven WAR build descriptor with deterministic coordinates and Tomcat 8.5-compatible output.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-006 | Create `pom.xml` at the repository root if it does not exist. If it already exists, update it in place without deleting unrelated project configuration. | ✅ | 2026-06-10 |
| TASK-007 | In `pom.xml`, set `<modelVersion>4.0.0</modelVersion>`, `<groupId>mta.devops</groupId>`, `<artifactId>meta</artifactId>`, `<version>1.0.0</version>`, `<packaging>war</packaging>`, and `<name>MTA DevOps Final Project JSP App</name>`. | ✅ | 2026-06-10 |
| TASK-008 | In `pom.xml`, set project properties `<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>` and `<maven.compiler.release>17</maven.compiler.release>` for compatibility with the Plan 02 Tomcat image `tomcat:8.5.100-jdk17-temurin`. | ✅ | 2026-06-10 |
| TASK-009 | In `pom.xml`, configure `<build><finalName>yonatan-csasznik-yoed-halberstam-niv-levin</finalName></build>` so `mvn clean package` creates `target/yonatan-csasznik-yoed-halberstam-niv-levin.war`. | ✅ | 2026-06-10 |
| TASK-010 | In `pom.xml`, configure `maven-war-plugin` version `3.4.0` with `<failOnMissingWebXml>false</failOnMissingWebXml>` so the project does not require `src/main/webapp/WEB-INF/web.xml`. | ✅ | 2026-06-10 |

### Implementation Phase 3

- GOAL-003: Create the JSP page with deterministic UI elements and validation behavior.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-011 | Create directory `src/main/webapp` if it does not exist. | ✅ | 2026-06-10 |
| TASK-012 | Create `src/main/webapp/index.jsp` with JSP page directive `<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>`. | ✅ | 2026-06-10 |
| TASK-013 | In `src/main/webapp/index.jsp`, define a JSP declaration method `private static String escapeHtml(String value)` that returns an empty string for `null` and replaces `&`, `<`, `>`, `"`, and `'` with HTML-safe entities before displaying request input. | ✅ | 2026-06-10 |
| TASK-014 | In `src/main/webapp/index.jsp`, read `String submittedName = request.getParameter("nameInput");`, compute `boolean submitted = "POST".equalsIgnoreCase(request.getMethod());`, and compute `String trimmedName = submittedName == null ? "" : submittedName.trim();` before rendering HTML. | ✅ | 2026-06-10 |
| TASK-015 | In `src/main/webapp/index.jsp`, render `<h1 id="pageTitle">MeTA</h1>` exactly once. | ✅ | 2026-06-10 |
| TASK-016 | In `src/main/webapp/index.jsp`, render `<a id="aboutLink" href="#about">About this app</a>` and an about section with `id="about"` that states the page is a Maven WAR for Tomcat with assignment-safe MeTA Corporate humor. | ✅ | 2026-06-10 |
| TASK-017 | In `src/main/webapp/index.jsp`, render a `<form id="nameForm" method="post" action="index.jsp">` containing `<input id="nameInput" name="nameInput" type="text">` and `<button id="submitButton" type="submit">Submit</button>`. | ✅ | 2026-06-10 |
| TASK-018 | In `src/main/webapp/index.jsp`, when `submitted` is true and `trimmedName` is non-empty, render a deterministic `#resultMessage` that includes `Hello, ${escapedName}.` and the MeTA Corporate approval joke, using `escapeHtml(trimmedName)` for the displayed name. | ✅ | 2026-06-10 |
| TASK-019 | In `src/main/webapp/index.jsp`, when `submitted` is true and `trimmedName` is empty, render a deterministic `#validationMessage` telling the user to enter a name before MeTA Corporate schedules a meeting about the empty box. | ✅ | 2026-06-10 |
| TASK-020 | In `src/main/webapp/index.jsp`, include minimal inline CSS only inside a `<style>` tag in the page `<head>`; do not add external CSS, JavaScript, fonts, images, or network dependencies. | ✅ | 2026-06-10 |

### Implementation Phase 4

- GOAL-004: Validate the Maven WAR and record implementation evidence without deploying to Tomcat.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-021 | Run `mvn clean package` from the repository root and confirm it exits with status `0`. | ✅ | 2026-06-10 |
| TASK-022 | Run `test -f target/yonatan-csasznik-yoed-halberstam-niv-levin.war` from the repository root and confirm it exits with status `0`. | ✅ | 2026-06-10 |
| TASK-023 | Run `jar tf target/yonatan-csasznik-yoed-halberstam-niv-levin.war` and confirm the output contains `index.jsp` and does not require `WEB-INF/web.xml`. | ✅ | 2026-06-10 |
| TASK-024 | Run `rtk grep -n "pageTitle|aboutLink|nameInput|submitButton|resultMessage|validationMessage" src/main/webapp/index.jsp` and confirm every required stable selector appears in the JSP source. | ✅ | 2026-06-10 |
| TASK-025 | Create `docs/changelog/03-jsp-maven-war-app.changelog.md` after implementation and validation are complete. | ✅ | 2026-06-10 |
| TASK-026 | In `docs/changelog/03-jsp-maven-war-app.changelog.md`, document files changed, Maven and Java versions observed, the command `mvn clean package`, the generated WAR path `target/yonatan-csasznik-yoed-halberstam-niv-levin.war`, the intended Plan 04 URL `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`, and the `MeTA` context-path override in `rules/compliance.md`. | ✅ | 2026-06-10 |
| TASK-027 | Run `git diff -- pom.xml src/main/webapp/index.jsp README.md contribution.md docs/plans/03-jsp-maven-war-app.md docs/plans/04-tomcat-container-deployment.md docs/plans/05-jenkins-container-ci-cd.md docs/plans/09-monitoring-and-jenkins-schedule.md docs/plans/10-public-vm-bonus.md docs/changelog/03-jsp-maven-war-app.changelog.md` and verify no secrets, no generated `target/` files, and no unrelated changes are present. | ✅ | 2026-06-10 |
| TASK-028 | Run `git status --short --branch` and confirm only intentional Plan 03 files are modified or untracked. | ✅ | 2026-06-10 |

## 3. Alternatives

- **ALT-001**: Build a plain static HTML page instead of JSP. Rejected because the assignment requires a JSP web application and final submission includes the JSP file.
- **ALT-002**: Build a servlet-based Java web application with controllers. Rejected because the assignment needs a simple defensible JSP app and servlet classes add unnecessary moving parts.
- **ALT-003**: Use Gradle instead of Maven. Rejected because the requested plan is explicitly a Maven WAR app and Maven `3.9.15` is installed locally.
- **ALT-004**: Add `WEB-INF/web.xml` by default. Rejected because `maven-war-plugin` can build a WAR without `web.xml`, and an unnecessary descriptor increases maintenance surface.
- **ALT-005**: Use client-side JavaScript for form behavior. Rejected because server-rendered JSP form handling gives clearer proof that Tomcat is executing the JSP.
- **ALT-006**: Name the WAR with an unresolved group-name placeholder. Rejected because the plan must be machine-executable with no unresolved placeholders; the final context name is the explicit group-member slug.

## 4. Dependencies

- **DEP-001**: Local Maven must be available through `mvn`; current observed version before this plan rewrite was `Apache Maven 3.9.15`.
- **DEP-002**: Local Java must be available for Maven; current observed version before this plan rewrite was `Java 21.0.9`.
- **DEP-003**: Maven must be able to resolve `org.apache.maven.plugins:maven-war-plugin:3.4.0` from the local cache or Maven Central when `mvn clean package` runs.
- **DEP-004**: Plan 02 Docker Compose foundation must remain the deployment target for later Tomcat validation, specifically service `tomcat` and volume `tomcat_webapps`.
- **DEP-005**: Plan 04 must copy or mount `target/yonatan-csasznik-yoed-halberstam-niv-levin.war` into Tomcat `webapps` and verify `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.

## 5. Files

- **FILE-001**: `pom.xml` will define the Maven WAR project, Maven coordinates, Java compatibility, WAR plugin configuration, and final WAR name.
- **FILE-002**: `src/main/webapp/index.jsp` will contain the complete JSP UI and server-side form behavior.
- **FILE-003**: `docs/changelog/03-jsp-maven-war-app.changelog.md` will record implementation summary, current-machine tool versions, validation commands, and WAR output evidence after execution.
- **FILE-004**: `rules/compliance.md` defines the group-member context path and remains the project compliance source.
- **FILE-005**: `README.md` will document `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` as the local Tomcat application URL.
- **FILE-006**: `docs/plans/04-tomcat-container-deployment.md`, `docs/plans/05-jenkins-container-ci-cd.md`, `docs/plans/09-monitoring-and-jenkins-schedule.md`, and `docs/plans/10-public-vm-bonus.md` will use `/yonatan-csasznik-yoed-halberstam-niv-levin/` for downstream deployment, CI, monitoring, and public VM references.
- **FILE-007**: `.gitignore` will be read to confirm `target/` and `*.war` remain ignored; it will be modified only if generated Maven output is not ignored.
- **FILE-008**: `src/main/webapp/WEB-INF/web.xml` will not be created unless Maven validation proves the WAR cannot build without it.

## 6. Testing

- **TEST-001**: `mvn clean package` must exit with status `0`.
- **TEST-002**: `test -f target/yonatan-csasznik-yoed-halberstam-niv-levin.war` must exit with status `0`.
- **TEST-003**: `jar tf target/yonatan-csasznik-yoed-halberstam-niv-levin.war` must list `index.jsp`.
- **TEST-004**: `rtk grep -n "pageTitle|aboutLink|nameInput|submitButton|resultMessage|validationMessage" src/main/webapp/index.jsp` must show all six stable selectors.
- **TEST-005**: `git diff -- pom.xml src/main/webapp/index.jsp README.md contribution.md docs/plans/03-jsp-maven-war-app.md docs/plans/04-tomcat-container-deployment.md docs/plans/05-jenkins-container-ci-cd.md docs/plans/09-monitoring-and-jenkins-schedule.md docs/plans/10-public-vm-bonus.md docs/changelog/03-jsp-maven-war-app.changelog.md` must contain only intentional Plan 03 source and documentation changes.
- **TEST-006**: `git status --short --branch` must show no generated `target/` files or `*.war` files.

## 7. Risks & Assumptions

- **RISK-001**: The former short context-name compliance risk is resolved by using group-member names in the WAR and Tomcat context path.
- **RISK-002**: `mvn clean package` may need network access if `maven-war-plugin:3.4.0` is not already cached locally.
- **RISK-003**: JSP scriptlets are acceptable for this small coursework app but should not become a pattern for larger production applications.
- **RISK-004**: This plan does not prove Tomcat deployment; Plan 04 must deploy the WAR and capture the `localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` evidence.
- **RISK-005**: The project compliance rules intentionally use Playwright instead of Selenium IDE; this plan creates selectors for Playwright but does not eliminate the assignment override risk documented in `rules/compliance.md`.
- **ASSUMPTION-001**: The Maven coordinate remains `mta.devops:meta:1.0.0`; Maven `finalName` controls the WAR and Tomcat context name separately.
- **ASSUMPTION-002**: The app should remain dependency-light and not use databases, sessions, authentication, external APIs, or frontend package managers.
- **ASSUMPTION-003**: Plan 06 will implement the five functional validations using the stable element IDs defined in this plan.

## 8. Related Specifications / Further Reading

- [Project contribution workflow](../../contribution.md)
- [Project compliance rules](../../rules/compliance.md)
- [Docker Compose foundation plan](./02-docker-compose-foundation.md)
- [Tomcat container deployment plan](./04-tomcat-container-deployment.md)
- [Playwright container functional test plan](./06-playwright-container-functional-test.md)
- [Repository baseline](../repository-baseline.md)
