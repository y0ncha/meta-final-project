# Final Project Submission Package

This is the single source of truth for the final email, required attachments, explanations, and optional public-IP bonus evidence.

## Email Header

- To: assignment recipient from `final-project.pdf`
- Subject: `Final Exercise from: Yonatan Csasznik, Yoed Halberstam, Niv Levin`
- Deadline from assignment: `2026-06-15` at midnight
- Local app evidence URL: `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Jenkins URL for local evidence: `http://localhost:8081/`
- Public GitHub repository: `https://github.com/y0ncha/meta-final-project`
- Optional public app URL: `http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

## Email Body

Hello Moshe,

Attached are the 12 required items for the MTA 2026 Semester B DevOps final project.

1. JSP file used: `submission/local/a-jsp-file/index.jsp`
2. GitHub screenshot showing the application/JSP: `submission/local/b-github-screenshot/github-jsp.png`
3. Tomcat screenshot with localhost URL visible: `submission/local/c-tomcat-local-screenshot/tomcat-local-url.png`
4. Public GitHub repository: `https://github.com/y0ncha/meta-final-project`
5. Monitor evidence: `submission/local/e-monitoring-evidence/`
6. Browser automation test file: `submission/local/f-browser-test-file/meta-functional.spec.js`
7. Browser automation passed-run evidence and validation explanation: `submission/local/g-browser-test-passed-run/`
8. HAR scenario description: `submission/local/h-har-scenario/scenario-description.md`
9. HAR file: `submission/local/i-har-file/meta-functional-flow.har`
10. Max-limit result and email explanation: `submission/local/j-gatling-max-limit/email-max-limit-text.md` (`8400` virtual users passed; `8420` was the first failing tested level)
11. Gatling CMD summary screenshots: `submission/local/k-gatling-cmd-screenshots/`
12. Gatling result PDFs and graph explanations: `submission/local/l-gatling-result-pdfs/`

Browser automation note: the assignment names Selenium IDE `.side`; this project uses Playwright as the Selenium IDE or similar browser automation tool. The Playwright test file and passed-run evidence are attached.

Gatling/HAR note: the HAR records the browser scenario. Gatling HAR Converter generated a reference Scala simulation, and the maintained `MetaSimulation.scala` is the cleaned HAR-derived version used for repeatable max-limit, load, and stress runs. Gatling does not load the HAR file at runtime.

Max-limit note: local Jenkins build `#224` tested `8000` to `12000` virtual users in `20`-user steps. `8400` passed with `KO=0`; `8420` failed with `61` connection-timeout errors. Under the project rule, the local tested max limit is `8400` virtual users.

Optional public-IP bonus evidence, if submitted, is kept separately under `submission/public/` and uses:

`http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

Public Gatling bonus note: Jenkins build `#225` targeted the public URL. Public max-limit evidence shows `8060` virtual users passed and `8080` was the first failing tested level; public load and stress evidence both completed with `0 KO`.

Regards,

Yonatan Csasznik, Yoed Halberstam, Niv Levin

## Required Attachments

These are the 12 items requested by `docs/final-project.txt`.

| Item | Required by assignment | Packaged evidence | Status | Explanation / note |
|---|---|---|---|---|
| a | JSP file used | `submission/local/a-jsp-file/index.jsp` | ready | Source JSP copied from `src/main/webapp/index.jsp`. |
| b | Screenshot of GitHub with the application/JSP | `submission/local/b-github-screenshot/github-jsp.png` | ready | Shows the GitHub repository and `src/main/webapp/index.jsp`. |
| c | Screenshot of the app in Tomcat with `localhost:8080/...` visible | `submission/local/c-tomcat-local-screenshot/tomcat-local-url.png` | ready | Shows browser chrome and the local Tomcat URL. |
| d | Link to public GitHub repo | `submission/local/d-github-public-link/github-public-repo.link` | ready, final browser check recommended | Link file contains `https://github.com/y0ncha/meta-final-project`; open once without authentication before sending. |
| e | Monitor tool name, monitored target, and passed monitor screenshot | `submission/local/e-monitoring-evidence/` | ready | Jenkins `meta-monitoring` screenshots show scheduled monitoring evidence. Public UptimeRobot bonus evidence is under `submission/public/public-monitoring-evidence/`. |
| f | Selenium IDE file `.side` | `submission/local/f-browser-test-file/meta-functional.spec.js` | ready with approved substitute risk | The project uses Playwright as the browser automation substitute; keep the substitution note in the email. |
| g | Browser automation passed-run screenshot and validation explanation | `submission/local/g-browser-test-passed-run/` | ready | Includes run log, native Playwright HTML report, passed-report screenshot, app screenshots, and `validation-explanation.md`. |
| h | Written HAR scenario | `submission/local/h-har-scenario/scenario-description.md` | ready | Describes the browser scenario in words. |
| i | HAR file | `submission/local/i-har-file/meta-functional-flow.har` | packaged; sensitivity review recommended | HAR validation passed, but the file contains local `JSESSIONID` cookie evidence. Review before external sharing. |
| j | Max-limit result, why it is the limit, and how it was found | `submission/local/j-gatling-max-limit/` | ready | Email-ready text is in `email-max-limit-text.md`. Local build `#224`: `8400` passed with `KO=0`; `8420` first failed. |
| k | Three Gatling CMD summary screenshots | `submission/local/k-gatling-cmd-screenshots/` | ready | Contains max-limit, load, and stress summary screenshots. |
| l | Three Gatling result PDFs with graph explanations | `submission/local/l-gatling-result-pdfs/` | ready | Contains max-limit, load, and stress PDFs plus `graph-explanations.md`. |

