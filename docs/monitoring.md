# Monitoring

## Jenkins Job

- Job name: `meta-monitoring`
- Job type: Freestyle project
- Trigger: Build periodically
- Schedule: `H/5 * * * *`
- Build step: Execute shell
- Build command: `./scripts/run-monitoring-check`
- Local target from Jenkins: `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Evidence path: `output/monitoring/latest-check.txt`
- Post-build action: Archive artifacts with pattern `output/monitoring/**/*`

The instructor confirmed that monitoring should be a separate Jenkins job. Do not put the 5-minute monitoring schedule in the CI/CD job `meta-container-ci-cd`.

## Behavior

The Freestyle job runs:

```sh
./scripts/run-monitoring-check
```

The script performs one bounded HTTP check:

```sh
curl --connect-timeout 5 --max-time 15 -fsS "$APP_BASE_URL" >/dev/null
```

On success it writes:

```text
status=up
target=http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/
checked_at=<UTC timestamp>
job=meta-monitoring
build=<build number>
```

The Jenkins job archives `output/monitoring/**/*` so the latest Jenkins-side monitoring evidence can be downloaded from the build page.

## Official Monitor Evidence

Use UptimeRobot as the preferred official monitor evidence. SiteMonitorLite is acceptable if the project documents why it was used instead. The final submission still needs a screenshot showing:

- Monitor tool name.
- Monitored target.
- 5-minute interval or equivalent configured cadence.
- Passed or up status.

For local-only evidence, the Jenkins Freestyle job checks `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` from inside the Docker network. For public-IP bonus evidence, the official monitor target must be the real public Tomcat URL and the bonus must not be claimed unless that public evidence exists.

## Class Material Alignment

The Lecture 5 monitoring slides define monitoring as a preventive measure and a process of continuous scanning. The project maps that directly to a scheduled availability check every 5 minutes.

The lecture demo shows UptimeRobot and SiteMonitorLite with these operations: create monitor, choose HTTP/Ping, set timeout, run, and edit. The course-facing evidence should therefore name UptimeRobot or SiteMonitorLite when available, show the monitored URL, show the 5-minute cadence, and show an up/passed state. Jenkins is the assignment-required trigger for the 5-minute check; it should not be presented as a replacement for the UptimeRobot/SiteMonitorLite screenshot when that screenshot is available.

Current evidence split:

- Jenkins `meta-monitoring`: proves the assignment's Jenkins-triggered 5-minute monitoring cadence.
- UptimeRobot screenshot: proves the lecture-demo monitor tool, HTTP monitor target, 5-minute check interval, and up status for the public Tomcat URL.
- SiteMonitorLite: remains an acceptable fallback only if UptimeRobot cannot be used and the reason is documented.

## Defense Checklist

- Show Jenkins has two jobs: `meta-container-ci-cd` and `meta-monitoring`.
- Show `meta-container-ci-cd` uses `Jenkinsfile` and has no `H/5` monitoring cron.
- Show `meta-monitoring` is a Freestyle project.
- Show `meta-monitoring` has trigger `Build periodically` with schedule `H/5 * * * *`.
- Show `meta-monitoring` has an Execute shell step that runs `./scripts/run-monitoring-check`.
- Show `meta-monitoring` archives `output/monitoring/**/*`.
- Open a scheduled `meta-monitoring` build and show `Started by timer`.
- Show the console log contains the monitoring script and does not contain Maven, `scripts/deploy-war`, Playwright, or Gatling commands.
- Open or download `output/monitoring/latest-check.txt` from the monitoring job artifacts.
- Show the official UptimeRobot or SiteMonitorLite passed monitor screenshot for the final submission evidence.
