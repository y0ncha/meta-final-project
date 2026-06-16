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
10. Max-limit result and explanation: `submission/local/j-gatling-max-limit/max-limit-explanation.md`
11. Gatling CMD summary screenshots: `submission/local/k-gatling-cmd-screenshots/`
12. Gatling result PDFs and graph explanations: `submission/local/l-gatling-result-pdfs/`

Browser automation note: the assignment names Selenium IDE `.side`; this project uses Playwright as the Selenium IDE or similar browser automation tool. The Playwright test file and passed-run evidence are attached.

Gatling/HAR note: the HAR records the browser scenario. Gatling HAR Converter generated a reference Scala simulation, and the maintained `MetaSimulation.scala` is the cleaned HAR-derived version used for repeatable max-limit, load, and stress runs. Gatling does not load the HAR file at runtime. The current hard Gatling pass rule is `KO=0`.

Max-limit note: state the max-limit value as the active-users count at a `Number of responses per second` graph tooltip where `KO=0`, not as the configured users/sec generator level. The refreshed local evidence in `builds/max-limit-local/` supports `2340 active users` with `1399 OK` / `0 KO`. The refreshed public evidence in `builds/max-limit-public/` supports `6718 active users` with `301 OK` / `0 KO`.

Optional public-IP bonus evidence, if submitted, is kept separately under `submission/public/` and uses:

`http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

Public Gatling bonus note: the refreshed public max-limit graph screenshot supports `6718 active users` as the public max limit under `KO=0`. Public load and stress were refreshed from Jenkins build `#18` and both completed with `0 KO`.

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
| g | Browser automation passed-run screenshot and validation explanation | `submission/local/g-browser-test-passed-run/` | ready for screenshot/PDF export | Refreshed from Jenkins `MeTA/meta-container-ci-cd` build `#20`: includes run log, JUnit XML, native Playwright HTML report, Jenkins-safe HTML report, app screenshots, and `validation-explanation.md`. Export the final passed-report HTML to PDF before sending. |
| h | Written HAR scenario | `submission/local/h-har-scenario/scenario-description.md` | ready | Describes the browser scenario in words. |
| i | HAR file | `submission/local/i-har-file/meta-functional-flow.har` | packaged; sensitivity review recommended | HAR validation passed, but the file contains local `JSESSIONID` cookie evidence. Review before external sharing. |
| j | Max-limit result, why it is the limit, and how it was found | `submission/local/j-gatling-max-limit/` | ready | Local max-limit graph screenshot shows `2340 active users`, `1399 OK`, `0 KO`. |
| k | Three Gatling CMD summary screenshots | `submission/local/k-gatling-cmd-screenshots/` | ready for CMD evidence with max-limit graph note | The max-limit CMD screenshot is terminal summary evidence for a local max-limit run, but the submitted active-users value comes from the separate `Number of responses per second` graph screenshot. Load/stress screenshots are from local build `#17` and show `0 KO`. |
| l | Three Gatling result PDFs with graph explanations | `submission/local/l-gatling-result-pdfs/` | ready for max-limit PDF; load/stress caveat remains | The local max-limit PDF matches `builds/max-limit-local/max-limit-report.pdf`; matching local build `#17` load/stress graph PDFs were generated but not retained in Jenkins build artifacts. |

## Required Explanations

### Browser Validations

The browser automation evidence is packaged under `submission/local/g-browser-test-passed-run/` and the test source is `submission/local/f-browser-test-file/meta-functional.spec.js`.

Passed-run evidence:

