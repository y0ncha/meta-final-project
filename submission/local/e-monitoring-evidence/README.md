# Item E - Monitoring Evidence

- Status: ready
- Assignment item: `e) Name of monitor tool you used, what did you monitor and a screenshot of your monitor passed`
- Monitor tool used: Jenkins Freestyle job `meta-monitoring`
- What was monitored: local Tomcat deployment at `http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Schedule: every 5 minutes
- Validation: the monitor job runs `./scripts/run-monitoring-check`, checks the deployed app URL, writes `output/monitoring/latest-check.txt`, and finishes `SUCCESS`

## Packaged Screenshots

- `jenkins-monitoring-build-history.png` - shows repeated successful `meta-monitoring` builds at the 5-minute cadence.
- `jenkins-monitoring-console-success.png` - shows `Started by timer`, the clean monitoring command with no Git SCM checkout, the monitored Tomcat URL, `Monitoring check passed`, artifact archiving, and `Finished: SUCCESS`.
