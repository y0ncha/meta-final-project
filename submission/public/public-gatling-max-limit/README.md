# Public Gatling Max Limit

- Status: ready with caveat
- Required target: `APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Source: Jenkins `MeTA/meta-ci-cd` build `#261`
- Result: no passing public max-limit level was proven in this run. The first tested level, `8100` virtual users, already failed with `KO>0`, so this run does not establish an exact public max limit.

Packaged files:

- `gatling-max-limit-test.png` - user-captured Jenkins console summary screenshot.
- `max-limit-report.pdf` - exported Gatling graph PDF from build `#261`.
- `graph-explanation.md` - written explanation of the public max-limit graphs.

Validation notes:

- Screenshot was visually inspected and shows the max-limit summary, the public EC2 URL, and `8100` as the first failing tested level.
- Jenkins build `#261` was inspected and shows `APP_BASE_URL` set to the public EC2 URL above.
- Public Gatling HTML and log artifacts were intentionally removed from this folder; the packaged report is the PDF.
