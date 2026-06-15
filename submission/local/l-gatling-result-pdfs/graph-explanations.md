# Gatling Graph Explanations

Source: Jenkins local builds `#12` for max-limit and `#260` for load/stress.

## Max Limit

The local max-limit run used a users/sec arrival-rate staircase from `250` to `550 users/sec`, stepping by `25 users/sec`. Each level ran for `10` seconds with a `1` second ramp.

The Gatling graphs show the load increasing until the local Docker/Tomcat path starts producing failures. The run completed with `217272` total requests, `213804 OK`, and `3468 KO`. The dominant error was `Address not available` against `tomcat:8080`, which means the local client/network path could not allocate or open enough connections at the failing load.

Under the project `KO=0` rule, the graph supports a local tested max limit of `475 users/sec`; `500 users/sec` is the first failing tested level.

## Load 5m

The local 5-minute load test used a fixed `5` virtual users for about `300` seconds. The run completed with `2336` requests, `2336 OK`, and `0 KO`.

The Gatling graphs show stable low-load behavior: mean request rate `8.027` requests per second, mean response time `7 ms`, p95 `18 ms`, and p99 `41 ms`.

## Stress 5m

The local 5-minute stress test ramped from `5` to `50` virtual users over about `300` seconds. The run completed with `15892` requests, `15892 OK`, and `0 KO`.

The Gatling graphs show throughput increasing with the ramp while requests continue to pass: mean request rate `52.449` requests per second, mean response time `11 ms`, p95 `36 ms`, and p99 `175 ms`.
