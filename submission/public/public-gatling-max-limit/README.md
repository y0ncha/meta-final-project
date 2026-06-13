# Public Gatling Max Limit

- Status: ready
- Required target: `APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Source: Jenkins `MeTA/meta-ci-cd` build `#249`
- Result: `8280` virtual users passed with `KO=0`; `8300` was the first failing tested level with `KO=47`.

Packaged files:

- `gatling-max-limit.png` - user-captured Jenkins console summary screenshot.
- `max-limit-report.pdf` - exported Gatling graph PDF from build `#249`.
- `graph-explanation.md` - written explanation of the public max-limit graphs.

Validation notes:

- Screenshot was visually inspected and shows the max-limit summary, `8280` highest passing level, and `8300` first failing level.
- Jenkins build `#249` was inspected and shows `APP_BASE_URL` set to the public EC2 URL above.
- Public Gatling HTML and log artifacts were intentionally removed from this folder; the packaged report is the PDF.
