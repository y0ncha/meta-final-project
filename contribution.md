# Project Contribution And Compliance Guide

This file is the active constraints and compliance source for the MTA 2026 Semester B DevOps final project. The assignment is 50% of the final grade and must be submitted by 2026-06-15 at midnight. Work must satisfy the assignment contract, not just look like a working demo.

## Branch And Merge Policy

- For every new implementation plan, create a new Git branch before making implementation changes.
- Implement the plan on that branch, not directly on the main/default branch.
- Use one canonical branch per plan. If a branch already exists for a plan, switch to that branch and continue there instead of creating a separate planning branch and a separate implementation branch.
- Keep each branch scoped to one plan unless explicitly instructed otherwise.
- Do not merge a plan branch back into the main/default branch until explicitly asked.
- If branch creation is blocked by uncommitted work, report the current Git state and ask how to handle the existing changes before switching or creating branches.

## Tool Version Policy

- Use the currently installed local apps and tool versions before installing alternatives.
- Run version checks before documenting setup steps, commands, Jenkins jobs, or evidence instructions.
- Treat version notes as a current-machine snapshot, not permanent truth. Re-check before relying on them.
- Do not upgrade, reinstall, or replace tools unless explicitly requested.
- If a required tool is missing, report it and recommend the smallest install path that satisfies the project.
- Current observed examples from 2026-06-09: Java `21.0.9`, Maven `3.9.15`, Node `v22.15.0`, npm/npx `11.8.0`, bun `1.3.14`, Git `2.50.1`, Docker `29.4.0`, and RTK `0.40.0`.
- Host Tomcat and host Jenkins installs are not project runtime dependencies. Do not document commands, evidence, or setup steps that rely on `/usr/local/tomcat8` or `/Users/yonatan/.jenkins`.
- Current missing-on-PATH examples from 2026-06-09: `gatling`, `jenkins`, `catalina`, `playwright`, and `playwright-cli`.

## Assignment Override Warning

- The original PDF asks for Selenium IDE deliverables: a `.side` file and a Selenium IDE passed-run screenshot.
- This project instruction overrides that browser-test tool choice: use Playwright instead of Selenium.
- This is an accepted grading compliance risk under the "Selenium IDE or similar" wording unless the lecturer later requires Selenium IDE specifically.

## Context Path Override Warning

- The original PDF asks for the Tomcat deployment folder/context to include the group members' names.
- This project instruction sets the Maven coordinate to `mta.devops:meta:1.0.0` and uses `meta` as the WAR name and Tomcat context path.
- Serve the local application at `http://localhost:8080/meta/` unless the lecturer later requires group-member names in the URL.
- This is an accepted grading compliance risk; if the lecturer requires names specifically, update the Maven `finalName`, deployment paths, monitoring targets, Playwright base URL, Gatling base URL, HAR target, screenshots, and submission notes before final evidence capture.

## Container Approval And Runtime Topology

- The instructor approved using containers for the project tools. Use the containerized track as the default implementation path.
- Run Apache Tomcat 8.5.x in Docker as the JSP production runtime. It must still deploy the app under Tomcat `webapps` and serve the app at `http://localhost:8080/meta/` for local evidence.
- Run Jenkins in Docker as the CI/CD orchestrator. Jenkins must use a persistent volume and must not claim port `8080`; expose Jenkins at `http://localhost:8081/`.
- Run Gatling in Docker for max-limit, 5-minute load, and 5-minute stress testing.
- Run the Playwright test runner in Docker for repeatable browser automation from Jenkins or local scripts.
- Use UptimeRobot SaaS for official availability-monitor evidence unless explicitly replaced by the instructor; it is listed by the assignment and gives stronger public-target evidence than a local monitor.
- Keep Git/GitHub as real host/public source control. Do not containerize GitHub.
- Host Tomcat and host Jenkins remain outside the project runtime. If the containerized runtime is blocked, fix the containerized path or document the blocker instead of falling back to local host installs.
- For public-IP bonus work, run the same Docker Compose stack on the public VM and point monitoring, Playwright, and Gatling at the public Tomcat URL.

## Core Scope

