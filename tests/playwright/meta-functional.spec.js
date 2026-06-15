const { test, expect } = require("@playwright/test");

test("JSP app supports the required functional flow", async ({ page }) => {
  // Five assignment-facing validations, with one Playwright expect per validation.
  await test.step("validation 1: assert the app identity", async () => {
    await page.goto("./");

    // Type: strict (assert)
    // What test: the browser tab title identifies the loaded app as MeTA.
    // Why this type: if the wrong page loaded, every downstream check is invalid.
    await expect(page).toHaveTitle("MeTA");
  });

  await test.step("validation 2: verify supporting About content", async () => {
    await page.locator("#aboutLink").click();

    // Type: soft (verify)
    // What test: the About section contains expected supporting page text.
    // Why this type: About content is visible product context, but it should not hide the core form result.
    await expect.soft(page.locator("#about")).toContainText("Maven WAR for Tomcat");
  });

  await test.step("validation 3: assert valid submit succeeds", async () => {
    await page.goto("./");
    await page.locator("#nameInput").fill("Yonatan");
    await page.locator("#submitButton").click();

    // Type: strict (assert)
    // What test: a valid submit shows the expected success message.
    // Why this type: this is the core business result of the positive form flow.
    await expect(page.locator("#resultMessage")).toHaveText(
      "Hello, Yonatan. MeTA Corporate reviewed your form, opened a committee, and somehow approved it.",
    );

    await page.screenshot({
      path: "output/playwright/screenshots/valid-submit.png",
      fullPage: true,
    });
  });

  await test.step("validation 4: verify empty submit does not show success", async () => {
    await page.goto("./");
    await page.locator("#submitButton").click();

    // Type: soft (verify)
    // What test: an empty submit does not show the positive success result.
    // Why this type: this is negative-path evidence, but the explicit validation message is the blocking result.
    await expect.soft(page.locator("#resultMessage")).toBeHidden();
  });

  await test.step("validation 5: assert empty submit shows validation text", async () => {
    await page.screenshot({
      path: "output/playwright/screenshots/empty-submit.png",
      fullPage: true,
    });

    // Type: strict (assert)
    // What test: the empty-name validation message has the expected rejection text.
    // Why this type: accepting invalid input, or rejecting it with the wrong user feedback, breaks the negative flow.
    await expect(page.locator("#validationMessage")).toHaveText(
      "Please enter a name before MeTA Corporate schedules a meeting about the empty box.",
    );
  });
});
