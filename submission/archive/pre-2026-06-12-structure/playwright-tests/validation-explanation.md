# Playwright Validation Explanation

The assignment asks for Selenium IDE evidence. We used Playwright as the equivalent browser automation tool. The official Playwright report is `index.html`; it shows one test file, `meta-functional.spec.js`, with 1 test passed and 0 failed tests.

The screenshots `valid-submit.png` and `empty-submit.png` are supporting evidence from the same automated test run. They show the two main form outcomes checked by the test.

## Validation Types

1. **Page load validation - positive assert**
   - Playwright asserts that the page title is `MeTA`.
   - This proves the deployed Tomcat page loaded correctly.

2. **Required element validation - positive assert**
   - Playwright asserts that the link, name input, and submit button are visible.
   - This proves the page contains the required UI elements.

3. **Link validation - positive assert**
   - Playwright clicks **About this app** and asserts that the URL reaches the `#about` section.
   - This proves the link works.

4. **Input validation - positive assert**
   - Playwright types `Yonatan` into the name input and asserts that the field contains `Yonatan`.
   - This proves the text input accepts user data.

5. **Successful submit validation - positive assert**
   - Playwright submits the form with `Yonatan` and asserts that the success message appears.
   - Evidence screenshot: `valid-submit.png`.
   - This proves the normal user flow works.

6. **Empty submit validation - negative assert**
   - Playwright submits the form with an empty name field and asserts that the validation message appears.
   - Evidence screenshot: `empty-submit.png`.
   - This proves invalid input is rejected instead of being accepted.

## Why This Is Equivalent To Selenium IDE

Playwright `expect(...)` checks are used like Selenium IDE assert/verify validations. They check exact text, URL changes, element visibility, and input values. If a required condition is wrong, the test fails and the Playwright report marks the run as failed. This makes the validation strict enough to prove the application behavior, not just open the page.