- Build or adapt a simple JSP web application.
- The JSP app must include at least one link, one button, and one input text box.
- Store all application code in Git and GitHub.
- Deploy to containerized Tomcat 8.5.x under `webapps` in the `meta` context/folder, per the Context Path Override Warning.
- Use containerized Jenkins to move code from Git/GitHub into Tomcat production.
- Treat deployment, monitoring, Playwright, and Gatling as one CI/CD pipeline flow unless there is a documented reason to split jobs.

## Jenkins Compliance

- Jenkins must be able to deploy the current GitHub code to the Tomcat container.
- Jenkins must be exposed on port `8081`; Tomcat owns port `8080` for grading screenshots.
- Jenkins must trigger the availability monitor every 5 minutes.
- Jenkins must trigger the Playwright functional test.
- Jenkins must trigger the 5-minute Gatling load test.
- Jenkins must trigger the 5-minute Gatling stress test.
- Keep job names, schedules, commands, and paths documented so they can be defended live.

## Monitoring Compliance

- Prefer UptimeRobot for official availability-monitor evidence. SiteMonitorLite or another explicit monitor is acceptable only if the project later documents why UptimeRobot was not used.
- Document the monitor tool name, monitored URL, interval, and pass/fail evidence.
- If pursuing the bonus, expose the app through a public IP and run monitoring, Playwright, and Gatling against that public target. Do not claim the bonus unless the public target and evidence are real.

## Playwright Compliance

- Use Playwright for browser automation, validation, screenshots, and repeatable CI/Jenkins execution.
- Prefer the official Playwright container for Jenkins execution so browser dependencies are reproducible.
- Provide the Playwright test file used for the functional test.
- The automated test must contain 5 validations of application functionality.
- Include passed-run evidence, relevant screenshots, and a written explanation of each validation.
- Use Playwright assertions deliberately. Explain whether each validation is positive or negative and why it is useful.

## Gatling Compliance

- Use Gatling to find the application's max limit.
- Prefer a Gatling container over a host Gatling install.
- Run a 5-minute load test through Jenkins.
- Run a 5-minute stress test through Jenkins.
- Save CMD/terminal screenshots for max limit, load test, and stress test runs.
- Export or print each Gatling `index.html` report to PDF for max limit, load test, and stress test.
- Explain why the Gatling graphs look the way they do and what likely happened in the system.
- Do not invent performance numbers. If a limit is uncertain, rerun or state the uncertainty clearly.

## HAR Compliance

- Describe the HAR scenario in words, for example: click link, type text, click button.
- Attach the actual HAR file used for the scenario.
- Keep the HAR scenario aligned with the JSP app behavior and Playwright/Gatling flows.

## Submission Package

The final email must be sent to `mosh.mta2@gmail.com` with subject `Final Exercise from: <yournames>` and include all 12 required items:

1. The JSP file used.
2. Screenshot of GitHub showing the application/JSP.
3. Screenshot of the application running in Tomcat, with the `localhost:8080/...` URL visible.
4. Link to the public GitHub repository.
5. Monitor tool name, monitored target, and screenshot showing the monitor passed.
6. Playwright test file.
7. Playwright passed-run evidence, relevant screenshot, and validation explanation.
8. Written HAR scenario description.
9. HAR file.
10. Written max-limit result, including why it is the limit and how it was found.
11. Three screenshots of Gatling CMD summaries: max limit, load, and stress.
12. Three Gatling result PDFs: max limit, load, and stress, with graph explanations.

## Defense Readiness

- Be ready to demo from the project laptop through projector or Google Meet.
- The defense is 15-20 minutes.
- Be ready to make a small live code change, push it to GitHub, and let Jenkins deploy it to Tomcat.
- Be ready to perform monitoring, Playwright, max-limit, load-test, and stress-test steps live.
- Keep commands and screenshots reproducible. A result that cannot be reproduced during defense is a risk.

## Evidence Standards

- Prefer real generated artifacts over prose claims: screenshots, Playwright reports, `.har`, Gatling PDFs, Jenkins logs, and GitHub links.
- Keep filenames clear and grouped by deliverable type.
- Do not fake screenshots, test results, monitor status, public IP exposure, or performance numbers.
- When fixing or adding project files, preserve evidence artifacts unless explicitly asked to clean them up.
