# Final Project Compliance Rules

This file is the active assignment and project-constraint source for the MTA 2026 Semester B DevOps final project. The source assignment is `final-project.pdf`. The assignment is 50% of the final grade and must be submitted by 2026-06-15 at midnight.

## Approved Project Overrides

- The instructor approved using containers for the project tools. Use the containerized track as the default implementation path.
- Run Apache Tomcat 8.5.x in Docker as the JSP production runtime. It must still deploy the app under Tomcat `webapps` and serve the app at `http://localhost:8080/meta/` for local evidence.
- Run Jenkins in Docker as the CI/CD orchestrator. Jenkins must use a persistent volume and must not claim port `8080`; expose Jenkins at `http://localhost:8081/`.
- Run Gatling in Docker for max-limit, 5-minute load, and 5-minute stress testing.
- Run the Playwright test runner in Docker for repeatable browser automation from Jenkins or local scripts.
- Use UptimeRobot SaaS for official availability-monitor evidence unless explicitly replaced by the instructor.
- Keep Git and GitHub as real host/public source control. Do not containerize GitHub.
- Host Tomcat and host Jenkins are not project runtime dependencies. Do not document commands, evidence, or setup steps that rely on `/usr/local/tomcat8` or `/Users/yonatan/.jenkins`.
- If the containerized runtime is blocked, fix the containerized path or document the blocker instead of falling back to local host installs.

## Accepted Compliance Risks

- The PDF asks for Selenium IDE deliverables: a `.side` file and a Selenium IDE passed-run screenshot.
- This project uses Playwright as the "Selenium IDE or similar" browser-test tool unless the lecturer later requires Selenium IDE specifically.
- Keep the Playwright test file, passed-run evidence, screenshots, and validation explanation strong enough to defend this substitution.
- The PDF asks for the Tomcat deployment folder/context to include the group members' names.
- This project uses Maven coordinate `mta.devops:meta:1.0.0`, WAR name `meta`, and Tomcat context path `meta`.
- Serve the local application at `http://localhost:8080/meta/` unless the lecturer later requires group-member names in the URL.
- If the lecturer requires names in the context path, update the Maven `finalName`, deployment paths, monitoring target, Playwright base URL, Gatling base URL, HAR target, screenshots, and submission notes before final evidence capture.

## Tool Version Policy

- Use the currently installed local apps and tool versions before installing alternatives.
- Run version checks before documenting setup steps, commands, Jenkins jobs, or evidence instructions.
- Treat version notes as a current-machine snapshot, not permanent truth. Re-check before relying on them.
- Do not upgrade, reinstall, or replace tools unless explicitly requested.
- If a required tool is missing, report it and recommend the smallest install path that satisfies the project.

## Core Assignment Scope

- Build or adapt a simple JSP web application.
- The JSP app must include at least one link, one button, and one input text box.
- Store all application code in Git and GitHub.
- Deploy the simple web application into Tomcat production.
- Use Jenkins to move code from Git/GitHub into Tomcat.
- Treat deployment, monitoring, browser automation, and Gatling as one CI/CD pipeline flow unless there is a documented reason to split jobs.
- Bonus work is worth up to 10 additional points only if the application is exposed through a real public IP and steps 6-10 are performed against that public target without compromising the result quality.

## Jenkins Compliance

- Jenkins must be able to deploy the current GitHub code to the Tomcat container.
- Jenkins must be exposed on port `8081`; Tomcat owns port `8080` for grading screenshots.
- Jenkins must trigger the availability monitor every 5 minutes.
- Jenkins must trigger the browser functional test.
- Jenkins must trigger the 5-minute Gatling load test.
- Jenkins must trigger the 5-minute Gatling stress test.
- Keep job names, schedules, commands, credentials boundaries, and paths documented so they can be defended live.

## Monitoring Compliance

- Create an availability monitor for the application.
- Prefer UptimeRobot for official availability-monitor evidence. SiteMonitorLite or another explicit monitor is acceptable only if the project documents why UptimeRobot was not used.
- Document the monitor tool name, monitored URL, interval, and pass/fail evidence.
- The monitor must run every 5 minutes through a Jenkins-triggered job or an equivalent Jenkins-controlled schedule.
- If pursuing the public-IP bonus, run monitoring against the public Tomcat URL and do not claim the bonus unless the public target and evidence are real.

## Browser Automation Compliance

- Automate a simple functional test with 5 validations of application functionality.
- Use Playwright for browser automation, validation, screenshots, and repeatable CI/Jenkins execution.
- Prefer the official Playwright container for Jenkins execution so browser dependencies are reproducible.
- Provide the Playwright test file used for the functional test.
- Include passed-run evidence, relevant screenshots, and a written explanation of each validation.
- Use assertions deliberately. Explain whether each validation is positive or negative and why it is useful.

## Gatling Compliance

- Use Gatling to find the application's max limit.
- Prefer a Gatling container over a host Gatling install.
- Run a 5-minute load test through Jenkins.
- Run a 5-minute stress test through Jenkins.
- Save CMD/terminal screenshots for max-limit, load-test, and stress-test runs.
- Export or print each Gatling `index.html` report to PDF for max-limit, load-test, and stress-test runs.
- Explain why the Gatling graphs look the way they do and what likely happened in the system.
- Do not invent performance numbers. If a limit is uncertain, rerun or state the uncertainty clearly.

## HAR Compliance

- Describe the HAR scenario in words, for example: click link, type text, click button.
- Attach the actual HAR file used for the scenario.
- Keep the HAR scenario aligned with the JSP app behavior and the browser/Gatling flows.

## Submission Package

Send the final email to `mosh.mta2@gmail.com` with subject `Final Exercise from: <yournames>`.

The email must include all 12 required items:

1. The JSP file used.
2. Screenshot of GitHub showing the application/JSP.
3. Screenshot of the application running in Tomcat, with the `localhost:8080/...` URL visible.
4. Link to the public GitHub repository.
5. Monitor tool name, monitored target, and screenshot showing the monitor passed.
6. Browser automation test file. The PDF names Selenium IDE `.side`; this project uses Playwright under the accepted override.
7. Browser automation passed-run evidence, relevant screenshot, and validation explanation.
8. Written HAR scenario description.
9. HAR file.
10. Written max-limit result, including why it is the limit and how it was found.
11. Three screenshots of Gatling CMD summaries: max limit, load, and stress.
12. Three Gatling result PDFs: max limit, load, and stress, with graph explanations.

## Defense Readiness

- Be ready to demo from the project laptop through projector or Google Meet.
- The defense is 15-20 minutes.
- Be ready to make a small live code change, push it to GitHub, and let Jenkins deploy it to Tomcat.
- Be ready to perform monitoring, browser automation, max-limit, load-test, and stress-test steps live.
- Be ready to answer questions about course topics.
- Keep commands and screenshots reproducible. A result that cannot be reproduced during defense is a grading risk.

## Evidence Standards

- Prefer real generated artifacts over prose claims: screenshots, browser reports, `.har`, Gatling PDFs, Jenkins logs, and GitHub links.
- Keep filenames clear and grouped by deliverable type.
- Do not fake screenshots, test results, monitor status, public IP exposure, or performance numbers.
- When fixing or adding project files, preserve evidence artifacts unless explicitly asked to clean them up.
