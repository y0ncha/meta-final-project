# Public Gatling Stress 5m

- Status: ready
- Required target: `APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Source: Jenkins `MeTA/meta-ci-cd` build `#225`
- Result: 5-minute stress run completed with `15592` requests, `15592 OK`, and `0 KO`.

Packaged files:

- `gatling-stress-test.png` - user-captured Jenkins console summary screenshot.
- `stress-5m-run.log` - Gatling run log from build `#225`.
- `index.html` - Gatling HTML report from build `#225`.
- `stress-5m-report.pdf` - exported Gatling graph PDF from build `#225`.
- `graph-explanation.md` - written explanation of the public stress-test graphs.

Validation notes:

- Screenshot was visually inspected and shows the stress summary with `0 KO`.
- Jenkins build `#225` was inspected and shows `APP_BASE_URL` set to the public EC2 URL above.
