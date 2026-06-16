# Public Gatling Max Limit

- Status: ready
- Required target: `APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Source: `builds/max-limit-public/`
- Public tested max limit: `6718 active users` from a zero-KO `Number of responses per second` tooltip
- Graph point: Tuesday, June 16, `03:38:22`
- Generator sweep: `50-700 users/sec`, step `50 users/sec`, `10s/level`, `1s` ramp
- Load/stress note: this max-limit failure-discovery run should not be used to set refreshed load/stress targets

Packaged files:

- `gatling-max-limit-test.png` - user-captured Jenkins console summary screenshot.
- `max-limit-report.pdf` - exported Gatling graph PDF from `builds/max-limit-public/`.
- `max-limit-public.png` - graph hover screenshot showing the selected zero-KO response tooltip.
- `graph-explanation.md` - written explanation of the public max-limit graphs.

Validation notes:

- Screenshot was visually inspected and matches the public EC2 URL, `201518` requests, `192205 OK`, `9313 KO`, and the `50-700 users/sec` generator sweep.
- The `Number of responses per second` graph hover screenshot `max-limit-public.png` shows `6718 active users`, `301 OK`, and `0 KO`.
- The full report active-users graph later reaches higher values, but those are not the selected zero-KO response tooltip shown in the evidence screenshot.
- The packaged PDF hash matches `builds/max-limit-public/max-limit-report.pdf`.
