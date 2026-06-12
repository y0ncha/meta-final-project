# Attachments Manifest

## Required Local Evidence

| Item | File | Source | Status | Freshness Check | Notes |
|---|---|---|---|---|---|
| a | `submission/local/a-jsp-file/index.jsp` | `src/main/webapp/index.jsp` | ready | `cmp src/main/webapp/index.jsp submission/local/a-jsp-file/index.jsp` | JSP source file. |
| b | `submission/local/b-github-screenshot/github-jsp.png` | archived prior screenshot | ready | visually inspected | Shows GitHub repo and `src/main/webapp/index.jsp`; recapture after final push if needed. |
| c | `submission/local/c-tomcat-local-screenshot/tomcat-local-url.png` | archived prior screenshot | ready | visually inspected | Shows localhost URL in browser bar. |
| d | `submission/local/d-github-public-link/github-public-repo.link` | archived prior link | partial | open without authentication | Link packaged; public accessibility check still manual. |
| e | `submission/local/e-monitoring-evidence/` | manual capture required | missing | capture monitor UI and final `meta-monitoring` evidence | Official monitor screenshot is missing. |
| f | `submission/local/f-browser-test-file/meta-functional.spec.js` | `tests/playwright/meta-functional.spec.js` | ready with override risk | compare with source | Playwright substitute for Selenium IDE `.side`. |
| g | `submission/local/g-browser-test-passed-run/` | `output/playwright/` | ready | log contains `1 passed` | Includes log, JUnit, screenshots, report, explanation. |
| h | `submission/local/h-har-scenario/scenario-description.md` | `docs/har-scenario.md` | ready | review text | Written HAR scenario. |
| i | `submission/local/i-har-file/meta-functional-flow.har` | `output/har/meta-functional-flow.har` | partial | validate and sensitivity-review HAR | HAR packaged; review before sending. |
| j | `submission/local/j-gatling-max-limit/` | `output/gatling/max-limit/` | partial | inspect max-limit log/report | Current result is a tested lower bound, not a proven true maximum. |
| k | `submission/local/k-gatling-cmd-screenshots/` | manual capture required | missing | add all three PNG screenshots | Required CMD/terminal screenshots are missing. |
| l | `submission/local/l-gatling-result-pdfs/` | `output/gatling/` | ready | verify three PDFs open | Includes three PDFs and graph explanations. |

## Optional Public-IP Bonus Evidence

| Item | File | Source | Status | Freshness Check | Notes |
|---|---|---|---|---|---|
| Public Tomcat | `submission/public/public-tomcat-screenshot/` | manual capture required | missing | screenshot must show public URL | Public URL text file is packaged only as support. |
| Public monitor UI | `submission/public/public-monitoring-evidence/` | manual capture required | missing | UptimeRobot or approved UI screenshot | Required for bonus. |
| Public script check | `submission/public/public-jenkins-monitoring-check/` | `output/public-app/monitoring/`, `output/monitoring/` | partial | target must match public URL | Script checks show `status=up`. |
| Public Playwright | `submission/public/public-browser-test-passed-run/` | `output/public-app/playwright/` | ready | log contains `1 passed` | Re-check target before claiming bonus. |
| Public Gatling max | `submission/public/public-gatling-max-limit/` | user-run required | missing | run approved public-target flow | Agent must not run Gatling directly. |
| Public Gatling load | `submission/public/public-gatling-load-5m/` | user-run required | missing | run approved public-target flow | Agent must not run Gatling directly. |
| Public Gatling stress | `submission/public/public-gatling-stress-5m/` | user-run required | missing | run approved public-target flow | Agent must not run Gatling directly. |
| AWS cleanup | `submission/public/aws-cleanup-verification/` | manual verification required | missing | terminate/release/check resources | Required before closing bonus evidence window. |
