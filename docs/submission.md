# Final Project Submission Package

This is the central reference for the final email, required attachments, explanations, and optional public-IP bonus evidence.

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

Attached is `final-project-submission-2026-06-16.zip`, which contains our 12 required submission items for the MTA 2026 Semester B DevOps final project, plus the optional public-IP bonus evidence.

Team members:

- Yonatan Csasznik
- Yoed Halberstam
- Niv Levin

Project links:

- Public GitHub repository: `https://github.com/y0ncha/meta-final-project`
- Local Tomcat evidence URL: `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Optional public-IP bonus URL: `http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

Submission items:

a) JSP: `submission/local/a-jsp-file/index.jsp`

b) GitHub screenshot: `submission/local/b-github-screenshot/github-jsp.png`

c) Local Tomcat screenshot: `submission/local/c-tomcat-local-screenshot/tomcat-local-url.png`

d) Public GitHub repository: `https://github.com/y0ncha/meta-final-project`

e) Monitoring: we used Jenkins scheduled job `meta-monitoring` to monitor the Tomcat application URL. Passed monitor evidence is attached under `submission/local/e-monitoring-evidence/`.

f) Browser automation file: `submission/local/f-browser-test-file/meta-functional.spec.js`. We used Playwright as the Selenium IDE or similar browser automation tool.

g) Browser automation passed run: `submission/local/g-browser-test-passed-run/`

Five validations used:
- Positive strict assert: the page title confirms the browser reached the MeTA application, so later checks are not run against the wrong page.
- Positive soft verify: the About section confirms supporting page content exists, but the test continues so the form flow can still be checked if only this secondary content changes.
- Positive strict assert: submitting a valid name must show the expected success message, because accepting valid input is core application behavior.
- Negative soft verify: submitting an empty name must not show the positive success result; this is kept soft so the test can continue to the explicit validation-message check.
- Negative strict assert: submitting an empty name must show the expected validation message, because rejecting invalid input is core application behavior.

We used strict assert checks where a failure makes the rest of the flow unreliable or proves a core behavior is broken. We used soft verify checks where continuing the run gives better diagnostic evidence while still failing the test if the soft check fails.

For the detailed validation table and rationale, see `submission/local/g-browser-test-passed-run/validation-explanation.md`.

h) HAR scenario: open app -> click About -> type Yonatan -> click Submit -> see success -> reload -> click Submit empty -> see validation error. Written scenario file: `submission/local/h-har-scenario/scenario-description.md`

i) HAR file: `submission/local/i-har-file/meta-functional-flow.har`

j) Max limit: the tested local application max limit is `2340 active users` with `KO=0`.

This is the limit because the selected Gatling `Number of responses per second` graph tooltip shows `2340 active users`, `1399 OK`, and `0 KO`. The max-limit run used a users/sec generator sweep to push the system, but the submitted max-limit value is the active-users graph point where the response tooltip still has zero failures, not the generator users/sec setting.

After that selected point, failures appear in the report. The local run ended with `201304` requests, `191872 OK`, and `9432 KO`, with `Address not available` against `tomcat:8080`. That shows the test passed beyond the clean operating boundary, so the defended local max limit is the selected zero-KO point: `2340 active users`.

Max-limit evidence: `submission/local/j-gatling-max-limit/`

k) Gatling CMD summary screenshots: `submission/local/k-gatling-cmd-screenshots/`

l) Gatling result PDFs and graph explanations: `submission/local/l-gatling-result-pdfs/`

Results explanation:
- Max limit: the run intentionally pushed past the clean operating range. The selected clean point is `2340 active users`, `1399 OK`, and `0 KO`; later failures and slower response times show local Docker/Jenkins/Gatling/Tomcat connection exhaustion under extreme load, not a JSP logic failure.
- Load 5m: the run completed cleanly with `4800 OK`, `0 KO`, p95 `13 ms`, and max `81 ms`, so the normal `5 users/sec` profile is comfortably inside capacity.
- Stress 5m: the run completed cleanly with `33120 OK`, `0 KO`, p95 `8 ms`, and max `396 ms`. The higher max response time is expected under more traffic, while zero KO shows this stress range did not break the system.

bonus) Public-IP bonus: evidence is attached under `submission/public/`. The public app URL is:

