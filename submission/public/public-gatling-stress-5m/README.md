# Public Gatling Stress 5m

- Status: ready
- Required target: `APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Source: Jenkins `MeTA/meta-container-ci-cd` build `#18`
- Result: 5-minute stress run completed with `33120` requests, `33120 OK`, and `0 KO`.
- Parameters: `GATLING_STRESS_START_USERS=5`, `GATLING_STRESS_TARGET_USERS=50`, duration `300s`.

Packaged files:

- `gatling-stress-test.png` - user-captured Jenkins console summary screenshot.
- `stress-5m-report.pdf` - exported Gatling graph PDF from build `#18`.
- `graph-explanation.md` - written explanation of the public stress-test graphs.

Validation notes:

- Screenshot and PDF source were checked against Jenkins build `#18`.
- Jenkins build `#18` shows `APP_BASE_URL` set to the public EC2 URL above.
- This is valid refreshed public stress evidence for the parameters shown in the screenshot.
- Public Gatling HTML and log artifacts were intentionally removed from this folder; the packaged report is the PDF.
