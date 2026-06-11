---
goal: Public App Exposure Bonus Evidence
version: 2.0
date_created: 2026-06-11
last_updated: 2026-06-11
owner: Project team
status: "Planned"
tags:
  - infrastructure
  - public-app
  - port-forwarding
  - public-vm
  - bonus
  - monitoring
  - devops-final-project
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

This plan captures the optional public-IP bonus by exposing the MeTA Tomcat application to the internet and running assignment bullets 6 through 10 against that public application target. The primary free path is home router port-forwarding from a public IP to the local Tomcat container. A public VM remains the fallback only when home public IP exposure is blocked by CGNAT, router restrictions, ISP restrictions, or unreliable local availability. Jenkins must stay private or access-restricted in both paths.

## 1. Requirements & Constraints

- **REQ-001**: Expose the application, not Jenkins, through a real public IP.
- **REQ-002**: Use public application URL format `http://<PUBLIC_IP>:8080/MeTA/` unless a DNS name is explicitly configured.
- **REQ-003**: Run UptimeRobot, Jenkins monitoring, Playwright, Gatling max-limit, Gatling 5-minute load, and Gatling 5-minute stress against the public application URL.
- **REQ-004**: Keep local base evidence for `http://localhost:8080/MeTA/`; public bonus evidence does not replace the required local Tomcat screenshot.
- **REQ-005**: Keep Jenkins private or access-restricted. Do not expose Jenkins `8081` to `0.0.0.0/0`.
- **REQ-006**: Use Path A home port-forwarding as the primary free implementation path.
- **REQ-007**: Use Path B public VM only if Path A is blocked or too unstable for evidence capture.
- **REQ-008**: For Path A, keep Tomcat and Jenkins running on the project laptop through the existing Docker Compose stack.
- **REQ-009**: For Path A, configure router port forwarding `public tcp/8080 -> laptop tcp/8080`.
- **REQ-010**: For Path A, keep Jenkins at `http://localhost:8081/` and configure jobs to target `APP_BASE_URL=http://<HOME_PUBLIC_IP>:8080/MeTA/`.
- **REQ-011**: For Path A, configure UptimeRobot URL `http://<HOME_PUBLIC_IP>:8080/MeTA/` with interval `5 minutes`.
- **REQ-012**: For Path B, deploy the same Docker Compose stack on a Linux VM only after Path A fails validation.
- **REQ-013**: For Path B, expose VM Tomcat on `tcp/8080` and restrict VM Jenkins `tcp/8081` to the operator IP or SSH tunnel.
- **REQ-014**: Record the selected path, public IP, public URL, monitor target, Jenkins target configuration, and evidence status in `docs/public-app-bonus.md`.
- **REQ-015**: Keep public bonus evidence separate from local base evidence using `output/public-app/` for screenshots, copied logs, and notes.
- **REQ-016**: Do not claim the public-IP bonus unless all required public-target evidence exists and uses the same public application URL.
- **REQ-017**: Create or update `docs/changelog/10-public-vm-bonus.changelog.md` when this plan is implemented, abandoned, or superseded.
- **SEC-001**: Do not commit router admin credentials, cloud credentials, SSH private keys, Jenkins secrets, UptimeRobot credentials, API keys, cookies, or IP-revealing screenshots beyond what is required for submission evidence.
- **SEC-002**: For Path A, do not forward router port `8081` to Jenkins.
- **SEC-003**: For Path A, restrict laptop firewall exposure to Tomcat port `8080` only for the evidence window.
- **SEC-004**: For Path B, restrict SSH `tcp/22` and Jenkins `tcp/8081` to the operator public IP or use SSH tunneling.
- **CON-001**: Read `AGENTS.md`, `contribution.md`, and `rules/compliance.md` before implementation.
- **CON-002**: Preserve filename `docs/plans/10-public-vm-bonus.md` for numbered plan continuity even though the goal is now public app exposure.
- **CON-003**: Use branch `feature/10-public-vm-bonus` for this plan unless the user explicitly requests another branch.
- **CON-004**: Do not run Gatling directly as the agent. If Gatling validation is needed, ask the user to run the required Gatling or Jenkins command and provide output or artifacts.
- **CON-005**: Do not replace the containerized project track with host Tomcat, host Jenkins, `/usr/local/tomcat8`, or `/Users/yonatan/.jenkins`.
- **CON-006**: Do not use Vercel, Netlify, Render, or another PaaS path as the primary solution because those paths weaken the Tomcat, Jenkins, WAR, and public-IP evidence story.
- **CON-007**: User approved the existing dirty tree on 2026-06-11; leave out-of-scope Plan 09 polling edits in `Jenkinsfile`, `docs/jenkins.md`, and `docs/changelog/09-monitoring-and-jenkins-schedule.changelog.md` untouched while editing Plan 10.
- **GUD-001**: Prefer the lowest-cost implementation that satisfies the PDF: Path A costs no cloud money and is the default.
- **GUD-002**: Prefer Path B only when Path A fails because the ISP uses CGNAT, the router cannot forward ports, the laptop cannot stay awake, or the public target is unstable.
- **PAT-001**: Follow existing repository patterns: source-controlled scripts in `scripts/`, documentation in `docs/`, implementation plans in `docs/plans/`, closeout in `docs/changelog/`, and generated evidence under ignored `output/`.
- **PAT-002**: Keep public bonus evidence labels explicit by including the public app URL in screenshots, logs, monitor configuration, and documentation wherever possible.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Select the public exposure path and prepare the evidence record.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Run `rtk git status` and confirm branch `feature/10-public-vm-bonus`; record that existing Plan 09 polling edits are user-approved and out of scope for Plan 10. |  |  |
| TASK-002 | Read `AGENTS.md`, `contribution.md`, `rules/compliance.md`, `docs/plans/10-public-vm-bonus.md`, and `docs/changelog/` before editing implementation files. |  |  |
| TASK-003 | Create or update `docs/public-app-bonus.md` with fields `selected_path`, `home_router_wan_ip`, `external_public_ip`, `public_app_url`, `router_forward_rule`, `jenkins_access_mode`, `uptimerobot_target`, `playwright_target`, `gatling_target`, `bonus_claim_status`, and `remaining_blockers`. |  |  |
| TASK-004 | Keep `output/public-app/` ignored through existing `.gitignore` rule `output/**`; do not add a tracked `.gitkeep` unless repository policy changes. |  |  |