`http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

The public max-limit graph screenshot shows `6718 active users`, `301 OK`, and `0 KO` at the selected response tooltip. Public load and stress evidence were refreshed separately and completed with `0 KO`.

Regards,

Yonatan Csasznik, Yoed Halberstam, Niv Levin

## Required Attachments

These are the 12 items requested by `docs/final-project.txt`.

| Item | Required by assignment | Packaged evidence | Status | Explanation / note |
|---|---|---|---|---|
| a | JSP file used | `submission/local/a-jsp-file/index.jsp` | ready | JSP copied from `src/main/webapp/index.jsp`. |
| b | Screenshot of GitHub with the application/JSP | `submission/local/b-github-screenshot/github-jsp.png` | ready | Shows the GitHub repository and `src/main/webapp/index.jsp`. |
| c | Screenshot of the app in Tomcat with `localhost:8080/...` visible | `submission/local/c-tomcat-local-screenshot/tomcat-local-url.png` | ready | Shows browser chrome and the local Tomcat URL. |
| d | Link to public GitHub repo | `submission/local/d-github-public-link/github-public-repo.link` | ready, final browser check recommended | Link file contains `https://github.com/y0ncha/meta-final-project`; open once without authentication before sending. |
| e | Monitor tool name, monitored target, and passed monitor screenshot | `submission/local/e-monitoring-evidence/` | ready | Jenkins `meta-monitoring` screenshots show scheduled monitoring evidence. Public UptimeRobot bonus evidence is under `submission/public/public-monitoring-evidence/`. |
| f | Selenium IDE file `.side` | `submission/local/f-browser-test-file/meta-functional.spec.js` | ready with approved substitute risk | The project uses Playwright as the browser automation substitute; keep the substitution note in the email. |
| g | Browser automation passed-run screenshot and validation explanation | `submission/local/g-browser-test-passed-run/` | ready for screenshot/PDF export | Refreshed from Jenkins `MeTA/meta-container-ci-cd` build `#20`: includes run log, JUnit XML, native Playwright HTML report, Jenkins-safe HTML report, app screenshots, and `validation-explanation.md`. Export the final passed-report HTML to PDF before sending. |
| h | Written HAR scenario | `submission/local/h-har-scenario/scenario-description.md` | ready | Describes the browser scenario in words. |
| i | HAR file | `submission/local/i-har-file/meta-functional-flow.har` | packaged; sensitivity review recommended | HAR validation passed, but the file contains local `JSESSIONID` cookie evidence. Review before external sharing. |
| j | Max-limit result, why it is the limit, and how it was found | `submission/local/j-gatling-max-limit/` | ready | Local max-limit graph screenshot shows `2340 active users`, `1399 OK`, `0 KO`. |
| k | Three Gatling CMD summary screenshots | `submission/local/k-gatling-cmd-screenshots/` | ready for CMD evidence with max-limit graph note | The max-limit CMD screenshot is terminal summary evidence for a local max-limit run, but the submitted active-users value comes from the separate `Number of responses per second` graph screenshot. Load/stress screenshots are from local build `#17` and show `0 KO`. |
| l | Three Gatling result PDFs with graph explanations | `submission/local/l-gatling-result-pdfs/` | needs final load/stress PDF refresh | Export/print the intended Gatling `index.html` files to PDF immediately after each run, because Jenkins reuses `output/gatling/` and later runs can overwrite earlier reports. |

## Required Explanations

### Browser Validations

The browser automation evidence is packaged under `submission/local/g-browser-test-passed-run/`, and the test file is `submission/local/f-browser-test-file/meta-functional.spec.js`.

Passed-run evidence:

