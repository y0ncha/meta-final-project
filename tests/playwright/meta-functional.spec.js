const { test, expect } = require('@playwright/test');

test('JSP app supports the required functional flow', async ({ page }) => {
  await test.step('page shell is visible', async () => {
    await page.goto('./');
    await expect(page.locator('#pageTitle')).toHaveText('DevOps Final Project');
    await expect(page.locator('#submitButton')).toBeVisible();
    await expect(page.locator('#nameInput')).toBeVisible();
  });

  await test.step('about link navigates to the about section', async () => {
    await page.locator('#aboutLink').click();
    await expect(page).toHaveURL(/#about$/);
    await expect(page.locator('#about')).toContainText('About');
  });

  await test.step('text input accepts typed text', async () => {
    await page.locator('#nameInput').fill('Yonatan');
    await expect(page.locator('#nameInput')).toHaveValue('Yonatan');
  });

  await test.step('valid submit shows success message', async () => {
    await page.locator('#submitButton').click();
    await expect(page.locator('#resultMessage')).toHaveText('Hello, Yonatan. Your JSP form submission worked.');
    await page.screenshot({ path: 'output/playwright/screenshots/06-valid-submit.png', fullPage: true });
  });

  await test.step('empty submit shows validation feedback', async () => {
    await page.goto('./');
    await page.locator('#submitButton').click();
    await expect(page.locator('#validationMessage')).toHaveText('Please enter a name before submitting.');
    await page.screenshot({ path: 'output/playwright/screenshots/06-empty-submit.png', fullPage: true });
  });
});
