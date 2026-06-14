# Item J - Gatling Max-Limit Result

- Status: ready
- Assignment item: `j) Write in the email what is your app max limit, explain why this is the limit and how you found it`
- Packaged files: `max-limit-explanation.md`, `max-limit-discovery.log`
- Source: Jenkins `MeTA/meta-ci-cd` build `#260`, archived from `output/gatling/max-limit/`

The max-limit run found a local boundary: `8300` virtual users passed with `KO=0`, and the next tested level, `8350` virtual users, failed. Under the project rule, the app's local tested max limit is therefore `8300` virtual users for this Jenkins/Tomcat container setup.

The explanation requested by the assignment is in `max-limit-explanation.md`.

The Gatling graph report PDF for this max-limit run is packaged with the other Gatling PDFs under `../l-gatling-result-pdfs/max-limit-report.pdf`.
