# Public Gatling Max-Limit Graph Explanation

Source: Jenkins `MeTA/meta-container-ci-cd` build `#13`.

The public max-limit run tested the EC2 Tomcat URL from `250` to `550 users/sec` in `25 users/sec` steps. Each level ran for `10` seconds with a `1` second ramp.

The Gatling graphs show the public host handling the lower levels cleanly, then failing at the final tested level. The run completed with `227601` total requests, `227580 OK`, and `21 KO`. The error was `Premature close`, meaning some connections closed before Gatling received a complete response.

Under the project `KO=0` rule, the public tested max limit is `525 users/sec`; `550 users/sec` is the first failing tested level.

This public run also explains the recommended latency SLA. Global p95 reached `1812 ms` near the failing boundary, so refreshed load/stress evidence should use p95 `< 2000ms` rather than a brittle `1000ms` cutoff. The hard pass/fail rule remains `KO=0`.
