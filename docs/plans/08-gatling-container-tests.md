# 08 - Gatling Container Tests

## Goal
Run Gatling in Docker for max-limit discovery, 5-minute load test, and 5-minute stress test.

## Deliverables
- Gatling simulation files.
- Container command/script for each run.
- `output/gatling/max-limit/`.
- `output/gatling/load-5m/`.
- `output/gatling/stress-5m/`.
- Three CMD/terminal screenshots.
- Three Gatling report PDFs.

## Implementation
- Keep target URL configurable with `APP_BASE_URL`.
- Create separate Gatling simulations or separate parameters for:
  - Max-limit discovery.
  - 5-minute load test.
  - 5-minute stress test.
- Run via Gatling container, not host `gatling`.
- Save generated reports to `output/gatling/`.
- Do not invent the max limit; rerun or document uncertainty if the limit is unclear.

## Validation
- Each run completes or fails with a documented reason.
- Each run produces a terminal summary screenshot.
- Each run produces an `index.html` report.
- Each report is exported/printed to PDF.

## Human Configuration Needed
- Capture terminal screenshots.
- Export/print each Gatling `index.html` report to PDF.
- Write graph explanations based on actual results.
