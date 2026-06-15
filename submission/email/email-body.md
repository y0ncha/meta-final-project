# Email Draft

To: `[assignment recipient email from final-project.pdf]`

Subject: `Final Exercise from: Yonatan Csasznik, Yoed Halberstam, Niv Levin`

## Body

Hello Moshe,

Attached are our 12 required submission items for the MTA 2026 Semester B DevOps final project.

Team members:

- Yonatan Csasznik
- Yoed Halberstam
- Niv Levin

Project links:

- Public GitHub repository: `https://github.com/y0ncha/meta-final-project`
- Local Tomcat evidence URL: `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Optional public-IP bonus URL: `http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

Required attached items:

1. JSP file used: `submission/local/a-jsp-file/index.jsp`
2. Screenshot of GitHub with the application/JSP: `submission/local/b-github-screenshot/github-jsp.png`
3. Screenshot of the application in Tomcat with the localhost URL visible: `submission/local/c-tomcat-local-screenshot/tomcat-local-url.png`
4. Public GitHub repository link: `https://github.com/y0ncha/meta-final-project`
5. Monitor evidence: `submission/local/e-monitoring-evidence/`
6. Browser automation test file: `submission/local/f-browser-test-file/meta-functional.spec.js`
7. Browser automation passed-run evidence and validation explanation: `submission/local/g-browser-test-passed-run/`
8. HAR scenario description: `submission/local/h-har-scenario/scenario-description.md`
9. HAR file: `submission/local/i-har-file/meta-functional-flow.har`
10. Gatling max-limit result and explanation: `submission/local/j-gatling-max-limit/max-limit-explanation.md`
11. Gatling CMD summary screenshots for max-limit, load, and stress: `submission/local/k-gatling-cmd-screenshots/`
12. Gatling result PDFs for max-limit, load, and stress, including graph explanations: `submission/local/l-gatling-result-pdfs/`

Browser automation note:

The assignment asks for Selenium IDE `.side` or similar browser automation. We used Playwright as the similar browser automation tool. The attached test file contains 5 validations, including positive and negative validation cases and both assert-style and verify-style checks. The passed-run evidence and validation explanation are attached under item 7.

HAR and Gatling note:

The HAR file records the browser scenario: open the application, submit a valid name, return to the form, and submit an empty name to verify validation behavior. Gatling HAR Converter was used as the reference for the Gatling scenario, and the maintained `MetaSimulation.scala` is the cleaned HAR-derived simulation used for repeatable max-limit, load, and stress runs.

Application max limit:

The tested local application max limit is `475 users/sec`.

This is the limit because Gatling's pass rule for this project is `KO=0`: a tested level passes only when Gatling reports zero failed requests, checks, or timeouts. The local max-limit run tested the Tomcat deployment from `250` to `550 users/sec` in `25 users/sec` steps. Each level ran for `10` seconds with a `1` second ramp.

`475 users/sec` was the highest tested level that still passed with `KO=0`. `500 users/sec` was the first tested level that failed. At `500 users/sec`, Gatling reported `3468` `KO` failures with `Address not available`, meaning the local Docker/Gatling networking path could no longer allocate or open enough client-side connections at that load. Therefore, the tested max limit is the previous passing level: `475 users/sec`.

Optional public-IP bonus evidence:

We also include optional public-IP bonus evidence under `submission/public/`. The public app URL is:

`http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`

The public max-limit evidence found `525 users/sec` as the highest passing tested level and `550 users/sec` as the first failing tested level. Public load and stress evidence were refreshed separately and completed with `0 KO`.

Regards,

Yonatan Csasznik, Yoed Halberstam, Niv Levin
