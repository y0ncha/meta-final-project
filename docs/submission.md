# Final Project Submission

This file maps the assignment requirements from `docs/final-project.txt` to the files, links, screenshots, and written explanations that must be sent in the final email.

## Submit To

- Recipient: `mosh.mta2@gmail.com`
- Subject: `Final Exercise from: <yournames>`
- Deadline from assignment: `2026-06-15` at midnight
- Base local app URL for evidence: `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Jenkins URL for local evidence: `http://localhost:8081/`
- Public GitHub repository: `https://github.com/y0ncha/meta-final-project`

Replace `<yournames>` with the final group member names before sending.

## Submission Rules

- Attach real generated evidence only. Do not include placeholder screenshots, fake monitor states, fake Gatling numbers, or guessed performance results.
- Use the Playwright deliverables as the Selenium IDE or similar browser automation evidence. The project override is documented in `rules/compliance.md`; keep this explanation visible in the submission and defense.
- Use the Tomcat URL screenshot only if the browser address bar visibly shows `localhost:8080/...`.
- Keep public-IP bonus evidence separate from the base local evidence. Do not claim the bonus unless the public target and steps 6-10 were actually validated against it.
- Review the HAR before sending because HAR files can include cookies, headers, response content, URLs, and cache metadata.

## Instructor Open Questions

These questions were sent to clarify assignment interpretation before final evidence capture:

1. Jenkins Pipeline was not demonstrated directly in class as far as we remember. Since the assignment asks for a single CI/CD pipeline, is it acceptable to use one Jenkins Pipeline job configured by a repository `Jenkinsfile`, or should the implementation follow the connected Freestyle-job approach shown in class?
2. The instructor mentioned that Jenkins plugins may be used as needed. Is it acceptable to use plugins such as Docker Pipeline to orchestrate container runners for Playwright and Gatling?
3. For monitoring, the intended tool is UptimeRobot. Since UptimeRobot is a SaaS tool with its own scheduled checks, what exactly should Jenkins do every 5 minutes: run a separate scheduled availability check, trigger or configure UptimeRobot, or simply document UptimeRobot's own 5-minute monitor clearly?
4. For the public-IP bonus, is port forwarding from a local machine/router acceptable, or is a public cloud VM/public server expected?
5. Yoed and Niv, the project partners, are currently on reserve duty and cannot attend the scheduled project defense. Is it possible to reschedule the defense so the group can present together?

## How To Assemble The Email

1. Run or refresh the required evidence before packaging:
   - Deploy app: `./scripts/deploy-war`
   - Browser automation: `./scripts/run-playwright-container`
   - HAR capture: `./scripts/capture-har`
   - HAR validation: `./scripts/validate-har output/har/meta-functional-flow.har`
   - Gatling max-limit, load, and stress commands from `docs/gatling.md`.
   - Jenkins CI/CD build after `meta-container-ci-cd` points at the public GitHub repo.
   - Jenkins scheduled monitoring build after `meta-monitoring` points at the public GitHub repo.
2. Capture manual screenshots where browser chrome or third-party UI must be visible:
   - GitHub repository page showing the JSP/app.
   - Tomcat app with `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` visible in the address bar.
   - Monitor tool showing the monitored target and a passed/up state.
   - Gatling terminal/CMD summaries for max-limit, load, and stress.
3. Export each Gatling `index.html` report to PDF:
   - Max-limit report PDF.
   - 5-minute load-test report PDF.
   - 5-minute stress-test report PDF.
4. Write the email body with the required explanations:
   - Browser validation types and why each validation is useful.
   - HAR scenario steps.
   - Max-limit result, why it is the limit, and how it was found.
   - Gatling graph explanations and what likely happened in the system.
5. Attach every evidence file listed in the submission evidence checklist below.

## Functional Deliverables

These are the required services, features, and pipeline capabilities that must work. The email evidence in the next section proves these deliverables.

