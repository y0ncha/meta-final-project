# Gatling Graph Explanations

## Max Limit

Build `#224` tested single max-limit levels from `8000` to `12000` virtual users in `20`-user steps, holding each level for `10` seconds. Levels through `8400` passed with `KO=0`; the next tested level, `8420`, failed with `61` connection-timeout errors. Gatling recorded `33,680` requests at the failing level, with `33,619` successful responses, `61` failed responses, and a 95th percentile response time of `14,538 ms`. Because the project max-limit rule is `KO=0`, the local tested max limit is `8400` virtual users for this Jenkins/Tomcat container setup.

## Load 5m

The 5-minute load test held the configured steady load and completed with `2,860` successful requests and `0` failures. The 95th percentile response time was `35 ms`, the 99th percentile was `87 ms`, and all requests were below `800 ms`. The graph should look flat and stable because the local Tomcat container handled this light sustained load without visible saturation.

## Stress 5m

The 5-minute stress test ramped from `5` to `50` virtual users and completed with `16,276` successful requests and `0` failures. The 95th percentile response time was `14 ms`, the 99th percentile was `37 ms`, and all requests stayed below `800 ms`. The request-rate graph should rise with the ramp while the response-time graphs remain low, which indicates the local Tomcat container handled the configured ramp without bottlenecking.
