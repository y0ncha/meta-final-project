# Item J - Gatling Max-Limit Result

- Status: ready
- Assignment item: `j) Write in the email what is your app max limit, explain why this is the limit and how you found it`
- Packaged files: `max-limit-explanation.md`, `max-limit-local.png`
- Source checked: `builds/max-limit-local/`
- Local graph point: `2340 active users`, `1399 OK`, `0 KO`
- Local generator sweep: `50-700 users/sec`, step `50 users/sec`, `10s/level`, `1s` ramp

The assignment max-limit value should be stated as the active-users count at a `Number of responses per second` tooltip with `KO=0`, not as a users/sec generator setting.

The graph hover screenshot is packaged as `max-limit-local.png`.
