# Email Draft

To: assignment recipient from `final-project.pdf`

Subject: `Final Exercise from: Yonatan Csasznik, Yoed Halberstam, Niv Levin`

## Body

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
10. Max-limit result and explanation: `submission/local/j-gatling-max-limit/` (`475 users/sec` passed; `500 users/sec` was the first failing tested level)
11. Gatling CMD summary screenshots: `submission/local/k-gatling-cmd-screenshots/`
12. Gatling result PDFs and graph explanations: `submission/local/l-gatling-result-pdfs/`

Browser automation note: the assignment names Selenium IDE `.side`; this project uses Playwright as the Selenium IDE or similar browser automation tool, with the test file and passed-run evidence attached.

Gatling/HAR note: the HAR records the browser scenario. Gatling HAR Converter generated a reference Scala simulation, and the maintained `MetaSimulation.scala` is the cleaned HAR-derived version used for repeatable max-limit, load, and stress runs. Gatling does not load the HAR file at runtime.

Max-limit note: Gatling tested the local Tomcat target from `250` to `550 users/sec` in `25 users/sec` steps. `475 users/sec` passed with `KO=0`; `500 users/sec` was the first failing tested level. The local failure was `Address not available`, meaning the local Docker/Gatling networking path could no longer allocate or open enough client-side connections at that load. Because Gatling counted those as `KO`, the local tested max limit is `475 users/sec`.

Optional public-IP bonus evidence, if submitted, is kept separately under `submission/public/` and uses:

`http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

Public Gatling bonus note: the refreshed public max-limit run found `525 users/sec` as the highest passing tested level and `550 users/sec` as the first failing tested level. Public load and stress evidence were not rerun in this max-limit-only refresh.

Regards,

Yonatan Csasznik, Yoed Halberstam, Niv Levin
