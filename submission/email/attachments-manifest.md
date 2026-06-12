# Attachments Manifest

## Required Local Evidence

| Item | File | Source | Status | Freshness Check | Notes |
|---|---|---|---|---|---|
| a | `submission/local/a-jsp-file/index.jsp` | `src/main/webapp/index.jsp` | ready | `cmp src/main/webapp/index.jsp submission/local/a-jsp-file/index.jsp` | JSP source file. |
| b | `submission/local/b-github-screenshot/github-jsp.png` | archived prior screenshot | ready | visually inspected | Shows GitHub repo and `src/main/webapp/index.jsp`; recapture after final push if needed. |
| c | `submission/local/c-tomcat-local-screenshot/tomcat-local-url.png` | archived prior screenshot | ready | visually inspected | Shows localhost URL in browser bar. |
| d | `submission/local/d-github-public-link/github-public-repo.link` | archived prior link | partial | open without authentication | Link packaged; public accessibility check still manual. |
| e | `submission/local/e-monitoring-evidence/` | Jenkins `meta-monitoring` screenshots | ready | visually inspect build history and timer-started console screenshot | Includes build history and timer-started clean console success screenshots for the local monitor. |
| f | `submission/local/f-browser-test-file/meta-functional.spec.js` | `tests/playwright/meta-functional.spec.js` | ready with override risk | compare with source | Playwright substitute for Selenium IDE `.side`. |
| g | `submission/local/g-browser-test-passed-run/` | `output/playwright/` | ready | log contains `1 passed` | Includes log, JUnit, screenshots, report, explanation. |
| h | `submission/local/h-har-scenario/scenario-description.md` | `docs/har-scenario.md` | ready | review text | Written HAR scenario. |
| i | `submission/local/i-har-file/meta-functional-flow.har` | `output/har/meta-functional-flow.har` | partial | validate and sensitivity-review HAR | HAR packaged; review before sending. |
| j | `submission/local/j-gatling-max-limit/` | `output/gatling/max-limit/` | partial | inspect max-limit log/report | Current result is a tested lower bound, not a proven true maximum. |
| k | `submission/local/k-gatling-cmd-screenshots/` | manual capture required | partial | add `max-limit-terminal.png` and `load-5m-terminal.png` | Stress CMD screenshot is packaged; max-limit and load screenshots are still missing. |
| l | `submission/local/l-gatling-result-pdfs/` | `output/gatling/` | ready | verify three PDFs open | Includes three PDFs and graph explanations. |

## Optional Public-IP Bonus Evidence

| Item | File | Source | Status | Freshness Check | Notes |
|---|---|---|---|---|---|
| Public Tomcat | `submission/public/public-tomcat-screenshot/` | manual browser screenshot | ready | visually inspect screenshot shows public URL | Includes fresh public Tomcat screenshot and public URL support file. |
| Public monitor UI | `submission/public/public-monitoring-evidence/` | UptimeRobot and Jenkins screenshots | ready | visually inspect UptimeRobot, build history, and public timer-started console screenshot | Required for bonus. |
| Public script check | `submission/public/public-jenkins-monitoring-check/` | `output/public-app/monitoring/`, `output/monitoring/` | ready | target must match public URL | Script checks show `status=up`; public Jenkins console screenshot is packaged with monitor UI evidence. |
| Public Playwright | `submission/public/public-browser-test-passed-run/` | `output/public-app/playwright/` | ready | log contains `1 passed` | Re-check target before claiming bonus. |
| Public Gatling max | `submission/public/public-gatling-max-limit/` | user-run required | missing | run approved public-target flow | Agent must not run Gatling directly. |
| Public Gatling load | `submission/public/public-gatling-load-5m/` | user-run required | missing | run approved public-target flow | Agent must not run Gatling directly. |
| Public Gatling stress | `submission/public/public-gatling-stress-5m/` | user-run required | missing | run approved public-target flow | Agent must not run Gatling directly. |
| AWS cleanup | `submission/public/aws-cleanup-verification/` | manual verification later | deferred | keep EC2 running until instructor confirms review or for the next two weeks | Do not terminate now; cleanup is intentionally delayed to preserve public bonus access. |
