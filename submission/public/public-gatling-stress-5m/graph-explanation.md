# Public Gatling Stress-Test Graph Explanation

Source: Jenkins `MeTA/meta-ci-cd` build `#261`.

This is historical evidence from before the users/sec SLA-profile refresh. The public 5-minute stress test used the EC2 Tomcat URL and ramped from `5` to `50` virtual users over about `300` seconds. The run completed with `15368` requests, `15368 OK`, and `0 KO`.

In the Gatling report graphs, active users increase over time as the stress ramp progresses. The request-rate graph rises with the ramp and averages about `50.719` requests per second. The response-time graph remains stable enough to pass, with `28 ms` mean response time, `80 ms` p95 response time, and `0 KO`, so this public stress run did not reach a failure point.

For current public stress-SLA evidence, rerun from `GATLING_STRESS_START_USERS=250` to `GATLING_STRESS_TARGET_USERS=475` users/sec and require both `KO=0` and p95 `< 2000ms`.
