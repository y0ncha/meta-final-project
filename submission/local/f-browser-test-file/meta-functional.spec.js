const { test, expect } = require('@playwright/test');

test('JSP app supports the required functional flow', async ({ page }) => {
  await test.step('page shell is visible', async () => {
    await page.goto('./');
    await expect(page.locator('#pageTitle')).toHaveText('MeTA');
    await expect.soft(page.locator('main > p').first()).toContainText('opened a ticket for DevOps two weeks ago');
    await expect.soft(page.locator('main > p').first()).toContainText("AI won't replace half of the company");
    await expect(page.locator('#submitButton')).toBeVisible();
    await expect(page.locator('#nameInput')).toBeVisible();
  });

  await test.step('about link navigates to the about section', async () => {
    await page.locator('#aboutLink').click();
    await expect.soft(page).toHaveURL(/#about$/);
    await expect.soft(page.locator('#about')).toContainText('About');
  });

  await test.step('text input accepts typed text', async () => {
    await page.goto('./');
    await page.locator('#nameInput').fill('Yonatan');
    await expect(page.locator('#nameInput')).toHaveValue('Yonatan');
  });

  await test.step('valid submit shows success message', async () => {
    await page.locator('#submitButton').click();
    await expect(page.locator('#resultMessage')).toHaveText('Hello, Yonatan. MeTA Corporate reviewed your form, opened a committee, and somehow approved it.');
    await page.screenshot({ path: 'output/playwright/screenshots/valid-submit.png', fullPage: true });
  });

  await test.step('empty submit shows validation feedback', async () => {
    await page.goto('./');
    await page.locator('#submitButton').click();
    await expect(page.locator('#validationMessage')).toHaveText('Please enter a name before MeTA Corporate schedules a meeting about the empty box.');
    await page.screenshot({ path: 'output/playwright/screenshots/empty-submit.png', fullPage: true });
  });
});
