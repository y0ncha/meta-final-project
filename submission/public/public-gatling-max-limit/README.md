# Public Gatling Max Limit

- Status: ready
- Required target: `APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Source: Jenkins `MeTA/meta-container-ci-cd` build `#13`
- Public tested max limit: `525 users/sec`
- First failing tested level: `550 users/sec`

Packaged files:

- `gatling-max-limit-test.png` - user-captured Jenkins console summary screenshot.
- `max-limit-report.pdf` - exported Gatling graph PDF from build `#13`.
- `graph-explanation.md` - written explanation of the public max-limit graphs.

Validation notes:

- Screenshot was visually inspected and shows the max-limit summary, the public EC2 URL, and the `525` / `550 users/sec` boundary.
- Jenkins build `#13` was inspected and shows `APP_BASE_URL` set to the public EC2 URL above.
- Public Gatling HTML and log artifacts were intentionally removed from this folder; the packaged report is the PDF.
