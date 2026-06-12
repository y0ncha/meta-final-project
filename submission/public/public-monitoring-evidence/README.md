# Public Monitoring UI Evidence

- Status: ready
- Required target: `http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
- Monitor tools used: UptimeRobot dashboard and Jenkins Freestyle job `meta-monitoring`
- Jenkins schedule: every 5 minutes
- Jenkins validation: timer-started monitoring job checks the public Tomcat URL, writes `output/monitoring/latest-check.txt`, archives the artifact, and finishes `SUCCESS`

## Packaged Screenshots

- `uptimerobot-dashboard.png` - public monitor dashboard evidence.
- `jenkins-monitoring-build-history.png` - public monitoring build history showing repeated successful `meta-monitoring` runs, including the recent public URL checks.
- `jenkins-public-monitoring-console-success.png` - shows `Started by timer`, the public IP `APP_BASE_URL`, `Monitoring check passed`, artifact archiving, and `Finished: SUCCESS`.

The public script check is also packaged separately under `submission/public/public-jenkins-monitoring-check/`.
