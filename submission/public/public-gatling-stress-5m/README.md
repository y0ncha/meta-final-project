# Public Gatling Stress 5m

- Status: historical evidence; refresh recommended
- Required target: `APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Source: Jenkins `MeTA/meta-ci-cd` build `#261`
- Historical result: 5-minute stress run completed with `15368` requests, `15368 OK`, and `0 KO`.
- Current recommended profile: rerun from `GATLING_STRESS_START_USERS=250` to `GATLING_STRESS_TARGET_USERS=475` users/sec with `KO=0` and p95 `< 2000ms`.

Packaged files:

- `gatling-stress-test.png` - user-captured Jenkins console summary screenshot.
- `stress-5m-report.pdf` - exported Gatling graph PDF from build `#261`.
- `graph-explanation.md` - written explanation of the public stress-test graphs.

Validation notes:

- Screenshot was visually inspected and shows the historical stress summary with `0 KO`.
- Jenkins build `#261` was inspected and shows `APP_BASE_URL` set to the public EC2 URL above.
- This evidence was captured before the users/sec SLA-profile refresh and should not be described as current stress-SLA evidence.
- Public Gatling HTML and log artifacts were intentionally removed from this folder; the packaged report is the PDF.
