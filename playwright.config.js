// @ts-check
const { defineConfig, devices } = require('@playwright/test');

const chromiumExecutablePath = process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH;
const chromiumUse = Object.assign({}, devices['Desktop Chrome']);
if (chromiumExecutablePath) {
  chromiumUse.launchOptions = Object.assign({}, chromiumUse.launchOptions, {
    executablePath: chromiumExecutablePath
  });
}

module.exports = defineConfig({
  testDir: './tests/playwright',
  timeout: 30000,
  outputDir: 'output/playwright/test-results',
  reporter: [
    ['list'],
    ['html', { outputFolder: 'output/playwright/playwright-report', open: 'never' }],
    ['junit', { outputFile: 'output/playwright/junit.xml' }]
  ],
  use: {
    baseURL: process.env.APP_BASE_URL || 'http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/',
    screenshot: 'only-on-failure',
    trace: 'retain-on-failure',
    video: 'off'
  },
  projects: [
    {
      name: 'chromium',
      use: chromiumUse
    }
  ]
});
