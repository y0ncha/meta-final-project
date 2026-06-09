# 06 - Playwright Container Functional Test

## Goal
Create and run the required browser automation test with five validations using a Playwright container.

## Deliverables
- Playwright test project files.
- Functional test file.
- Test screenshots/report under `output/playwright/`.
- Jenkins command or stage to run the Playwright container.

## Implementation
- Use `@playwright/test`, not only the exploratory Playwright CLI.
- Keep `APP_BASE_URL` configurable.
- Add exactly five clear validations:
  - Page heading/app shell is visible.
  - Link interaction changes visible content or navigates correctly.
  - Input accepts typed text.
  - Button submit with valid input shows expected result.
  - Empty submit shows expected validation feedback.
- Run tests in the official Playwright container.
- Configure screenshots/report output for archival.

## Validation
- Local containerized Playwright run passes.
- Jenkins-triggered Playwright run passes.
- Evidence includes a passed-run log and at least one relevant screenshot/report.

## Human Configuration Needed
- None if Docker can pull the Playwright image.
