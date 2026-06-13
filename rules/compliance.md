# Final Project Compliance Rules

The authoritative assignment source is `final-project.pdf`. This file is the active operational compliance checklist for the MTA 2026 Semester B DevOps final project, derived from `final-project.pdf` plus documented project-specific overrides. The assignment is 50% of the final grade and must be submitted by 2026-06-15 at midnight.

## Approved Project Overrides

- The instructor explicitly approved using containers instead of host-installed project tools. Use the containerized track as the default implementation path.
- Run Apache Tomcat 8.5.x in Docker as the JSP production runtime. It must still deploy the app under Tomcat `webapps` and serve the app at `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` for local evidence.
- Run Jenkins in Docker as the CI/CD orchestrator. Jenkins must use a persistent volume and must not claim port `8080`; expose Jenkins at `http://localhost:8081/`.
- Run Gatling in Docker for max-limit, 5-minute load, and 5-minute stress testing.
- Run the Playwright test runner in Docker for repeatable browser automation from Jenkins or local scripts.
- Use UptimeRobot SaaS for official monitoring evidence unless explicitly replaced by the instructor. SiteMonitorLite is acceptable when explicitly documented.
- The instructor confirmed that monitoring should be implemented as a separate Jenkins job from the CI/CD build/deploy/test job.
- Keep Git and GitHub as real host/public source control. Do not containerize GitHub.
- Host Tomcat and host Jenkins are not project runtime dependencies. Do not document commands, evidence, or setup steps that rely on `/usr/local/tomcat8` or `/Users/yonatan/.jenkins`.
- If the containerized runtime is blocked, fix the containerized path or document the blocker instead of falling back to local host installs.

## Accepted Compliance Risks

- The PDF asks for Selenium IDE deliverables: a `.side` file and a Selenium IDE passed-run screenshot.
- This project uses Playwright as the "Selenium IDE or similar" browser-test tool unless the lecturer later requires Selenium IDE specifically.
- Keep the Playwright test file, passed-run evidence, screenshots, and validation explanation strong enough to defend this substitution.
- The PDF asks for the Tomcat deployment folder/context to include the group members' names.
- This project satisfies that wording with WAR name and Tomcat context path `yonatan-csasznik-yoed-halberstam-niv-levin`.
- Serve the local application at `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` for final local evidence.

## Class Compliance Priority

- When generic tool best practices conflict with the instructor's demonstrated metric, workflow, or terminology, prioritize class compliance for final evidence and defense wording.
- Treat the Gatling lecture workflow as the course-facing methodology: record a browser scenario as HAR, use Gatling Recorder with HAR Converter to generate a reference Scala simulation, then maintain a cleaned simulation for repeatable max-limit, load, and stress runs.
- The HAR file is Gatling scenario evidence. Position it as the recorded HTTP-level user journey that is converted into/reference-checked against Scala simulation code, not as Playwright evidence. Playwright remains separate browser-functional evidence.
- Gatling does not load the HAR at runtime in this project. It runs `MetaSimulation.scala`, the cleaned HAR-derived simulation.
- Prefer virtual-user level terminology for final evidence. Do not describe virtual-user levels as `users/sec`.
- Interpret Gatling's active-users graph as the number of virtual users currently running over time. Request-rate graphs describe throughput; response-time and KO/failure graphs explain system behavior.

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
- Treat deployment, browser automation, and Gatling as the CI/CD pipeline flow. Monitoring is the documented exception and must run as a separate Jenkins job.
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
- The monitor must run every 5 minutes through a separate Jenkins Freestyle job named `meta-monitoring`.
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
- Preserve the instructor's terminology in the written explanation: max-limit, load, and stress evidence should describe virtual-user levels, active users over time, successes, failures, and graph behavior.
- Save CMD/terminal screenshots for max-limit, load-test, and stress-test runs.
- Export or print each Gatling `index.html` report to PDF for max-limit, load-test, and stress-test runs.
- Explain why the Gatling graphs look the way they do and what likely happened in the system.
- In graph explanations, state exactly which graph is being discussed: active users over time, requests per second, response time percentiles, or failed requests/checks.
- Do not invent performance numbers. If a limit is uncertain, rerun or state the uncertainty clearly.

## HAR Compliance

- Describe the HAR scenario in words, for example: click link, type text, click button.
- Attach the actual HAR file used for the scenario.
- Keep the HAR scenario aligned with the JSP app behavior and the browser/Gatling flows.
- Keep the written HAR scenario aligned with the Gatling simulation steps. If Gatling executes only page load plus valid form submit, do not claim the Gatling run covers empty-submit validation unless the simulation also executes that request.
- For defense, explain the relationship as: HAR records the scenario, Gatling HAR Converter generated a reference Scala simulation, and the maintained `MetaSimulation.scala` executes the cleaned HAR-derived flow with multiple virtual users.

## Gatling/HAR Class Alignment Action Items

- [x] Generate a reference simulation with Gatling Recorder HAR Converter from `output/har/meta-functional-flow.har`.
- [x] Align the maintained Gatling simulation with the HAR's HTTP-relevant user flow.
- [x] Use virtual-user level terminology for max-limit, load, and stress configuration.
- [ ] Refresh Gatling CMD summary screenshots and PDF reports only from real generated runs; do not reuse stale graphs after changing the scenario or injection profile.
- [ ] Write the graph explanation with class terminology first: active users over time, request throughput, response times, successes, and failures.
- [ ] In the final email and defense, position HAR as the recorded scenario converted into the Gatling reference simulation, and position Playwright as a separate Selenium-like functional automation substitute.

## Submission Package

Send the final email to the assignment recipient with subject `Final Exercise from: <yournames>`.

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
