# Public Gatling Load 5m

- Status: ready
- Required target: `APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Source: Jenkins `MeTA/meta-container-ci-cd` build `#18`
- Result: 5-minute load run completed with `4800` requests, `4800 OK`, and `0 KO`.
- Parameters: `GATLING_LOAD_USERS=5`, duration `300s`.

Packaged files:

- `gatling-load-test.png` - user-captured Jenkins console summary screenshot.
- `load-5m-report.pdf` - exported Gatling graph PDF from build `#18`.
- `graph-explanation.md` - written explanation of the public load-test graphs.

Validation notes:

- Screenshot and PDF source were checked against Jenkins build `#18`.
- Jenkins build `#18` shows `APP_BASE_URL` set to the public EC2 URL above.
- This is valid refreshed public load evidence for the parameters shown in the screenshot.
- Public Gatling HTML and log artifacts were intentionally removed from this folder; the packaged report is the PDF.
