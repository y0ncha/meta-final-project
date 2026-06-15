# Gatling Max-Limit Explanation

- Gatling tested the local Tomcat target from `250` to `550 users/sec`.
- Step size was `25 users/sec`; each level ran for `10` seconds with a `1` second ramp.
- Pass rule is `KO=0`: a tested level passes only when Gatling reports zero failed requests/checks/timeouts.
- Gatling's final request-rate and active-user metrics are observed results, not the configured max-limit level.
- `475 users/sec` was the highest tested level before failure.
- `500 users/sec` was the first failing tested level.

At `500 users/sec`, the tested local deployment setup could no longer sustain the requested rate with zero failures. Gatling reported `3468` `KO` failures with `Address not available`.
