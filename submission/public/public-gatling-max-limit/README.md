# Public Gatling Max Limit

- Status: ready
- Required target: `APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Source: Jenkins `MeTA/meta-ci-cd` build `#225`
- Result: `8060` virtual users passed with `KO=0`; `8080` was the first failing tested level with `KO=2`.

Packaged files:

- `gatling-max-limit.png` - user-captured Jenkins console summary screenshot.
- `max-limit-run.log` - Gatling run log from build `#225`.
- `max-limit-discovery.log` - max-limit discovery summary from build `#225`.
- `index.html` - Gatling HTML report from build `#225`.
- `max-limit-report.pdf` - exported Gatling graph PDF from build `#225`.
- `graph-explanation.md` - written explanation of the public max-limit graphs.

Validation notes:

- Screenshot was visually inspected and shows the max-limit summary, `8060` highest passing level, and `8080` first failing level.
- Jenkins build `#225` was inspected and shows `APP_BASE_URL` set to the public EC2 URL above.
