# Public Gatling Stress-Test Graph Explanation

Source: Jenkins `MeTA/meta-ci-cd` build `#225`.

The public 5-minute stress test used the EC2 Tomcat URL and ramped from `5` to `50` virtual users over about `300` seconds. The run completed with `15592` requests, `15592 OK`, and `0 KO`.

In the Gatling report graphs, active users increase over time as the stress ramp progresses. The request-rate graph rises with the ramp and averages about `51.629` requests per second. The response-time graph remains stable, with `24 ms` mean response time and `47 ms` p95 response time, so this public stress run did not reach a failure point.
