# Item L - Gatling Result PDFs

- Status: needs final PDF refresh for the intended load/stress runs
- Assignment item: `l) Attach 3 PDFs (max limit, load and stress) with Gatling results/graphs, explain why the results look this way`
- Packaged PDFs: `max-limit-report.pdf`, `load-5m-report.pdf`, `stress-5m-report.pdf`
- Supporting explanation: `graph-explanations.md`
- Source rule: export/print each intended Gatling `index.html` to PDF, then copy it here immediately.

Important: Jenkins reuses the same `output/gatling/` workspace. A later load, stress, public, or local run can overwrite the previous HTML report. Do not treat a PDF as final unless it was exported from the intended report before the next Gatling run.

Max-limit is a breaking-point run: failures are expected once the system/client network path is pushed too far. Load and stress should be clean comparison runs with `0 KO`.
