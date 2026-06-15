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
10. Max-limit result and explanation: `submission/local/j-gatling-max-limit/max-limit-explanation.md` (`475 users/sec` passed; `500 users/sec` was the first failing tested level)
11. Gatling CMD summary screenshots: `submission/local/k-gatling-cmd-screenshots/`
12. Gatling result PDFs and graph explanations: `submission/local/l-gatling-result-pdfs/`

Browser automation note: the assignment names Selenium IDE `.side`; this project uses Playwright as the Selenium IDE or similar browser automation tool. The Playwright test file and passed-run evidence are attached.

Gatling/HAR note: the HAR records the browser scenario. Gatling HAR Converter generated a reference Scala simulation, and the maintained `MetaSimulation.scala` is the cleaned HAR-derived version used for repeatable max-limit, load, and stress runs. Gatling does not load the HAR file at runtime.

Max-limit note: the local max-limit evidence uses users/sec arrival-rate levels from Jenkins build `#12`. `475 users/sec` passed with `KO=0`; `500 users/sec` was the first failing tested level. The local failure was `Address not available`, meaning the local Docker/Gatling networking path could no longer allocate or open enough client-side connections at that load. Because Gatling counted those failures as `KO`, the local tested max limit is `475 users/sec`.

Optional public-IP bonus evidence, if submitted, is kept separately under `submission/public/` and uses:

`http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

Public Gatling bonus note: the refreshed public max-limit run from Jenkins build `#13` found `525 users/sec` as the highest passing tested level and `550 users/sec` as the first failing tested level. Public load and stress evidence were not rerun in this max-limit-only refresh.

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
| g | Browser automation passed-run screenshot and validation explanation | `submission/local/g-browser-test-passed-run/` | ready for screenshot/PDF capture | Includes run log, native Playwright HTML report, Jenkins-safe HTML report, app screenshots, and `validation-explanation.md`. Capture the final passed-report screenshot/PDF from the HTML report before sending. |
| h | Written HAR scenario | `submission/local/h-har-scenario/scenario-description.md` | ready | Describes the browser scenario in words. |
| i | HAR file | `submission/local/i-har-file/meta-functional-flow.har` | packaged; sensitivity review recommended | HAR validation passed, but the file contains local `JSESSIONID` cookie evidence. Review before external sharing. |
| j | Max-limit result, why it is the limit, and how it was found | `submission/local/j-gatling-max-limit/` | ready | Local build `#12`: `475 users/sec` passed, `500 users/sec` first failed under `KO=0`. |
| k | Three Gatling CMD summary screenshots | `submission/local/k-gatling-cmd-screenshots/` | ready | Contains max-limit, load, and stress summary screenshots. |
| l | Three Gatling result PDFs with graph explanations | `submission/local/l-gatling-result-pdfs/` | ready | Contains max-limit, load, and stress PDFs plus `graph-explanations.md`. |

## Required Explanations

### Browser Validations

The browser automation evidence is packaged under `submission/local/g-browser-test-passed-run/` and the test source is `submission/local/f-browser-test-file/meta-functional.spec.js`.

Passed-run evidence:

- Native Playwright HTML report: `submission/local/g-browser-test-passed-run/playwright-run-report.html`
- Jenkins-safe Playwright HTML report: `submission/local/g-browser-test-passed-run/index.html`
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

- Workload knob: users/sec arrival rate
- Passing rule: `KO=0`
- Source: Jenkins `MeTA/meta-container-ci-cd` build `#12`
- Tested range: `250` to `550 users/sec`, step `25 users/sec`, `10s/level`, `1s` ramp
- Result: `475 users/sec` is the highest tested level with `KO=0`
- Boundary: `500 users/sec` is the first tested level with `KO>0`
- Failure type: `Address not available` against `tomcat:8080`

A failed tested level is not the max limit. The max limit is the previous tested level that still had `KO=0`.

### Local Gatling Graphs

The local graph explanations are packaged in `submission/local/l-gatling-result-pdfs/graph-explanations.md`.

- Max-limit graphs were refreshed from build `#12` and show the users/sec arrival-rate staircase plus the updated `KO=0` boundary.
- Load-test graphs must be refreshed after the users/sec profile change; the previous `2336 OK` / `0 KO` run used the older concurrent-user profile.
- Stress-test graphs must be refreshed after the users/sec profile change; the previous `15892 OK` / `0 KO` run used the older concurrent-user profile.

## Optional Public-IP Bonus Evidence

Public evidence is optional and does not replace the required local evidence.

| Bonus item | Packaged evidence | Source | Status | Explanation / note |
|---|---|---|---|---|
| Public Tomcat URL | `submission/public/public-tomcat-screenshot/` | Manual browser screenshot | ready | Screenshot was visually inspected and shows the public EC2 URL in the browser address bar. |
| Public monitor UI | `submission/public/public-monitoring-evidence/` | UptimeRobot and Jenkins screenshots | ready | Shows UptimeRobot monitoring the public Tomcat URL and Jenkins `meta-monitoring` evidence. |
| Public script check | `submission/public/public-jenkins-monitoring-check/` | `output/public-app/monitoring/`, `output/monitoring/` | ready | Script checks show `status=up` for the public URL. |
| Public Playwright | `submission/public/public-browser-test-passed-run/` | Public-target Jenkins artifacts | ready for screenshot/PDF capture | Packaged log shows `1 passed`; target is the public EC2 URL. Includes native and Jenkins-safe HTML reports. |
| Public Gatling max-limit | `submission/public/public-gatling-max-limit/` | Public-target Jenkins build `#13` | ready | Includes screenshot, PDF report, and graph explanation. `525 users/sec` passed; `550 users/sec` first failed. |
| Public Gatling load 5m | `submission/public/public-gatling-load-5m/` | Public-target Jenkins artifacts | stale after profile change | Refresh after the users/sec load-profile change before submitting as current public evidence. |
| Public Gatling stress 5m | `submission/public/public-gatling-stress-5m/` | Public-target Jenkins artifacts | stale after profile change | Refresh after the users/sec stress-profile change before submitting as current public evidence. |
| AWS cleanup | `submission/public/aws-cleanup-verification/` | Manual verification after review | deferred | Keep EC2 running through the review window; record cleanup after termination. |

### Public Gatling Results

The public-target Gatling run targeted:

`http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

Results:

- Public max-limit: build `#13` found `525 users/sec` as the highest passing tested level and `550 users/sec` as the first failing tested level.
- Public load 5m: refresh after the users/sec load-profile change before claiming current public evidence.
- Public stress 5m: refresh after the users/sec stress-profile change before claiming current public evidence.

## Final Checks Before Sending

- Open `https://github.com/y0ncha/meta-final-project` without authentication.
- Review `submission/local/i-har-file/meta-functional-flow.har` for cookies/session values before external sharing.
- Keep the EC2 instance running until the instructor confirms review, or for the next two weeks if confirmation does not arrive first.
- After review, record cleanup in `submission/public/aws-cleanup-verification/cleanup.md`.