- Native Playwright HTML report: `submission/local/g-browser-test-passed-run/playwright-run-report.html`
- Jenkins-safe Playwright HTML report: `submission/local/g-browser-test-passed-run/index.html`
- Console log: `submission/local/g-browser-test-passed-run/playwright-run.log`
- JUnit result: `submission/local/g-browser-test-passed-run/junit.xml`
- Screenshots: `submission/local/g-browser-test-passed-run/screenshots/valid-submit.png` and `submission/local/g-browser-test-passed-run/screenshots/empty-submit.png`
- Jenkins build: `MeTA/meta-container-ci-cd` build `#20`, targeting `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

Validation types used:

- Positive strict assert: app identity/title.
- Positive soft verify: supporting About content.
- Positive strict assert: valid-name submit returns the expected success message.
- Negative soft verify: empty submit does not show the positive success message.
- Negative strict assert: empty-submit validation text is shown.

### HAR Scenario

The written HAR scenario is `submission/local/h-har-scenario/scenario-description.md`, and the HAR file is `submission/local/i-har-file/meta-functional-flow.har`.

Scenario summary:

1. Open the MeTA app.
2. Submit a valid name.
3. Return to the form.
4. Submit an empty name to trigger validation.

The HAR was used as the recording/reference for the Gatling scenario. Gatling runs the cleaned Scala simulation, not the HAR file directly.

### Local Gatling Max Limit

- Generator sweep: users/sec arrival rate
- Selection rule: `Number of responses per second` graph tooltip has `KO=0`
- Submission max-limit value: graph-selected active-users count from that zero-KO response tooltip
- Evidence checked: `builds/max-limit-local/`
- Tested range: `50` to `700 users/sec`, step `50 users/sec`, `10s/level`, `1s` ramp
- Report result: `201304` requests, `191872 OK`, `9432 KO`
- Failure type shown in the report: `Address not available` against `tomcat:8080`
- Graph-selected local max-limit response tooltip: `2340 active users`, `1399 OK`, `0 KO` at Tuesday, June 16, `04:17:15`; this is the highest active-users zero-KO response tooltip in the local report.

A failed run does not make the peak active-users count the max limit. The max limit is the selected active-users count from the `Number of responses per second` tooltip where `KO=0`.

### Local Gatling Graphs

The local graph explanations are packaged in `submission/local/l-gatling-result-pdfs/graph-explanations.md`.

- Max-limit PDF and graph screenshot evidence was refreshed from `builds/max-limit-local/`; the selected response tooltip shows `2340 active users`, `1399 OK`, and `0 KO`.
- Load PDF: export from the intended load `index.html` before another Gatling run overwrites the shared workspace.
- Stress PDF: export from the intended stress `index.html` before another Gatling run overwrites the shared workspace.

### Gatling SLA Recommendations

| Area | Recommended value | Evidence basis |
|---|---|---|
| Max-limit selection | `KO=0` on the `Number of responses per second` tooltip | The submitted active-users value must come from a graph point whose response tooltip shows zero KOs. |
| Load latency | report p95 as observed evidence | The refreshed max-limit run is failure-discovery evidence, not a clean latency-SLA baseline. |
| Load profile | current packaged load evidence remains at `5 users/sec` | Do not derive a refreshed load target from the max-limit failure-discovery run. |
| Stress profile | current packaged stress evidence remains at `5-50 users/sec` | Do not derive a refreshed stress target from the max-limit failure-discovery run. |
| Max-limit confirmation | targeted users/sec sweep around the expected failure region | State the result as the active-users count at the zero-KO response tooltip, not as the users/sec generator setting. |

## Optional Public-IP Bonus Evidence

Public evidence is optional and does not replace the required local evidence.

| Bonus item | Packaged evidence | Status | Explanation / note |
|---|---|---|---|
| Public Tomcat URL | `submission/public/public-tomcat-screenshot/` | ready | Screenshot was visually inspected and shows the public EC2 URL in the browser address bar. |
| Public monitor UI | `submission/public/public-monitoring-evidence/` | ready | Shows UptimeRobot monitoring the public Tomcat URL and Jenkins `meta-monitoring` evidence. |
| Public script check | `submission/public/public-jenkins-monitoring-check/` | ready | Script checks show `status=up` for the public URL. |
| Public Playwright | `submission/public/public-browser-test-passed-run/` | ready for screenshot/PDF capture | Packaged log shows `1 passed`; target is the public EC2 URL. Includes native and Jenkins-safe HTML reports. |
| Public Gatling max-limit | `submission/public/public-gatling-max-limit/` | ready | Graph screenshot shows `6718 active users`, `301 OK`, `0 KO`. |
| Public Gatling load 5m | `submission/public/public-gatling-load-5m/` | ready | Screenshot and PDF match the refreshed public run: `4800 OK`, `0 KO`, p95 `58 ms`. |
| Public Gatling stress 5m | `submission/public/public-gatling-stress-5m/` | ready | Screenshot and PDF match the refreshed public run: `33120 OK`, `0 KO`, p95 `67 ms`. |
| AWS cleanup | `submission/public/aws-cleanup-verification/` | deferred | Keep EC2 running through the review window; record cleanup after termination. |

### Public Gatling Results

The public-target Gatling run targeted:

`http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

Results:

- Public max-limit: `builds/max-limit-public/` graph screenshot supports `6718 active users`, `301 OK`, `0 KO`.
- Public load 5m: build `#18`, `5 users/sec`, `4800 OK`, `0 KO`, p95 `58 ms`.
- Public stress 5m: build `#18`, `5-50 users/sec`, `33120 OK`, `0 KO`, p95 `67 ms`.

## Final Checks Before Sending

- Open `https://github.com/y0ncha/meta-final-project` without authentication.
- Review `submission/local/i-har-file/meta-functional-flow.har` for cookies/session values before external sharing.
- Keep the EC2 instance running until the instructor confirms review, or for the next two weeks if confirmation does not arrive first.
- After review, record cleanup in `submission/public/aws-cleanup-verification/cleanup.md`.