### Implementation Phase 2

- GOAL-002: Validate Path A home port-forwarding eligibility.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-005 | Determine the external public IPv4 by visiting a public IP checker or running a trusted external lookup outside this plan. |  |  |
| TASK-006 | Determine the router WAN or Internet IPv4 from the router admin UI. |  |  |
| TASK-007 | Compare external public IPv4 and router WAN IPv4; mark Path A eligible only if they match or the ISP confirms direct public IPv4 routing. |  |  |
| TASK-008 | Mark Path A blocked if router WAN IPv4 is in `10.0.0.0/8`, `100.64.0.0/10`, `172.16.0.0/12`, or `192.168.0.0/16`. |  |  |
| TASK-009 | Confirm the laptop can remain awake, connected, and running Docker for the full evidence window. |  |  |
| TASK-010 | If TASK-007 through TASK-009 pass, set `selected_path=home-port-forwarding` in `docs/public-app-bonus.md`; otherwise set `selected_path=public-vm-fallback`. |  |  |

### Implementation Phase 3

- GOAL-003: Implement Path A by exposing local Tomcat through home router port-forwarding.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-011 | Start or confirm local Docker Compose services `tomcat` and `jenkins` with `docker compose up -d tomcat jenkins`. |  |  |
| TASK-012 | Deploy the WAR locally with `./scripts/deploy-war` and confirm `http://localhost:8080/MeTA/` responds. |  |  |
| TASK-013 | Configure router port-forward rule `external tcp/8080 -> laptop_lan_ip tcp/8080`. |  |  |
| TASK-014 | Configure laptop firewall to allow inbound `tcp/8080` for the evidence window if the operating system blocks inbound traffic. |  |  |
| TASK-015 | From a non-home network, verify `http://<HOME_PUBLIC_IP>:8080/MeTA/` loads in a browser. |  |  |
| TASK-016 | Record the public URL, router rule, and verification result in `docs/public-app-bonus.md`. |  |  |

### Implementation Phase 4

