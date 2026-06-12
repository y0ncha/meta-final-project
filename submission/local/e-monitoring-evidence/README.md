# Item E - Monitoring Evidence

- Status: missing
- Assignment item: `e) Name of monitor tool you used, what did you monitor and a screenshot of your monitor passed`
- Required tool evidence: UptimeRobot or approved monitor UI screenshot showing target and up/pass state
- Required Jenkins evidence: separate Freestyle job `meta-monitoring` scheduled run every 5 minutes

No final local/base monitor UI screenshot is packaged yet. Current script checks found under `submission/public/public-jenkins-monitoring-check/` target the public EC2 URL and are classified as public evidence, not local evidence.
