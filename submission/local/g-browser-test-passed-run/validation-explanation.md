# Validation Used

**Positive** validations prove the expected normal webapp behavior.  
**Negative** validations prove the webapp rejects invalid user behavior.  
**Strict** assert is used when failure makes later checks irrelevant or proves a core page/component failure.  
**Soft** verify is used when the check should still fail the test, but continuing helps show whether unrelated downstream checks also fail.

| #   | Validation                                                   | Description                                                      | Type                    | Why this type                                                                                              |
| --- | ------------------------------------------------------------ | ---------------------------------------------------------------- | ----------------------- | ---------------------------------------------------------------------------------------------------------- |
| 1   | `expect(page).toHaveTitle("MeTA")`                           | Confirms the browser loaded the MeTA app tab.                    | Positive assert, strict | If the wrong app loaded, downstream checks would fail and waste expensive testing time and resources.      |
| 2   | `expect.soft(page.locator("#about")).toContainText(...)`     | Confirms the About section contains expected supporting text.    | Positive verify, soft   | About content is useful product context, but strict failure here would block downstream form-test results. |
| 3   | `expect(page.locator("#resultMessage")).toHaveText(...)`     | Confirms valid submit returns the expected success message.      | Positive assert, strict | Treating valid input as valid is core business logic: if it fails, it can indicate a major input/state security risk and contaminate downstream checks. |
| 4   | `expect.soft(page.locator("#resultMessage")).toBeHidden()`   | Confirms empty submit does not show the positive success result. | Negative verify, soft   | This pre-validation check stays soft so the explicit validation can still catch and report the failed flow. |
| 5   | `expect(page.locator("#validationMessage")).toHaveText(...)` | Confirms the empty-name validation text is the expected message. | Negative assert, strict | Explicit validation is core rejection logic: if it fails, it can indicate a major input/state security risk. |

\* `expect(...)` is a strict assert: it stops the test when a critical requirement fails.

\*\* `expect.soft(...)` is a soft verify: it records the failure, continues execution, and still fails the whole test at the end if the soft check failed.
