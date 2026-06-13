# Public Gatling Load-Test Graph Explanation

Source: Jenkins `MeTA/meta-ci-cd` build `#225`.

The public 5-minute load test used the EC2 Tomcat URL with a fixed `5` virtual users for about `300` seconds. The run completed with `2780` requests, `2780 OK`, and `0 KO`.

In the Gatling report graphs, active users stay stable around the configured load. The request-rate graph shows steady throughput at about `9.205` requests per second. The response-time graph stays low, with `28 ms` mean response time and `66 ms` p95 response time, so the public app stayed healthy at this load level.
