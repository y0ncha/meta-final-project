# Public Gatling Load-Test Graph Explanation

Source: Jenkins `MeTA/meta-ci-cd` build `#261`.

The public 5-minute load test used the EC2 Tomcat URL with a fixed `5` virtual users for about `300` seconds. The run completed with `1900` requests, `1900 OK`, and `0 KO`.

In the Gatling report graphs, active users stay stable around the configured load. The request-rate graph shows steady throughput at about `6.529` requests per second. The response-time graph is slower than local but still passes with `0 KO`: mean response time `124 ms`, p95 `805 ms`, and p99 `1412 ms`.
