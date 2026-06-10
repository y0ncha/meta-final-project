# Final Project Submission

This file maps the assignment requirements from `docs/final-project.txt` to the files, links, screenshots, and written explanations that must be sent in the final email.

## Submit To

- Recipient: `mosh.mta2@gmail.com`
- Subject: `Final Exercise from: <yournames>`
- Deadline from assignment: `2026-06-15` at midnight
- Base local app URL for evidence: `http://localhost:8080/meta/`
- Jenkins URL for local evidence: `http://localhost:8081/`
- Public GitHub repository: `https://github.com/y0ncha/meta-final-project`

Replace `<yournames>` with the final group member names before sending.

## Submission Rules

- Attach real generated evidence only. Do not include placeholder screenshots, fake monitor states, fake Gatling numbers, or guessed performance results.
- Use the Playwright deliverables as the Selenium IDE or similar browser automation evidence. The project override is documented in `rules/compliance.md`; keep this explanation visible in the submission and defense.
- Use the Tomcat URL screenshot only if the browser address bar visibly shows `localhost:8080/...`.
- Keep public-IP bonus evidence separate from the base local evidence. Do not claim the bonus unless the public target and steps 6-10 were actually validated against it.
- Review the HAR before sending because HAR files can include cookies, headers, response content, URLs, and cache metadata.

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
   - Tomcat app with `http://localhost:8080/meta/` visible in the address bar.
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
| Tomcat production deployment | Jenkins deploys the WAR into the Tomcat container and the app is reachable at `http://localhost:8080/meta/`. | Jenkins build log, `./scripts/deploy-war` output, Tomcat screenshot with address bar visible. | Partial; final address-bar screenshot still needed |
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
| c | Screenshot of the app in Tomcat with `localhost:8080/...` visible | Manual browser screenshot with address bar visible at `http://localhost:8080/meta/` | `output/screenshots/04-tomcat-meta-local.png` is supplemental only because it does not show browser chrome | Needs final screenshot |
| d | Link to public GitHub repo | `https://github.com/y0ncha/meta-final-project` | Git remote is expected to be that repository | Needs final accessibility check |
| e | Monitor tool name, monitored target, and passed monitor screenshot | UptimeRobot or approved monitor name, target URL, interval, and passed/up screenshot | Jenkins Freestyle job `meta-monitoring` runs `./scripts/run-monitoring-check` on schedule `H/5 * * * *`; official monitor screenshot is not present | Missing |
| f | Selenium IDE file `.side` | Playwright substitute: `tests/playwright/meta-functional.spec.js` | Playwright override documented in `rules/compliance.md` and `docs/playwright.md` | Ready with override risk |
| g | Selenium/automation passed-run screenshot plus validation explanation | Playwright test file, run log, screenshots, report, and written validation explanation | `output/playwright/06-playwright-run.log`, `output/playwright/junit.xml`, `output/playwright/playwright-report/index.html`, `output/playwright/screenshots/06-valid-submit.png`, `output/playwright/screenshots/06-empty-submit.png`, `docs/playwright.md` | Ready |
| h | Written HAR scenario | Scenario text in email or attached document | `docs/har-scenario.md` | Ready |
| i | HAR file | `output/har/meta-functional-flow.har` | `output/har/meta-functional-flow.har` and `output/har/07-har-capture.log` | Ready |
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
- `output/playwright/06-playwright-run.log`
- `output/playwright/junit.xml`
- `output/playwright/playwright-report/index.html`
- `output/playwright/screenshots/06-valid-submit.png`
- `output/playwright/screenshots/06-empty-submit.png`
- Final GitHub screenshot showing the JSP/app.
- Final Tomcat screenshot with `http://localhost:8080/meta/` visible.
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

## Final Review Before Sending

- Confirm `main` is pushed to GitHub and the public repository opens without authentication.
- Confirm both Jenkins jobs are configured from SCM, not local mounted-script jobs.
- Confirm `meta-container-ci-cd` uses script path `Jenkinsfile`.
- Confirm `meta-monitoring` is a Freestyle project, runs `./scripts/run-monitoring-check` every 5 minutes, archives `output/monitoring/**/*`, and does not run Maven, deploy, Playwright, or Gatling commands.
- Confirm the Playwright override is explained clearly because the assignment text names Selenium IDE specifically.
- Confirm all Gatling numbers and graph explanations come from real generated reports.
- Capture the three Gatling terminal/CMD summary screenshots before sending; Plan 08 intentionally leaves those screenshot files deferred.
- Confirm the email has exactly the required subject: `Final Exercise from: <yournames>`.
