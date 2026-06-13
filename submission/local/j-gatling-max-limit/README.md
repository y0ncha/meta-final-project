# Item J - Gatling Max-Limit Result

- Status: ready
- Assignment item: `j) Write in the email what is your app max limit, explain why this is the limit and how you found it`
- Packaged files: `email-max-limit-text.md`, `max-limit-run.log`, `max-limit-discovery.log`
- Source: Jenkins local build `#224`, archived from `output/gatling/max-limit/`

Build `#224` found a local max-limit boundary: `8400` virtual users passed with `KO=0`, and the next tested level, `8420` virtual users, failed with `61` connection-timeout errors. Under the project rule, the app's local tested max limit is therefore `8400` virtual users for this Jenkins/Tomcat container setup.

The email-ready text requested by the assignment is in `email-max-limit-text.md`.

The Gatling graph report PDF for this max-limit run is packaged with the other Gatling PDFs under `../l-gatling-result-pdfs/max-limit-report.pdf`.
