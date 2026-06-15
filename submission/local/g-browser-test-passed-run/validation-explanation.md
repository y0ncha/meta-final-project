# Validation Used

**Positive** validations prove the expected normal webapp behavior.  
**Negative** validations prove the webapp rejects invalid user behavior.  
**Strict** assert is used when failure makes later checks irrelevant or proves a core page/component failure.  
**Soft** verify is used when the check should still fail the test, but continuing helps show whether unrelated downstream checks also fail.

The test uses exactly five assignment-facing validations, with one Playwright `expect` per validation.

| # | Validation                                                   | Description                                                      | Type                    | Why this type                                                                                              |
| - | ------------------------------------------------------------ | ---------------------------------------------------------------- | ----------------------- | ---------------------------------------------------------------------------------------------------------- |
| 1 | `expect(page).toHaveTitle("MeTA")`                           | Confirms the browser loaded the MeTA app tab.                    | Positive assert, strict | If it fails, all downstream webapp checks are irrelevant.                                                  |
| 2 | `expect.soft(page.locator("#about")).toContainText(...)`     | Confirms the About section contains expected supporting text.    | Positive verify, soft   | About content is visible product context, but it should not hide the core form result.                     |
| 3 | `expect(page.locator("#resultMessage")).toHaveText(...)`     | Confirms valid submit returns the expected success message.      | Positive assert, strict | Treating valid input as valid is core business logic: if it fails, the valid-submit flow failed.           |
| 4 | `expect.soft(page.locator("#resultMessage")).toBeHidden()`   | Confirms empty submit does not show the positive success result. | Negative verify, soft   | This is negative-path evidence, but the explicit validation message is the blocking result.                |
| 5 | `expect(page.locator("#validationMessage")).toHaveText(...)` | Confirms the empty-name validation text is the expected message. | Negative assert, strict | Failed input validation is a major security risk: wrong feedback means rejection behavior is not reliable. |

\* `expect(...)` is a strict assert: it stops the test when a critical requirement fails.

\*\* `expect.soft(...)` is a soft verify: it records the failure, continues execution, and still fails the whole test at the end if the soft check failed.