- GOAL-004: Use Path B public VM fallback only when Path A is blocked.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-017 | Execute this phase only if `selected_path=public-vm-fallback` in `docs/public-app-bonus.md`. |  |  |
| TASK-018 | Provision one Linux VM using Ubuntu LTS or another Docker-supported Linux image. |  |  |
| TASK-019 | Configure VM firewall rule `tcp/22` from the operator public IP only. |  |  |
| TASK-020 | Configure VM firewall rule `tcp/8080` for public Tomcat access to `http://<VM_PUBLIC_IP>:8080/MeTA/`. |  |  |
| TASK-021 | Keep VM Jenkins `tcp/8081` closed, restricted to the operator public IP, or accessed through SSH tunnel `ssh -L 8081:localhost:8081 <vm-user>@<VM_PUBLIC_IP>`. |  |  |
| TASK-022 | Install Docker Engine, Docker Compose plugin, Git, and curl on the VM. |  |  |
| TASK-023 | Clone `https://github.com/y0ncha/meta-final-project.git`, checkout the selected branch or commit, run `docker compose up -d tomcat jenkins`, and run `./scripts/deploy-war`. |  |  |
| TASK-024 | From outside the VM, verify `http://<VM_PUBLIC_IP>:8080/MeTA/` loads in a browser. |  |  |
| TASK-025 | Record VM provider, region, image, size, public IP, firewall rules, selected commit, and verification result in `docs/public-app-bonus.md`. |  |  |

### Implementation Phase 5

- GOAL-005: Configure monitoring and Jenkins jobs to target the public application URL.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-026 | Define canonical public target variable `PUBLIC_APP_BASE_URL=http://<PUBLIC_IP>:8080/MeTA/` in `docs/public-app-bonus.md`. |  |  |
| TASK-027 | Configure UptimeRobot monitor with URL `PUBLIC_APP_BASE_URL`, interval `5 minutes`, and monitor type `HTTP(s)`. |  |  |
| TASK-028 | Capture UptimeRobot passed/up screenshot showing monitor name, public target URL, and pass/up state. |  |  |
| TASK-029 | Configure Jenkins Freestyle job `meta-monitoring` command `APP_BASE_URL=<PUBLIC_APP_BASE_URL> ./scripts/run-monitoring-check` and archive pattern `output/monitoring/**/*`. |  |  |
| TASK-030 | Capture Jenkins `meta-monitoring` successful build evidence showing public `APP_BASE_URL` and archived `output/monitoring/latest-check.txt`. |  |  |
| TASK-031 | Configure Jenkins job `meta-container-ci-cd` or manual runner environment so Playwright and Gatling stages use `APP_BASE_URL=<PUBLIC_APP_BASE_URL>`. |  |  |

### Implementation Phase 6

- GOAL-006: Produce public-target browser and performance evidence without inventing results.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-032 | Run Playwright against `APP_BASE_URL=<PUBLIC_APP_BASE_URL>` through Jenkins or `scripts/run-playwright-container` and capture passed-run evidence. |  |  |
| TASK-033 | Capture Playwright screenshot evidence under `output/playwright/` or `output/public-app/playwright/` and label it as public-target evidence in `docs/public-app-bonus.md`. |  |  |
| TASK-034 | Ask the user to run Jenkins job `meta-container-ci-cd` with `RUN_GATLING_MAX_LIMIT=true` and `APP_BASE_URL=<PUBLIC_APP_BASE_URL>` for public max-limit evidence. |  |  |
| TASK-035 | Ask the user to run Jenkins job `meta-container-ci-cd` with `APP_BASE_URL=<PUBLIC_APP_BASE_URL>` for 5-minute load and 5-minute stress evidence. |  |  |
| TASK-036 | Collect Gatling public max-limit log, HTML report, PDF report, and terminal or Jenkins-console screenshot. |  |  |
| TASK-037 | Collect Gatling public load-test log, HTML report, PDF report, and terminal or Jenkins-console screenshot. |  |  |
| TASK-038 | Collect Gatling public stress-test log, HTML report, PDF report, and terminal or Jenkins-console screenshot. |  |  |
| TASK-039 | Record public Gatling result summaries in `docs/public-app-bonus.md` using only values from generated logs or reports. |  |  |

### Implementation Phase 7