| Deliverable | Functional requirement | How to prove it | Current status |
|---|---|---|---|
| JSP web application | A simple JSP application with at least one link, one button, and one text input. | Source file, GitHub screenshot, Tomcat screenshot, Playwright validations. | Ready |
| Git/GitHub source control | Application and automation code are stored in Git and the public GitHub repository. | Public repository link and GitHub screenshot showing the JSP/app. | Needs final public accessibility check and screenshot |
| Tomcat production deployment | Jenkins deploys the WAR into the Tomcat container and the app is reachable at `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`. | Jenkins build log, `./scripts/deploy-war` output, Tomcat screenshot with address bar visible. | Partial; final address-bar screenshot still needed |
| Jenkins CI/CD pipeline | Jenkins builds, deploys, verifies, and triggers the required automation flows from source control. | `meta-container-ci-cd` SCM/manual build log, Jenkins job configuration, archived/published reports. | Partial; needs final SCM-backed evidence after all stages exist |
| Monitoring | A separate Jenkins Freestyle job checks the application every 5 minutes and official monitor evidence shows the target is up. | Monitor passed screenshot plus `meta-monitoring` scheduled build log. | Missing official monitor screenshot and final scheduled Jenkins evidence |
| Browser functional automation | Browser automation validates 5 application behaviors and is triggerable from Jenkins. | Playwright test file, passed run log/report, screenshots, validation explanation. | Ready with Playwright override risk |
| HAR scenario capture | A browser scenario is described and the actual HAR file is captured. | `docs/har-scenario.md`, `output/har/meta-functional-flow.har`, HAR validation log. | Ready |
| Gatling max-limit test | Gatling discovers the app's tested max limit or a documented lower bound. | Max-limit run log, terminal screenshot, HTML/PDF report, written max-limit conclusion. | Reports/logs ready; terminal screenshot deferred |
| Gatling 5-minute load test | Gatling runs a 5-minute load test through Jenkins. | Jenkins/terminal log, screenshot, HTML/PDF report, graph explanation. | Reports/logs ready; terminal screenshot deferred |
| Gatling 5-minute stress test | Gatling runs a 5-minute stress test through Jenkins. | Jenkins/terminal log, screenshot, HTML/PDF report, graph explanation. | Reports/logs ready; terminal screenshot deferred |
| Final submission package | The final email contains all 12 required evidence items and written explanations. | Completed A-L evidence checklist with no missing rows. | Not ready until final screenshots, monitor evidence, GitHub accessibility, and Jenkins live build evidence are captured |

## Submission Evidence Checklist

These are the 12 items that `docs/final-project.txt` says to send by email.

| Item | Assignment requirement | Evidence to submit | Current project evidence | Status |
|---|---|---|---|---|
| a | The JSP file used | `src/main/webapp/index.jsp` | `src/main/webapp/index.jsp` | Ready |
| b | Screenshot of GitHub with the application/JSP in it | Manual screenshot of GitHub showing the repo and JSP/app file | Public repo URL is documented as `https://github.com/y0ncha/meta-final-project`; screenshot still must be captured | Missing screenshot |
| c | Screenshot of the app in Tomcat with `localhost:8080/...` visible | Manual browser screenshot with address bar visible at `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` | `output/screenshots/tomcat-meta-local.png` is supplemental only because it does not show browser chrome | Needs final screenshot |
| d | Link to public GitHub repo | `https://github.com/y0ncha/meta-final-project` | Git remote is expected to be that repository | Needs final accessibility check |
| e | Monitor tool name, monitored target, and passed monitor screenshot | UptimeRobot or approved monitor name, target URL, interval, and passed/up screenshot | Jenkins Freestyle job `meta-monitoring` runs `./scripts/run-monitoring-check` on schedule `H/5 * * * *`; official monitor screenshot is not present | Missing |
| f | Selenium IDE file `.side` | Playwright substitute: `tests/playwright/meta-functional.spec.js` | Playwright override documented in `rules/compliance.md` and `docs/playwright.md` | Ready with override risk |
| g | Selenium/automation passed-run screenshot plus validation explanation | Playwright test file, run log, screenshots, report, and written validation explanation | `output/playwright/playwright-run.log`, `output/playwright/junit.xml`, `output/playwright/playwright-report/index.html`, `output/playwright/screenshots/valid-submit.png`, `output/playwright/screenshots/empty-submit.png`, `docs/playwright.md` | Ready |
| h | Written HAR scenario | Scenario text in email or attached document | `docs/har-scenario.md` | Ready |
| i | HAR file | `output/har/meta-functional-flow.har` | `output/har/meta-functional-flow.har` and `output/har/har-capture.log` | Ready |
| j | Written max-limit result and explanation | Max-limit number, how it was found, and why it is the limit | `docs/gatling.md`, `output/gatling/max-limit/max-limit-run.log`, `output/gatling/max-limit/index.html` | Partial; current evidence supports a tested lower bound, not a true maximum |
| k | Three screenshots of Gatling CMD summaries: max limit, load, stress | Terminal/CMD screenshots for all three Gatling runs | `output/gatling/screenshots/max-limit-terminal.png`, `output/gatling/screenshots/load-5m-terminal.png`, and `output/gatling/screenshots/stress-5m-terminal.png` are intentionally not captured yet | Deferred; must capture before final email |
| l | Three Gatling result PDFs with graph explanations | Max-limit, load, and stress PDF reports plus written graph explanations | `output/gatling/max-limit/max-limit-report.pdf`, `output/gatling/load-5m/load-5m-report.pdf`, `output/gatling/stress-5m/stress-5m-report.pdf`, `docs/gatling.md` | Ready |

