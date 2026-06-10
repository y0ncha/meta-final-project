const { chromium, expect } = require('@playwright/test');
const fs = require('node:fs');
const path = require('node:path');

const appBaseUrl = process.env.APP_BASE_URL || 'http://localhost:8080/meta/';
const harPath = process.env.HAR_PATH || 'output/har/meta-functional-flow.har';

async function main() {
  fs.mkdirSync(path.dirname(harPath), { recursive: true });

  let browser;
  let context;

  try {
    browser = await chromium.launch();
    context = await browser.newContext({
      recordHar: {
        path: harPath,
        content: 'embed',
        mode: 'full'
      }
    });

    const page = await context.newPage();
    await page.goto(appBaseUrl, { waitUntil: 'networkidle' });
    await page.locator('#aboutLink').click();
    await expect(page).toHaveURL(/#about$/);
    await page.locator('#nameInput').fill('Yonatan');
    await page.locator('#submitButton').click();
    await expect(page.locator('#resultMessage')).toHaveText('Hello, Yonatan. Your JSP form submission worked.');
  } finally {
    if (context) {
      await context.close();
    }
    if (browser) {
      await browser.close();
    }
  }

  if (!fs.existsSync(harPath) || fs.statSync(harPath).size === 0) {
    throw new Error('HAR file was not created or is empty');
  }

  console.log(`Captured HAR: ${harPath}`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