- GOAL-007: Validate, document, and close out the public app exposure bonus plan.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-040 | Update `docs/submission.md` to keep local base evidence and public bonus evidence separate. |  |  |
| TASK-041 | Update `docs/public-app-bonus.md` with final evidence paths, commands, screenshots, public URL, selected path, and remaining risks. |  |  |
| TASK-042 | Create or update `docs/changelog/10-public-vm-bonus.changelog.md` with what changed, why it changed, validation commands or artifacts, selected path, and remaining risks. |  |  |
| TASK-043 | Run `git diff --check`. |  |  |
| TASK-044 | Run `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md` and confirm zero failures. |  |  |
| TASK-045 | Run `rtk git status` and confirm Plan 10 changes are scoped while user-approved Plan 09 polling edits remain untouched. |  |  |

## 3. Alternatives

- **ALT-001**: Use only a public VM. Rejected as the primary path because it can add cloud cost and setup time when home port-forwarding can satisfy the PDF wording for free.
- **ALT-002**: Use Vercel, Netlify, Render, or another PaaS deployment. Rejected because those paths weaken the Tomcat `webapps`, WAR deployment, Jenkins, and public-IP evidence story.
- **ALT-003**: Expose Jenkins publicly with the application. Rejected because the bonus requires public application exposure, not public Jenkins access.
- **ALT-004**: Use ngrok, Cloudflare Tunnel, or another tunnel as the primary solution. Rejected because the PDF says public IP; tunnels can be a troubleshooting aid but are weaker evidence unless explicitly approved.
- **ALT-005**: Reuse local `localhost` evidence for the bonus claim. Rejected because bullets 6 through 10 must target the public application URL.
- **ALT-006**: Claim a max limit from a non-failing Gatling run. Rejected because `rules/compliance.md` forbids invented performance numbers; a non-failing run is only a tested lower bound.

## 4. Dependencies

- **DEP-001**: Existing local Docker Compose stack with services `tomcat` and `jenkins`.
- **DEP-002**: Router admin access for Path A.
- **DEP-003**: Home ISP must provide a routable public IPv4 for Path A.
- **DEP-004**: Laptop LAN IP must be stable during evidence capture for Path A.
- **DEP-005**: Laptop power, sleep, Wi-Fi, Docker, and Tomcat must remain stable during evidence capture for Path A.
- **DEP-006**: Public VM provider, SSH key, and firewall control are required only for Path B fallback.
- **DEP-007**: Public GitHub repository `https://github.com/y0ncha/meta-final-project.git` is required for VM fallback and Jenkins SCM setup.
- **DEP-008**: UptimeRobot account access is required for official public monitor evidence.
- **DEP-009**: Browser access from a network outside the hosting network is required to verify public reachability.
- **DEP-010**: User-provided Jenkins/Gatling artifacts are required because the agent must not run Gatling directly.

## 5. Files

- **FILE-001**: `docs/plans/10-public-vm-bonus.md` - this executable implementation plan, preserved under the original filename for numbering continuity.
- **FILE-002**: `docs/public-app-bonus.md` - selected path, setup details, public URL, evidence paths, validation results, and bonus claim status.
- **FILE-003**: `docs/submission.md` - submission checklist updated to separate local base evidence from public bonus evidence.
- **FILE-004**: `docs/changelog/10-public-vm-bonus.changelog.md` - closeout changelog for the public app exposure bonus work.
- **FILE-005**: `output/public-app/` - ignored local evidence staging directory for screenshots, copied Jenkins logs, public URL notes, and manual artifacts.
- **FILE-006**: `scripts/run-monitoring-check` - existing Jenkins Freestyle monitoring command used with public `APP_BASE_URL`.
- **FILE-007**: `scripts/run-playwright-container` - existing Playwright runner used with public `APP_BASE_URL`.
- **FILE-008**: `scripts/run-gatling-container`, `scripts/run-gatling-max-limit`, `scripts/run-gatling-load-5m`, and `scripts/run-gatling-stress-5m` - existing Gatling runners invoked by Jenkins for public-target evidence.
- **FILE-009**: `Jenkinsfile` - existing CI/CD Pipeline; edit only if public `APP_BASE_URL` cannot be injected through Jenkins configuration or command environment.

## 6. Testing

