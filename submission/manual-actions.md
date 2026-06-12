# Manual Actions Needed

These actions require the user because they involve external UI screenshots, final public checks, or Gatling runs that the agent must not run directly.

## Required For The Base Submission

1. Capture or confirm the final GitHub screenshot after the final `main` push if you want it to show the latest commit.
   - Current packaged file: `submission/local/b-github-screenshot/github-jsp.png`
   - Required content: public GitHub repo showing `src/main/webapp/index.jsp`.
2. Confirm the public GitHub repository opens without authentication.
   - Packaged link: `submission/local/d-github-public-link/github-public-repo.link`
3. Capture official monitor UI evidence.
   - Target folder: `submission/local/e-monitoring-evidence/`
   - Required content: UptimeRobot or approved monitor name, monitored URL, 5-minute cadence if visible, and up/pass state.
4. Capture final `meta-monitoring` Freestyle scheduled-build evidence if Jenkins is available.
   - Target folder: `submission/local/e-monitoring-evidence/`
   - Required content: console log or screenshot showing the separate job `meta-monitoring` ran `./scripts/run-monitoring-check`.
5. Capture three Gatling terminal/CMD summary screenshots.
   - Target folder: `submission/local/k-gatling-cmd-screenshots/`
   - Required filenames: `max-limit-terminal.png`, `load-5m-terminal.png`, `stress-5m-terminal.png`.
6. Decide whether the current max-limit evidence is acceptable as a tested lower bound.
   - Current packaged folder: `submission/local/j-gatling-max-limit/`
   - If you need a real maximum, run the approved Jenkins or runner max-limit flow until a passing level is followed by a failing level.

## Optional Public-IP Bonus

1. Capture public Tomcat browser screenshot.
   - Target folder: `submission/public/public-tomcat-screenshot/`
   - Required URL: `http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
2. Capture official public monitor UI evidence.
   - Target folder: `submission/public/public-monitoring-evidence/`
3. Run public-target Gatling max-limit, load, and stress through the approved Jenkins or runner flow.
   - Do not ask the agent to run Gatling directly.
   - Required target: `APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`
4. Capture public-target Gatling terminal/CMD or Jenkins-console screenshots.
5. Terminate the EC2 instance, release the Elastic IP if allocated, and record cleanup verification in `submission/public/aws-cleanup-verification/cleanup.md`.