## Required Explanations

### Browser Validations

The browser automation evidence is packaged under `submission/local/g-browser-test-passed-run/` and the test source is `submission/local/f-browser-test-file/meta-functional.spec.js`.

Passed-run evidence:

- Native Playwright report: `submission/local/g-browser-test-passed-run/playwright-run-report.html`
- Passed-report screenshot: `submission/local/g-browser-test-passed-run/playwright-run-report.png`
- Console log: `submission/local/g-browser-test-passed-run/playwright-run.log`
- Screenshots: `submission/local/g-browser-test-passed-run/screenshots/valid-submit.png` and `submission/local/g-browser-test-passed-run/screenshots/empty-submit.png`

Validation types used:

- Positive validation: submits a valid name and asserts the success message appears.
- Negative validation: submits an empty name and asserts the validation message appears.
- Page-content checks: verifies the page title, form controls, and important supporting text.
- Smart assert/verify split: blocking behaviors use hard assertions; supporting text and non-blocking checks use softer verification so the report shows useful context without hiding the main functional result.

### HAR Scenario

The written HAR scenario is `submission/local/h-har-scenario/scenario-description.md`, and the HAR file is `submission/local/i-har-file/meta-functional-flow.har`.

Scenario summary:

1. Open the MeTA app.
2. Submit a valid name.
3. Return to the form.
4. Submit an empty name to trigger validation.

The HAR was used as the recording/reference source for the Gatling scenario. Gatling runs the cleaned Scala simulation, not the HAR file directly.

### Local Gatling Max Limit

Local Jenkins build `#224` is the base submission evidence.

- Tested range: `8000` to `12000` virtual users
- Step: `20` virtual users
- Passing rule: `KO=0`
- Highest passing tested level: `8400` virtual users
- First failing tested level: `8420` virtual users
- Conclusion: the local tested max limit is `8400` virtual users

A failed tested level is not the max limit. The max limit is the previous tested level that still had `KO=0`.

### Local Gatling Graphs

The local graph explanations are packaged in `submission/local/l-gatling-result-pdfs/graph-explanations.md`.

- Max-limit graphs show the system approaching the failure boundary; failures begin at `8420`.
- Load-test graphs show behavior under a fixed 5-minute load.
- Stress-test graphs show behavior while virtual users increase over 5 minutes.

## Optional Public-IP Bonus Evidence

Public evidence is optional and does not replace the required local evidence.

| Bonus item | Packaged evidence | Source | Status | Explanation / note |
|---|---|---|---|---|
| Public Tomcat URL | `submission/public/public-tomcat-screenshot/` | Manual browser screenshot | ready | Screenshot was visually inspected and shows the public EC2 URL in the browser address bar. |
| Public monitor UI | `submission/public/public-monitoring-evidence/` | UptimeRobot and Jenkins screenshots | ready | Shows UptimeRobot monitoring the public Tomcat URL and Jenkins `meta-monitoring` evidence. |
| Public script check | `submission/public/public-jenkins-monitoring-check/` | `output/public-app/monitoring/`, `output/monitoring/` | ready | Script checks show `status=up` for the public URL. |
| Public Playwright | `submission/public/public-browser-test-passed-run/` | `output/public-app/playwright/` | ready | Packaged log shows `1 passed`; target is the public EC2 URL. |
| Public Gatling max-limit | `submission/public/public-gatling-max-limit/` | Jenkins public build `#225` | ready | Includes screenshot, run log, discovery log, HTML report, PDF, and graph explanation. |
| Public Gatling load 5m | `submission/public/public-gatling-load-5m/` | Jenkins public build `#225` | ready | Includes screenshot, run log, HTML report, PDF, and graph explanation. |
| Public Gatling stress 5m | `submission/public/public-gatling-stress-5m/` | Jenkins public build `#225` | ready | Includes screenshot, run log, HTML report, PDF, and graph explanation. |
| AWS cleanup | `submission/public/aws-cleanup-verification/` | Manual verification after review | deferred | Keep EC2 running through the review window; record cleanup after termination. |

### Public Gatling Results

Jenkins public build `#225` targeted:

`http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

Results:

- Public max-limit: `8060` virtual users passed with `KO=0`; `8080` was the first failing tested level with `KO=2`.
- Public load 5m: `2780 OK`, `0 KO`.
- Public stress 5m: `15592 OK`, `0 KO`.

## Final Checks Before Sending

- Open `https://github.com/y0ncha/meta-final-project` without authentication.
- Review `submission/local/i-har-file/meta-functional-flow.har` for cookies/session values before external sharing.
- Keep the EC2 instance running until the instructor confirms review, or for the next two weeks if confirmation does not arrive first.
- After review, record cleanup in `submission/public/aws-cleanup-verification/cleanup.md`.
