# Public Gatling Load 5m

- Status: historical evidence; refresh recommended
- Required target: `APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Source: Jenkins `MeTA/meta-ci-cd` build `#261`
- Historical result: 5-minute load run completed with `1900` requests, `1900 OK`, and `0 KO`.
- Current recommended profile: rerun at `GATLING_LOAD_USERS=250` users/sec with `KO=0` and p95 `< 2000ms`.

Packaged files:

- `gatling-load-test.png` - user-captured Jenkins console summary screenshot.
- `load-5m-report.pdf` - exported Gatling graph PDF from build `#261`.
- `graph-explanation.md` - written explanation of the public load-test graphs.

Validation notes:

- Screenshot was visually inspected and shows the historical load summary with `0 KO`.
- Jenkins build `#261` was inspected and shows `APP_BASE_URL` set to the public EC2 URL above.
- This evidence was captured before the users/sec SLA-profile refresh and should not be described as current load-SLA evidence.
- Public Gatling HTML and log artifacts were intentionally removed from this folder; the packaged report is the PDF.
