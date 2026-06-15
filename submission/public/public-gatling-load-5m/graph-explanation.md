# Public Gatling Load-Test Graph Explanation

Source: Jenkins `MeTA/meta-container-ci-cd` build `#18`.

The public 5-minute load test used the EC2 Tomcat URL with `5 users/sec` for about `300` seconds. The run completed with `4800` requests, `4800 OK`, and `0 KO`.

In the Gatling report graphs, traffic stays stable around the configured load. The request-rate graph averages `16.107` requests/sec. Response time remains low for the public EC2 target: mean `23 ms`, p95 `58 ms`, and p99 `120 ms`.
