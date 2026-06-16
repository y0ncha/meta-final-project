# Gatling Graph Explanations

This folder should contain three PDFs exported from Gatling `index.html`: max-limit, load, and stress.

## Max Limit

The max-limit run intentionally pushes the app until it breaks.

The local report reached `201304` requests: `191872 OK` and `9432 KO`. The main error was `Address not available` against `tomcat:8080`. That means the Gatling client/local network path ran out of available connections before every request could be opened successfully.

Use the graph point before the failure region as the limit. The selected local tooltip shows `2340 active users`, `1399 OK`, and `0 KO`.

## Load 5m

The load test is the normal steady run. It should show stable traffic, low response times, and `0 KO`. That means the app handles normal expected traffic without errors.

## Stress 5m

The stress test increases traffic gradually. It should still stay at `0 KO`, but response times can rise because more users are active at the same time.

## What Happened

The system works under the normal load and stress profiles. In the max-limit run, the generator pushed beyond the local environment's connection capacity, so connection allocation started failing. This is why the max-limit report has KO errors while the regular load/stress reports should not.

Jenkins uses one shared `output/gatling/` workspace, so each new Gatling run can overwrite the previous HTML report. Export the PDF immediately after the intended run.
