# Item K - Gatling CMD Screenshots

- Status: ready
- Assignment item: `k) Attach 3 screenshots of: max limit, load and stress gatling run summary (screenshot of the CMD)`
- Packaged files: `gatling-max-limit-test.png`, `gatling-load-test.png`, `gatling-stress-test.png`
- Source: user-captured Jenkins console screenshots; max-limit is from local build `#12`, load/stress are from local build `#17`

Validated visually: all three screenshots show the command context and Gatling `Global Information` summary for the matching run type. The load/stress screenshots show local build `#17` targeting `tomcat:8080` with `0 KO`. The max-limit screenshot also shows the `475 users/sec` passing / `500 users/sec` failing boundary.