## Evidence Paths To Attach

Attach these when present and freshly validated:

- `src/main/webapp/index.jsp`
- `tests/playwright/meta-functional.spec.js`
- `docs/playwright.md`
- `docs/har-scenario.md`
- `output/har/meta-functional-flow.har`
- `output/playwright/playwright-run.log`
- `output/playwright/junit.xml`
- `output/playwright/playwright-report/index.html`
- `output/playwright/screenshots/valid-submit.png`
- `output/playwright/screenshots/empty-submit.png`
- Final GitHub screenshot showing the JSP/app.
- Final Tomcat screenshot with `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` visible.
- Final monitor passed screenshot.
- Final Gatling max-limit terminal screenshot.
- Final Gatling load-test terminal screenshot.
- Final Gatling stress-test terminal screenshot.
- `output/gatling/max-limit/max-limit-report.pdf`
- `output/gatling/load-5m/load-5m-report.pdf`
- `output/gatling/stress-5m/stress-5m-report.pdf`
- `output/gatling/max-limit/max-limit-run.log`
- `output/gatling/load-5m/load-5m-run.log`
- `output/gatling/stress-5m/stress-5m-run.log`

## Public-IP Bonus Evidence

The public-IP bonus is separate from the base local submission package. Do not replace the required `localhost:8080/...` Tomcat screenshot with public app exposure evidence.

The primary free path is home router port-forwarding:

- Local Tomcat remains `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- Router forwards public `tcp/8080` to the laptop `tcp/8080`.
- Jenkins remains local/private at `http://localhost:8081/`.
- UptimeRobot, Playwright, and Gatling target `http://<PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.

Use a public VM only as fallback if home public IP exposure is blocked by CGNAT, router restrictions, ISP restrictions, or unstable laptop availability.

Bonus evidence is claimable only when all public-target rows below are real and current:

| Bonus item | Public target | Required evidence | Status |
|---|---|---|---|
| Public Tomcat URL | `http://<PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` | Browser screenshot from outside the hosting network with address bar visible. | Pending public IP and port-forward or VM validation |
| Availability monitor | `http://<PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` | UptimeRobot or approved monitor screenshot showing up/pass state and public URL. | Pending public monitor evidence |
| Jenkins monitoring | `APP_BASE_URL=http://<PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` | `meta-monitoring` build log and archived `output/monitoring/latest-check.txt`. | Pending public-target Jenkins evidence |
| Browser automation | `APP_BASE_URL=http://<PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` | Playwright passed-run log/report/screenshots from the public target. | Pending public-target Playwright evidence |
| Gatling max-limit | `APP_BASE_URL=http://<PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` | Max-limit log, HTML report, PDF, and terminal or Jenkins-console screenshot. | Pending user-run public evidence |
| Gatling load 5m | `APP_BASE_URL=http://<PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` | Load-test log, HTML report, PDF, and terminal or Jenkins-console screenshot. | Pending user-run public evidence |
| Gatling stress 5m | `APP_BASE_URL=http://<PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` | Stress-test log, HTML report, PDF, and terminal or Jenkins-console screenshot. | Pending user-run public evidence |

Track the selected path, public URL, firewall or router decisions, and public evidence paths in Plan 10 (`docs/plans/10-public-vm-bonus.md`) or in a future evidence note if the plan is executed.

## Final Review Before Sending

- Confirm `main` is pushed to GitHub and the public repository opens without authentication.
- Confirm both Jenkins jobs are configured from SCM, not local mounted-script jobs.
- Confirm `meta-container-ci-cd` uses script path `Jenkinsfile`.
- Confirm `meta-monitoring` is a Freestyle project, runs `./scripts/run-monitoring-check` every 5 minutes, archives `output/monitoring/**/*`, and does not run Maven, deploy, Playwright, or Gatling commands.
- Confirm the Playwright override is explained clearly because the assignment text names Selenium IDE specifically.
- Confirm all Gatling numbers and graph explanations come from real generated reports.
- If claiming the public-IP bonus, confirm the selected public app exposure path has a real public URL, monitor evidence, Playwright evidence, Gatling max/load/stress evidence, and no pending rows for bullets 6-10.
- Capture the three Gatling terminal/CMD summary screenshots before sending; Plan 08 intentionally leaves those screenshot files deferred.
- Confirm the email has exactly the required subject: `Final Exercise from: <yournames>`.
