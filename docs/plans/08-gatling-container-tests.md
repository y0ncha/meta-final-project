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
- Use the same ephemeral container-runner pattern as Playwright:
  - Local or Jenkins runner script starts Gatling with `docker run --rm`.
  - Gatling container joins the `meta` Docker network.
  - Gatling executes the selected simulation and exits when the run finishes.
  - Docker removes the Gatling container automatically after exit.
- Scope Docker socket access to Jenkins or the local runner that launches the Gatling container; do not mount `/var/run/docker.sock` into the Gatling container itself.
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
