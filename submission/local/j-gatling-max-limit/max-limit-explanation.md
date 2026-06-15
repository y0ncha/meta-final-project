# Gatling Max-Limit Explanation

- Gatling tested the local Tomcat target from `250` to `550 users/sec`.
- Step size was `25 users/sec`; each level ran for `10` seconds with a `1` second ramp.
- The project pass rule is `KO=0`: a tested level passes only when Gatling reports zero failed requests/checks/timeouts.
- `475 users/sec` was the highest tested level before failure.
- `500 users/sec` was the first failing tested level.

At `500 users/sec`, Gatling reported `3468` failed requests with `Address not available` against `tomcat:8080`. This means the test reached a point where the local Host/Server networking path could no longer open enough connections to keep serving the requested rate reliably. Because those connection failures were counted as `KO`, `500 users/sec` fails the project SLA of `KO=0`.
