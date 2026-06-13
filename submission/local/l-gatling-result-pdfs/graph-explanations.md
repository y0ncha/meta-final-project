# Gatling Graph Explanations

Source: Jenkins local build `#248`.

## Max Limit

The local max-limit run tested the local Tomcat target from `8100` to `12000` virtual users in `20`-user steps, with `10` seconds per level. The highest tested level with `KO=0` was `8440` virtual users. The next tested level, `8460`, produced `33` failed requests from connection timeouts, so the local tested max limit is `8440` virtual users under the project `KO=0` rule.

The final failing-level Gatling report has `33840` total requests, `33807 OK`, and `33 KO`. Response times degraded heavily at the boundary: mean `5676 ms`, p95 `17096 ms`, and p99 `21531 ms`.

## Load 5m

The local 5-minute load test used a fixed `5` virtual users for about `300` seconds. The run completed with `2356` requests, `2356 OK`, and `0 KO`.

The Gatling graphs show stable low-load behavior: mean request rate `8.096` requests per second, mean response time `5 ms`, p95 `13 ms`, and p99 `25 ms`.

## Stress 5m

The local 5-minute stress test ramped from `5` to `50` virtual users over about `300` seconds. The run completed with `16036` requests, `16036 OK`, and `0 KO`.

The Gatling graphs show throughput increasing with the ramp while requests continue to pass: mean request rate `53.099` requests per second, mean response time `8 ms`, p95 `22 ms`, and p99 `150 ms`.
