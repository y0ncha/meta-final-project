const fs = require('node:fs');
const path = require('node:path');
const { pathToFileURL } = require('node:url');
const { chromium } = require('@playwright/test');

const reports = [
  {
    htmlPath: 'output/gatling/max-limit/index.html',
    pdfPath: 'output/gatling/max-limit/max-limit-report.pdf',
  },
  {
    htmlPath: 'output/gatling/load-5m/index.html',
    pdfPath: 'output/gatling/load-5m/load-5m-report.pdf',
  },
  {
    htmlPath: 'output/gatling/stress-5m/index.html',
    pdfPath: 'output/gatling/stress-5m/stress-5m-report.pdf',
  },
];

const requireAllReports = process.env.GATLING_PDF_REQUIRE_ALL !== 'false';

async function main() {
  const browser = await chromium.launch();
  let exportedCount = 0;

  try {
    for (const report of reports) {
      const absoluteHtmlPath = path.resolve(report.htmlPath);
      const absolutePdfPath = path.resolve(report.pdfPath);

      if (!fs.existsSync(absoluteHtmlPath)) {
        if (!requireAllReports) {
          console.log(`Skipping missing Gatling report: ${report.htmlPath}`);
          continue;
        }
        throw new Error(`Missing Gatling report: ${report.htmlPath}`);
      }

      fs.mkdirSync(path.dirname(absolutePdfPath), { recursive: true });

      const page = await browser.newPage();
      await page.goto(pathToFileURL(absoluteHtmlPath).href, { waitUntil: 'networkidle' });
      await page.pdf({ path: absolutePdfPath, format: 'A4', printBackground: true });
      await page.close();

      const pdfStat = fs.statSync(absolutePdfPath);
      if (pdfStat.size <= 0) {
        throw new Error(`Generated PDF is empty: ${report.pdfPath}`);
      }

      console.log(`Exported Gatling PDF: ${report.pdfPath}`);
      exportedCount += 1;
    }

    if (exportedCount === 0) {
      throw new Error('No Gatling reports were available for PDF export');
    }
  } finally {
    await browser.close();
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
