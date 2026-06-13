# Gatling Graph Explanations

Status: stale after Gatling profile changes. The packaged PDFs in this folder were generated before the new load, stress, and max-limit workload shapes. Do not use the old numbers as current evidence after this change.

## Max Limit

Update this section after rerunning the max-limit wrapper and exporting the new PDF. Explain the final visual Gatling report from the PDF: the stepped virtual-user levels, the first level where failures appear, the total requests, successful responses, failed responses, and response-time percentiles. The max-limit result remains the previous tested level with `KO=0`, even if the visual PDF includes the first failing level.

## Load 5m

Update this section after rerunning the load test and exporting the new PDF. Explain the graph values shown in that PDF: the ramp-up, plateau, ramp-down, request count, failure count, and response-time percentiles.

## Stress 5m

Update this section after rerunning the stress test and exporting the new PDF. Explain the graph values shown in that PDF: the five stepped virtual-user levels, request count, failure count, and response-time percentiles.
