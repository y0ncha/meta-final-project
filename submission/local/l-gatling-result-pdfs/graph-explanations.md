# Gatling Graph Explanations

Source: Jenkins local build `#260`.

## Max Limit

The local max-limit run tested the local Tomcat target from `8100` to `12000` virtual users in `50`-user steps, with `10` seconds per level. The highest tested level with `KO=0` was `8300` virtual users. The next tested level, `8350`, was the first failing tested level, so the local tested max limit is `8300` virtual users under the project `KO=0` rule.

The final staircase Gatling report has `1,621,128` total requests, `1,029,510 OK`, and `591,618 KO`. Response times degraded heavily after the boundary: mean `4416 ms`, p95 `12987 ms`, and p99 `18527 ms`. All reported errors were `Address not available` socket errors against the local Tomcat container.

## Load 5m

The local 5-minute load test used a fixed `5` virtual users for about `300` seconds. The run completed with `2336` requests, `2336 OK`, and `0 KO`.

The Gatling graphs show stable low-load behavior: mean request rate `8.027` requests per second, mean response time `7 ms`, p95 `18 ms`, and p99 `41 ms`.

## Stress 5m

The local 5-minute stress test ramped from `5` to `50` virtual users over about `300` seconds. The run completed with `15892` requests, `15892 OK`, and `0 KO`.

The Gatling graphs show throughput increasing with the ramp while requests continue to pass: mean request rate `52.449` requests per second, mean response time `11 ms`, p95 `36 ms`, and p99 `175 ms`.
