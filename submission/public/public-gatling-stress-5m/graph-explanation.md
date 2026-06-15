# Public Gatling Stress-Test Graph Explanation

Source: Jenkins `MeTA/meta-container-ci-cd` build `#18`.

The public 5-minute stress test used the EC2 Tomcat URL and ramped from `5` to `50 users/sec` over about `300` seconds. The run completed with `33120` requests, `33120 OK`, and `0 KO`.

In the Gatling report graphs, throughput rises with the stress ramp and averages `109.307` requests/sec. Response time remains acceptable for this run: mean `24 ms`, p95 `67 ms`, p99 `126 ms`, and `0 KO`.
