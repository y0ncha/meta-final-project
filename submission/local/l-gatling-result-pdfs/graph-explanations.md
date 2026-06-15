# Gatling Graph Explanations

Source: Jenkins local build `#260`.

## Max Limit

Pending refresh: the local max-limit PDF and graph explanation must be regenerated after the users/sec max-limit refactor.

The refreshed max-limit graph explanation should describe the users/sec arrival-rate staircase, the tested users/sec range, the highest tested users/sec level with `KO=0`, and the first tested users/sec level with `KO>0`. Do not reuse the previous concurrent-user boundary as the users/sec result.

## Load 5m

The local 5-minute load test used a fixed `5` virtual users for about `300` seconds. The run completed with `2336` requests, `2336 OK`, and `0 KO`.

The Gatling graphs show stable low-load behavior: mean request rate `8.027` requests per second, mean response time `7 ms`, p95 `18 ms`, and p99 `41 ms`.

## Stress 5m

The local 5-minute stress test ramped from `5` to `50` virtual users over about `300` seconds. The run completed with `15892` requests, `15892 OK`, and `0 KO`.

The Gatling graphs show throughput increasing with the ramp while requests continue to pass: mean request rate `52.449` requests per second, mean response time `11 ms`, p95 `36 ms`, and p99 `175 ms`.
