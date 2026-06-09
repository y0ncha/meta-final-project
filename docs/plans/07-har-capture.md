# 07 - HAR Capture

## Goal
Capture a real HAR file for the JSP application scenario and document the scenario in words.

## Deliverables
- `docs/har-scenario.md`.
- `output/har/<scenario>.har`.

## Implementation
- Use this scenario unless the app behavior changes:
  - Open the app.
  - Click the link.
  - Type text into the input.
  - Click the button.
  - Observe the result.
- Capture HAR using Chrome DevTools or Playwright/browser tooling.
- Save the HAR with content, not a summary-only export.
- Keep the HAR scenario aligned with the Playwright and Gatling flows.

## Validation
- HAR file exists.
- HAR contains requests to the JSP app URL.
- `docs/har-scenario.md` describes the same flow in plain language.

## Human Configuration Needed
- Manual browser HAR export may be needed if automated HAR capture is not implemented.
