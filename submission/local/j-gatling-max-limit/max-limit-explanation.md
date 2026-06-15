# Gatling Max-Limit Explanation

Source: Jenkins `MeTA/meta-container-ci-cd` build `#12`.

The local tested max limit is `475 users/sec`.

Why this is the limit:

- Gatling tested the local Tomcat target from `250` to `550 users/sec`.
- Step size was `25 users/sec`; each level ran for `10` seconds with a `1` second ramp.
- The project pass rule is `KO=0`: a tested level passes only when Gatling reports zero failed requests/checks/timeouts.
- `475 users/sec` was the highest tested level before failure.
- `500 users/sec` was the first failing tested level.

What failed:

At `500 users/sec`, Gatling reported `3468` failed requests with `Address not available` against `tomcat:8080`. This means the local Docker/Gatling networking path could no longer allocate or open enough client-side connections for that load. It is valid max-limit evidence because Gatling counted those connection failures as `KO`, so `500 users/sec` violates the `KO=0` rule.

Conclusion: the local app max limit for this evidence run is `475 users/sec`; `500 users/sec` is the first tested level beyond the limit.
