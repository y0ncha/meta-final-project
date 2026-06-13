const { test, expect } = require("@playwright/test");

test("JSP app supports the required functional flow", async ({ page }) => {
  // Business scenario: the browser must open the MeTA app before any form behavior is meaningful.
  await test.step("open app and assert page title", async () => {
    await page.goto("./");
    // Type: strict (assert)
    // What test: the browser tab title identifies the loaded app as MeTA.
    // Why this type: if the wrong page loaded, every downstream check is invalid.
    await expect(page).toHaveTitle("MeTA");

    // Type: strict (assert)
    // What test: the visible page heading identifies the business page as MeTA.
    // Why this type: if the app shell is wrong, the form flow cannot be trusted.
    await expect(page.locator("#pageTitle")).toHaveText("MeTA");
  });

  // Business scenario: the user must have the controls needed to learn about the page and submit the form.
  await test.step("verify page controls are present", async () => {
    // Type: soft (verify)
    // What test: the informational About link is visible to the user.
    // Why this type: a missing About link is a defect, but it does not block form submission.
    await expect.soft(page.locator("#aboutLink")).toBeVisible();

    // Type: strict (assert)
    // What test: the name input is visible so the user can enter form data.
    // Why this type: without the input, the core form flow is unusable.
    await expect(page.locator("#nameInput")).toBeVisible();

    // Type: strict (assert)
    // What test: the submit button is visible so the user can send the form.
    // Why this type: without the button, the core form flow is unusable.
    await expect(page.locator("#submitButton")).toBeVisible();
  });

  // Business scenario: the About link should navigate to supporting page information.
  await test.step("click about link and verify text is present", async () => {
    const aboutLink = page.locator("#aboutLink");
    if (await aboutLink.isVisible()) {
      await aboutLink.click();

      // Type: soft (verify)
      // What test: clicking About moves the browser to the About section anchor.
      // Why this type: broken informational navigation should be reported but should not hide form-flow results.
      await expect.soft(page).toHaveURL(/#about$/);

      // Type: soft (verify)
      // What test: the About section contains the expected About text.
      // Why this type: missing supporting text is a page-content defect, not a blocker for name submission.
      await expect.soft(page.locator("#about")).toContainText("About");
    }
  });

  // Business scenario: submitting a valid name should produce the approved business response.
  await test.step("positive scenario: type name, submit, assert success text", async () => {
    await page.goto("./");
    await page.locator("#nameInput").fill("Yonatan");

    // Type: soft (verify)
    // What test: the name input contains the value typed by the user.
    // Why this type: this is setup evidence; the final success message proves whether submission worked.
    await expect.soft(page.locator("#nameInput")).toHaveValue("Yonatan");

    await page.locator("#submitButton").click();

    // Type: strict (assert)
    // What test: a valid submit shows the expected success message.
    // Why this type: this is the core business result of the positive form flow.
    await expect(page.locator("#resultMessage")).toHaveText(
      "Hello, Yonatan. MeTA Corporate reviewed your form, opened a committee, and somehow approved it.",
    );

    // Type: soft (verify)
    // What test: the submit button remains visible after a successful submit.
    // Why this type: post-submit visibility is supporting UI evidence, not the main business result.
    await expect.soft(page.locator("#submitButton")).toBeVisible();
    await page.screenshot({
      path: "output/playwright/screenshots/valid-submit.png",
      fullPage: true,
    });
  });

  // Business scenario: submitting an empty name should show validation instead of accepting the form.
  await test.step("negative scenario: submit empty form and verify error text", async () => {
    await page.goto("./");
    await page.locator("#submitButton").click();

    await page.screenshot({
      path: "output/playwright/screenshots/empty-submit.png",
      fullPage: true,
    });

    // Type: strict (assert)
    // What test: the empty-name validation message becomes visible.
    // Why this type: accepting an empty name breaks the negative business flow.
    await expect(page.locator("#validationMessage")).toBeVisible();

    // Type: strict (assert)
    // What test: the empty-name validation message has the expected business text.
    // Why this type: wrong validation text means the rejection behavior is not the expected app behavior.
    await expect(page.locator("#validationMessage")).toHaveText(
      "Please enter a name before MeTA Corporate schedules a meeting about the empty box.",
    );
  });
});
