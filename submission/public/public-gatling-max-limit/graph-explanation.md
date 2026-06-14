# Public Gatling Max-Limit Graph Explanation

Source: Jenkins `MeTA/meta-ci-cd` build `#261`.

The public max-limit run tested the EC2 Tomcat URL from `8100` to `12000` virtual users in `50`-user steps, with `10` seconds per level. The first tested level, `8100`, already produced failures, so this run does not prove a public max-limit value. Under the project `KO=0` rule, a precise max limit needs a passing tested level followed by a failing tested level; this public run only proves that `8100` virtual users is beyond the public passing boundary.

In the Gatling report graphs, active users rise sharply through the staircase while the public host is already failing. The final staircase report has `2,545,428` total requests, `506,017 OK`, and `2,039,411 KO`. The dominant errors are connection refused (`1,749,919`) and connection timed out (`285,951`) against `51.84.219.74:8080`, so the graph represents overload of the public Tomcat path rather than a clean boundary bracket.
