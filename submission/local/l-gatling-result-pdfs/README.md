# Item L - Gatling Result PDFs

- Status: ready with caveat
- Assignment item: `l) Attach 3 PDFs (max limit, load and stress) with Gatling results/graphs, explain why the results look this way`
- Packaged PDFs: `max-limit-report.pdf`, `load-5m-report.pdf`, `stress-5m-report.pdf`
- Supporting explanation: `graph-explanations.md`
- Source: Jenkins local build `#12` for max-limit and build `#260` for load/stress, archived from `output/gatling/`

The max-limit PDF was refreshed from build `#12` after the users/sec refactor. Load and stress PDFs were not rerun in this refresh, so they remain older-profile evidence. For current SLA evidence, rerun load at `250 users/sec` and stress from `250` to `475 users/sec`, with `KO=0` and `p95 < 2000ms` as the recommended pass criteria. Terminal/CMD screenshots are packaged separately under item `k`.
