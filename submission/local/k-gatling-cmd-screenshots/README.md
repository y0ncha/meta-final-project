# Item K - Gatling CMD Screenshots

- Status: ready
- Assignment item: `k) Attach 3 screenshots of: max limit, load and stress gatling run summary (screenshot of the CMD)`
- Packaged files: `gatling-max-limit-test.png`, `gatling-load-test.png`, `gatling-stress-test.png`
- Source: user-captured Jenkins console screenshots; max-limit is terminal summary evidence for a local max-limit run, load/stress are from local build `#17`

Validated visually: all three screenshots show command context and Gatling `Global Information` summary. The load/stress screenshots show local build `#17` targeting `tomcat:8080` with `0 KO`.

The max-limit CMD screenshot targets `tomcat:8080`, shows `201835` requests, `192580 OK`, `9255 KO`, and a `50-700 users/sec` generator sweep. It is valid terminal-summary evidence for item `k`, but it is not the source for the submitted active-users max-limit value. The active-users max-limit value is proven by the separate `Number of responses per second` graph screenshot packaged under item `j`.
