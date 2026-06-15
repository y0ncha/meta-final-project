# Validation Used

**Positive** validations prove the expected normal webapp behavior.  
**Negative** validations prove the webapp rejects invalid user behavior.  
**Strict** assert is used when failure makes later checks irrelevant or proves a core page/component failure.  
**Soft** verify is used when the check should still fail the test, but continuing helps show whether unrelated downstream checks also fail.

| #   | Validation                                                       | Description                                                      | Type                    | Why this type                                                                                              |
| --- | ---------------------------------------------------------------- | ---------------------------------------------------------------- | ----------------------- | ---------------------------------------------------------------------------------------------------------- |
| 1   | `expect(page).toHaveTitle("MeTA")`                               | Confirms the browser loaded the MeTA app tab.                    | Positive assert, strict | If it fails, all downstream webapp checks are irrelevant.                                                  |
| 2   | `expect(page.locator("#pageTitle")).toHaveText("MeTA")`          | Confirms the visible page heading is MeTA.                       | Positive assert, strict | If it fails, the page shell is wrong and the form flow cannot be trusted.                                  |
| 3   | `expect.soft(page.locator("#aboutLink")).toBeVisible()`          | Checks that the About link is visible.                           | Positive verify, soft   | Continue so unrelated core form checks can still run and be reported.                                      |
| 4   | `expect(page.locator("#nameInput")).toBeVisible()`               | Checks that the name input is visible.                           | Positive assert, strict | Without the input, later form tests are not meaningful.                                                    |
| 5   | `expect(page.locator("#submitButton")).toBeVisible()`            | Checks that the submit button is visible.                        | Positive assert, strict | Without submit, both positive and negative form flows are blocked.                                         |
| 6   | `expect.soft(page).toHaveURL(/#about$/)`                         | Confirms clicking About moves to the About anchor.               | Positive verify, soft   | Continue because About navigation is separate from the core form logic.                                    |
| 7   | `expect.soft(page.locator("#about")).toContainText("About")`     | Confirms the About section contains expected text.               | Positive verify, soft   | Continue so a content issue does not hide unrelated form behavior.                                         |
| 8   | `expect.soft(page.locator("#nameInput")).toHaveValue("Yonatan")` | Confirms the typed valid name is present before submit.          | Positive verify, soft   | Continue to see whether submission logic fails independently.                                              |
| 9   | `expect(page.locator("#resultMessage")).toHaveText(...)`         | Confirms valid submit returns the expected success message.      | Positive assert, strict | Treating valid input as valid is core business logic: if it fails, the valid-submit flow failed.           |
| 10  | `expect.soft(page.locator("#submitButton")).toBeVisible()`       | Confirms the submit button remains visible after success.        | Positive verify, soft   | Continue/report it without treating it as the main success result.                                         |
| 11  | `expect(page.locator("#validationMessage")).toBeVisible()`       | Confirms empty submit shows a validation message.                | Negative assert, strict | Failed input validation is a major security risk: if no error appears, the app accepted invalid input.     |
| 12  | `expect(page.locator("#validationMessage")).toHaveText(...)`     | Confirms the empty-name validation text is the expected message. | Negative assert, strict | Failed input validation is a major security risk: wrong feedback means rejection behavior is not reliable. |

## Gatling SLA Context

| Area | Current recommendation | Reason |
| --- | --- | --- |
| Hard performance SLA | `KO=0` for load, stress, and max-limit runs | A single failed request/check/timeout means the tested level is not acceptable. |
| Latency SLA | `p95 < 2000ms` for load and stress evidence | Public build `#13` reached `1812ms` near the boundary, so `1000ms` would be too brittle. |
| Load parameters | `GATLING_LOAD_USERS=250` users/sec | About half of the conservative local proven max-limit, suitable for stable evidence. |
| Stress parameters | `GATLING_STRESS_START_USERS=250`, `GATLING_STRESS_TARGET_USERS=475` users/sec | Exercises degradation up to the local passing boundary without crossing into known failure. |
| Max-limit parameters | `450-550` users/sec, step `25`, `10s` per level, ramp `1s` | Covers the local `475/500` and public `525/550` pass/fail boundaries with less wasted runtime. |

\* `expect(...)` is a strict assert: it stops the test when a critical requirement fails.

\*\* `expect.soft(...)` is a soft verify: it records the failure, continues execution, and still fails the whole test at the end if the soft check failed.
