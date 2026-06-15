# Item J - Gatling Max-Limit Result

- Status: pending users/sec refresh
- Assignment item: `j) Write in the email what is your app max limit, explain why this is the limit and how you found it`
- Packaged files: `max-limit-explanation.md`, `max-limit-discovery.log`
- Source: refresh with Jenkins after the users/sec max-limit refactor

The previous packaged max-limit boundary was measured with concurrent virtual-user levels. The implementation now measures max-limit as users/sec arrival rate, so this item must be refreshed before submission.

After the refresh, record:

- the tested users/sec range
- the step size in users/sec
- the highest tested users/sec level with `KO=0`
- the first tested users/sec level with `KO>0`

The explanation requested by the assignment is in `max-limit-explanation.md`.

The Gatling graph report PDF for this max-limit run is packaged with the other Gatling PDFs under `../l-gatling-result-pdfs/max-limit-report.pdf`.