- **TEST-001**: `rtk git status` must show branch `feature/10-public-vm-bonus`; Plan 10 changes must be scoped, and user-approved Plan 09 polling edits may remain present but untouched.
- **TEST-002**: For Path A, external public IPv4 and router WAN IPv4 must match or ISP must confirm direct public IPv4 routing.
- **TEST-003**: For Path A, router port-forward rule `public tcp/8080 -> laptop tcp/8080` must exist.
- **TEST-004**: For Path A, `curl -fsS http://localhost:8080/MeTA/ >/dev/null` must pass on the laptop before public validation.
- **TEST-005**: For Path A, `http://<HOME_PUBLIC_IP>:8080/MeTA/` must load from a non-home network.
- **TEST-006**: For Path B, VM `docker --version` and `docker compose version` must print installed versions.
- **TEST-007**: For Path B, VM `docker compose up -d tomcat jenkins` must start services `tomcat` and `jenkins`.
- **TEST-008**: For Path B, VM `./scripts/deploy-war` must pass and the public app URL must load from outside the VM.
- **TEST-009**: UptimeRobot must show a passed/up monitor for `PUBLIC_APP_BASE_URL`.
- **TEST-010**: Jenkins job `meta-monitoring` must produce `output/monitoring/latest-check.txt` for public `APP_BASE_URL`.
- **TEST-011**: Playwright public-target run must pass with the same five validations as `tests/playwright/meta-functional.spec.js`.
- **TEST-012**: Public Gatling max-limit evidence must include log, HTML report, PDF report, and terminal or Jenkins-console screenshot.
- **TEST-013**: Public Gatling 5-minute load evidence must include log, HTML report, PDF report, and terminal or Jenkins-console screenshot.
- **TEST-014**: Public Gatling 5-minute stress evidence must include log, HTML report, PDF report, and terminal or Jenkins-console screenshot.
- **TEST-015**: `docs/public-app-bonus.md` must list the selected path, public URL, and evidence path for every public bonus artifact.
- **TEST-016**: `docs/submission.md` must not treat public bonus evidence as a replacement for the required local `localhost:8080/...` screenshot.
- **TEST-017**: `git diff --check` must pass.
- **TEST-018**: `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md` must pass with zero failures.
- **TEST-019**: No Gatling command may be run directly by the agent while validating this plan; Gatling execution must be performed by the user through Jenkins or by a user-approved manual command outside the agent workflow.

## 7. Risks & Assumptions

- **RISK-001**: Home port-forwarding is available only while the laptop, Docker, Tomcat, router, and ISP connection remain up.
- **RISK-002**: ISP CGNAT can make Path A impossible even when the router UI allows port-forward rules.
- **RISK-003**: Home public IP can change before UptimeRobot, Playwright, or Gatling evidence is captured.
- **RISK-004**: Laptop sleep, Wi-Fi roaming, firewall prompts, or Docker restarts can break Path A during evidence capture.
- **RISK-005**: Public VM fallback can create cost or setup delays if no free credit or free VM capacity is available.
- **RISK-006**: Public network latency can change Gatling response-time graphs; graph explanations must describe the observed public-run behavior instead of copying local-run explanations.
- **RISK-007**: UptimeRobot may need several minutes to show a clean passed state after monitor creation.
- **RISK-008**: Exposing Jenkins publicly creates avoidable security risk; keep Jenkins private, restricted, or tunneled.
- **RISK-009**: The final submission deadline is 2026-06-15 at midnight, so public exposure troubleshooting time is limited.
- **ASSUMPTION-001**: The app context path remains `/MeTA/`.
- **ASSUMPTION-002**: Local Tomcat remains reachable at `http://localhost:8080/MeTA/`.
- **ASSUMPTION-003**: Jenkins can run or trigger Playwright and Gatling with `APP_BASE_URL` set to the public application URL.
- **ASSUMPTION-004**: UptimeRobot remains acceptable as the official availability monitor.
- **ASSUMPTION-005**: The instructor accepts screenshots and Jenkins artifacts that clearly show the public target URL as public-IP bonus evidence.

## 8. Related Specifications / Further Reading

- [Project contribution workflow](../../contribution.md)
- [Project compliance rules](../../rules/compliance.md)
- [Submission checklist](../submission.md)
- [Jenkins documentation](../jenkins.md)
- [Monitoring documentation](../monitoring.md)
- [Playwright documentation](../playwright.md)
- [Gatling documentation](../gatling.md)
- [UptimeRobot monitor setup documentation](https://uptimerobot.com/help/)