- Native Playwright HTML report: `submission/local/g-browser-test-passed-run/playwright-run-report.html`
- Jenkins-safe Playwright HTML report: `submission/local/g-browser-test-passed-run/index.html`
- Console log: `submission/local/g-browser-test-passed-run/playwright-run.log`
- JUnit result: `submission/local/g-browser-test-passed-run/junit.xml`
- Screenshots: `submission/local/g-browser-test-passed-run/screenshots/valid-submit.png` and `submission/local/g-browser-test-passed-run/screenshots/empty-submit.png`
- Source build: Jenkins `MeTA/meta-container-ci-cd` build `#20`, targeting `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

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

The HAR was used as the recording/reference source for the Gatling scenario. Gatling runs the cleaned Scala simulation, not the HAR file directly.

### Local Gatling Max Limit

- Generator sweep: users/sec arrival rate
- Selection rule: `Number of responses per second` graph tooltip has `KO=0`
- Submission max-limit value: graph-selected active-users count from that zero-KO response tooltip
- Source checked: `builds/max-limit-local/`
- Tested range: `50` to `700 users/sec`, step `50 users/sec`, `10s/level`, `1s` ramp
- Report result: `201304` requests, `191872 OK`, `9432 KO`
- Failure type shown in the report: `Address not available` against `tomcat:8080`
- Graph-selected local max-limit response tooltip: `2340 active users`, `1399 OK`, `0 KO` at Tuesday, June 16, `04:17:15`; this is the highest active-users zero-KO response tooltip in the local report.

A failed run does not make the peak active-users count the max limit. The max limit is the selected active-users count from the `Number of responses per second` tooltip where `KO=0`.

### Local Gatling Graphs

The local graph explanations are packaged in `submission/local/l-gatling-result-pdfs/graph-explanations.md`.

- Max-limit PDF and graph screenshot evidence was refreshed from `builds/max-limit-local/`; the selected response tooltip shows `2340 active users`, `1399 OK`, and `0 KO`.
- Local build `#17` load screenshot shows `4800 OK` / `0 KO` at `5 users/sec`, p95 `13 ms`; the matching graph PDF was not retained.
- Local build `#17` stress screenshot shows `33120 OK` / `0 KO` at `5-50 users/sec`, p95 `8 ms`; the matching graph PDF was not retained.

### Gatling SLA Recommendations

| Area | Recommended value | Evidence basis |
|---|---|---|
| Max-limit selection | `KO=0` on the `Number of responses per second` tooltip | The submitted active-users value must come from a graph point whose response tooltip shows zero KOs. |
| Load latency | report p95 as observed evidence | The refreshed max-limit run is failure-discovery evidence, not a clean latency-SLA source. |
| Load profile | current packaged load evidence remains at `5 users/sec` | Do not derive a refreshed load target from the max-limit failure-discovery run. |
| Stress profile | current packaged stress evidence remains at `5-50 users/sec` | Do not derive a refreshed stress target from the max-limit failure-discovery run. |
| Max-limit confirmation | targeted users/sec sweep around the expected failure region | State the result as the active-users count at the zero-KO response tooltip, not as the users/sec generator setting. |

## Optional Public-IP Bonus Evidence

Public evidence is optional and does not replace the required local evidence.

| Bonus item | Packaged evidence | Source | Status | Explanation / note |
|---|---|---|---|---|
| Public Tomcat URL | `submission/public/public-tomcat-screenshot/` | Manual browser screenshot | ready | Screenshot was visually inspected and shows the public EC2 URL in the browser address bar. |
| Public monitor UI | `submission/public/public-monitoring-evidence/` | UptimeRobot and Jenkins screenshots | ready | Shows UptimeRobot monitoring the public Tomcat URL and Jenkins `meta-monitoring` evidence. |
| Public script check | `submission/public/public-jenkins-monitoring-check/` | `output/public-app/monitoring/`, `output/monitoring/` | ready | Script checks show `status=up` for the public URL. |
| Public Playwright | `submission/public/public-browser-test-passed-run/` | Public-target Jenkins artifacts | ready for screenshot/PDF capture | Packaged log shows `1 passed`; target is the public EC2 URL. Includes native and Jenkins-safe HTML reports. |
| Public Gatling max-limit | `submission/public/public-gatling-max-limit/` | `builds/max-limit-public/` | ready | Graph screenshot shows `6718 active users`, `301 OK`, `0 KO`. |
| Public Gatling load 5m | `submission/public/public-gatling-load-5m/` | Public-target Jenkins build `#18` | ready | Screenshot and PDF match the refreshed public run: `4800 OK`, `0 KO`, p95 `58 ms`. |
| Public Gatling stress 5m | `submission/public/public-gatling-stress-5m/` | Public-target Jenkins build `#18` | ready | Screenshot and PDF match the refreshed public run: `33120 OK`, `0 KO`, p95 `67 ms`. |
| AWS cleanup | `submission/public/aws-cleanup-verification/` | Manual verification after review | deferred | Keep EC2 running through the review window; record cleanup after termination. |

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
