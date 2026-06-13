# Item I - HAR File

- Status: partial
- Assignment item: `i) Attach the HAR file`
- Packaged file: `meta-functional-flow.har`
- Source file: `output/har/meta-functional-flow.har`
- Validation command: `node scripts/validate-har submission/local/i-har-file/meta-functional-flow.har`
- Validation result: passed with `entries=4` and `groupContextRequests=4`
- Manual review needed: the HAR contains local `JSESSIONID` cookie evidence; decide whether to send as-is or redact cookie values before external sharing

The HAR is packaged and structurally valid, but sensitivity review must happen before external sharing.
