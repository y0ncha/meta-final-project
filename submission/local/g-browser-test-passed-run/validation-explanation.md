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

\* `expect(...)` is a strict assert: it stops the test when a critical requirement fails.

\*\* `expect.soft(...)` is a soft verify: it records the failure, continues execution, and still fails the whole test at the end if the soft check failed.
