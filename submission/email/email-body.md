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
10. Max-limit result and explanation: `submission/local/j-gatling-max-limit/` (`8440` virtual users passed; `8460` was the first failing tested level)
11. Gatling CMD summary screenshots: `submission/local/k-gatling-cmd-screenshots/`
12. Gatling result PDFs and graph explanations: `submission/local/l-gatling-result-pdfs/`

Browser automation note: the assignment names Selenium IDE `.side`; this project uses Playwright as the Selenium IDE or similar browser automation tool, with the test file and passed-run evidence attached.

Gatling/HAR note: the HAR records the browser scenario. Gatling HAR Converter generated a reference Scala simulation, and the maintained `MetaSimulation.scala` is the cleaned HAR-derived version used for repeatable max-limit, load, and stress runs. Gatling does not load the HAR file at runtime.

Max-limit note: Gatling tested the local Tomcat target from `8100` to `12000` virtual users in `20`-user steps. `8440` passed with `KO=0`; `8460` failed with `33` connection-timeout errors. Under the project rule, the local tested max limit is `8440` virtual users.

Optional public-IP bonus evidence, if submitted, is kept separately under `submission/public/` and uses:

`http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

Public Gatling bonus note: the public-target Gatling evidence shows `8280` virtual users passed and `8300` was the first failing tested level; public load and stress evidence both completed with `0 KO`.

Regards,

Yonatan Csasznik, Yoed Halberstam, Niv Levin
