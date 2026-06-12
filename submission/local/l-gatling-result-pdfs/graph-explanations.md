# Gatling Graph Explanations

## Max Limit

The max-limit run completed the configured stepped profile from 5 to 50 users per second without crossing the failure threshold. Gatling recorded 21,450 requests, 21,450 successful responses, 0 failed responses, and a 95th percentile response time of 10 ms. Because no tested level failed, this is a tested lower bound through the highest configured step, not the true application maximum.

## Load 5m

The 5-minute load test held the default steady rate and completed with 3,000 successful requests and 0 failures. The 95th percentile response time was 20 ms and all requests were below 800 ms, so the graph should appear flat and stable with no visible saturation under this light sustained load.

## Stress 5m

The 5-minute stress test ramped from 5 to 50 users per second and completed with 16,500 successful requests and 0 failures. The 95th percentile response time was 14 ms, the 99th percentile was 117 ms, and all requests stayed below 800 ms. The request-rate graph should rise with the ramp while response-time graphs remain low, which indicates the local Tomcat container handled the configured ramp without visible bottlenecking.
