# Gatling Graph Explanations

## Max Limit

The run reached `201304` requests: `191872 OK` and `9432 KO`. The selected clean graph point is `2340 active users`, `1399 OK`, and `0 KO`, so that is the submitted max-limit value.

After that point, failures appear and response times spread out (`p95=530 ms`, `p99=1175 ms`, max `5597 ms`). The main error was `Address not available` against `tomcat:8080`, which suggests local Docker/Jenkins/Gatling/Tomcat connection exhaustion under extreme load, not a JSP logic failure.

## Load 5m

The load run completed cleanly: `4800` requests, `4800 OK`, `0 KO`, all below `800 ms`, with `p95=13 ms` and max `81 ms`.

This shows the normal `5 users/sec` profile is comfortably inside the app's capacity.

## Stress 5m

The stress run also completed cleanly: `33120` requests, `33120 OK`, `0 KO`, all below `800 ms`, with `p95=8 ms` and max `396 ms`.

The higher max response time is expected with more traffic, but the zero-KO result shows this stress range did not break the system.

## What Happened

Load and stress stayed healthy. The max-limit run pushed past the clean operating range and exposed the local environment's connection limit.
