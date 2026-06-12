---
goal: AWS EC2 Tomcat-Only Public App Bonus Evidence
version: 5.0
date_created: 2026-06-11
last_updated: 2026-06-12
owner: Project team
status: "In progress"
tags:
  - infrastructure
  - aws
  - ec2
  - public-vm
  - public-ip
  - tomcat
  - bonus
  - monitoring
  - devops-final-project
---

# AWS EC2 Tomcat-Only Public App Bonus Evidence

![Status: In progress](https://img.shields.io/badge/status-In%20progress-yellow)

This plan captures the optional public-IP bonus by deploying only the existing MeTA Tomcat web application on a short-lived AWS EC2 VM. Jenkins stays local/private and is not deployed to EC2. The EC2 VM exists only to expose the Tomcat application through a real public IPv4 address or AWS public DNS name long enough to capture public monitor, Playwright, and Gatling evidence. The user has `$100` AWS credit and accepts an estimated `$10-$20` evidence window, but the plan must avoid unnecessary AWS services and terminate resources immediately after evidence capture.

## 1. Requirements & Constraints

- **REQ-001**: Use AWS EC2 as the primary public bonus path because it best matches the PDF wording "public IP".
- **REQ-002**: Deploy only Tomcat and the WAR-backed web application on EC2. Do not deploy Jenkins on EC2.
- **REQ-003**: Expose the application, not Jenkins, through a real public IPv4 address or AWS public DNS name.
- **REQ-004**: Use public application URL format `http://<EC2_PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` unless AWS public DNS is selected.
- **REQ-005**: Keep local base evidence for `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`; public bonus evidence does not replace the required local Tomcat screenshot.
- **REQ-006**: Run UptimeRobot or SiteMonitorLite against the public EC2 Tomcat application URL.
- **REQ-007**: Run public-target Playwright, Gatling max-limit, Gatling 5-minute load, and Gatling 5-minute stress evidence against the same public EC2 Tomcat URL before claiming the bonus.
- **REQ-008**: Keep Jenkins local/private. Jenkins may trigger public-target Playwright and Gatling with `APP_BASE_URL=<PUBLIC_APP_BASE_URL>`, but Jenkins must not be exposed from EC2.
- **REQ-009**: Use an EC2 security group with inbound `tcp/8080` public for Tomcat, inbound `tcp/22` restricted to the operator IP for SSH, and no inbound `tcp/8081`.
- **REQ-010**: Use the cheapest bootcamp-approved Ubuntu EC2 instance that can run Docker and the Tomcat container reliably.
- **REQ-011**: Do not use a load balancer, NAT Gateway, RDS, ECS, EKS, Auto Scaling Group, Elastic IP, or any additional paid AWS service unless explicitly approved later.
- **REQ-012**: Use AWS CLI v2 where available for setup evidence and resource cleanup, but preserve console fallback if the bootcamp account blocks CLI operations.
- **REQ-013**: Keep total AWS spend bounded by using a short evidence window and terminating the EC2 instance immediately after public evidence is captured.
- **REQ-014**: Record AWS region, instance type, AMI, public IPv4 or public DNS, security group rules, public app URL, monitor target, Playwright target, Gatling target, cost-control decisions, and evidence status in `docs/public-app-bonus.md`.
- **REQ-015**: Keep public bonus evidence separate from local base evidence using `output/public-app/` for screenshots, copied logs, and notes.
- **REQ-016**: Do not claim the public-IP bonus unless all required public-target evidence exists and uses the same public application URL.
- **SEC-001**: Do not commit AWS console credentials, AWS access keys, SSH private keys, Jenkins secrets, UptimeRobot credentials, SiteMonitorLite credentials, cookies, API keys, or sensitive screenshots.
- **SEC-002**: Do not expose Jenkins `tcp/8081` publicly to the internet.
- **SEC-003**: Restrict SSH `tcp/22` to the operator public IP wherever the bootcamp account allows source-IP restriction.
- **SEC-004**: Terminate the EC2 instance and release any public IPv4 or Elastic IP resource immediately after evidence capture.
- **SEC-005**: Do not paste, save, screenshot, or commit AWS access keys, session tokens, private key material, or full credential configuration output while using AWS CLI.
- **CON-001**: Read `AGENTS.md`, `contribution.md`, and `rules/compliance.md` before implementation.
- **CON-002**: Preserve filename `docs/plans/10-aws-ec2-public-vm-bonus.md` for numbered plan continuity.
- **CON-003**: Use branch `feature/10-aws-ec2-public-vm-bonus` for this plan unless the user explicitly requests another branch.
- **CON-004**: Do not run Gatling directly as the agent. If Gatling validation is needed, ask the user to run the required Gatling or Jenkins command and provide output or artifacts.
- **CON-005**: Do not replace the containerized project track with host Tomcat, host Jenkins, `/usr/local/tomcat8`, or `/Users/yonatan/.jenkins`.
- **CON-006**: Remove Render deployment files from this branch; Render is no longer the selected path.
- **GUD-001**: Prefer EC2 because it provides the strongest public-IP evidence story for the assignment bonus.
- **GUD-002**: Prefer the cheapest viable VM because the EC2 host runs only Tomcat, not Jenkins, Playwright, or Gatling.
- **GUD-003**: Prefer running Gatling from local/private Jenkins against EC2 instead of running the load generator on the EC2 Tomcat host.
- **GUD-004**: Prefer AWS CloudShell or local AWS CLI for fast verification and cleanup commands.
- **PAT-001**: Follow existing repository patterns: source-controlled scripts in `scripts/`, documentation in `docs/`, implementation plans in `docs/plans/`, closeout in `docs/changelog/`, and generated evidence under ignored `output/`.
- **PAT-002**: Keep public bonus evidence labels explicit by including the public app URL in screenshots, logs, monitor configuration, and documentation wherever possible.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Pivot Plan 10 back from Render to AWS EC2 Tomcat-only.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Run `rtk git status` and confirm branch `feature/10-aws-ec2-public-vm-bonus`. | ✅ | 2026-06-12 |
| TASK-002 | Read `AGENTS.md`, `contribution.md`, `rules/compliance.md`, and `docs/plans/10-aws-ec2-public-vm-bonus.md` before editing implementation files. | ✅ | 2026-06-12 |
| TASK-003 | Delete `Dockerfile.render`, `.dockerignore`, and `render.yaml` because Render is no longer the selected public hosting path. | ✅ | 2026-06-12 |
| TASK-004 | Rewrite `docs/plans/10-aws-ec2-public-vm-bonus.md` so EC2 Tomcat-only is primary and Jenkins-on-EC2 is prohibited. | ✅ | 2026-06-12 |
| TASK-005 | Rewrite `docs/public-app-bonus.md` so it tracks AWS EC2 Tomcat-only public evidence and cost controls. | ✅ | 2026-06-12 |

### Implementation Phase 2

- GOAL-002: Prepare the lowest-cost AWS EC2 Tomcat host.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-006 | Confirm AWS region, default VPC, selected security group, and operator public IP in `docs/public-app-bonus.md`. |  |  |
| TASK-007 | Create or verify security group rule `tcp/22` from the operator public IP only. |  |  |
| TASK-008 | Create or verify security group rule `tcp/8080` from `0.0.0.0/0` for public Tomcat access. |  |  |
| TASK-009 | Verify the security group has no public `tcp/8081` rule. |  |  |
| TASK-010 | Select the cheapest bootcamp-approved Ubuntu EC2 instance type that can run Docker and one Tomcat container. |  |  |
| TASK-011 | Launch one EC2 Ubuntu instance with public IPv4 or public DNS enabled and the selected security group attached. |  |  |
| TASK-012 | Record instance ID, AMI, instance type, public IPv4 or DNS, and estimated cost controls in `docs/public-app-bonus.md`. |  |  |

### Implementation Phase 3

- GOAL-003: Deploy only Tomcat and the WAR on EC2.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-013 | SSH into the EC2 instance with the bootcamp-approved key or credential flow. |  |  |
| TASK-014 | Install Docker Engine, Docker Compose plugin, Git, and curl on the EC2 instance. |  |  |
| TASK-015 | Clone `https://github.com/y0ncha/meta-final-project.git` onto the EC2 instance. |  |  |
| TASK-016 | Check out the commit or branch selected for final evidence and record `git rev-parse HEAD` in `docs/public-app-bonus.md`. |  |  |
| TASK-017 | Start only the Tomcat service with `docker compose up -d tomcat`; do not start the Jenkins service on EC2. |  |  |
| TASK-018 | Deploy the WAR on EC2 with `./scripts/deploy-war`. |  |  |
| TASK-019 | Verify from the EC2 instance that `curl -fsS http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ >/dev/null` passes. |  |  |
| TASK-020 | Verify externally that `http://<EC2_PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` or the public DNS equivalent loads. |  |  |
| TASK-021 | Record the public URL and verification result in `docs/public-app-bonus.md`. |  |  |

### Implementation Phase 4

- GOAL-004: Capture public-target evidence without running Jenkins on EC2.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-022 | Define `PUBLIC_APP_BASE_URL=http://<EC2_PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` in `docs/public-app-bonus.md`, or use AWS public DNS if DNS is selected. |  |  |
| TASK-023 | Configure UptimeRobot or SiteMonitorLite with `PUBLIC_APP_BASE_URL`, interval `5 minutes`, and monitor type `HTTP(s)`. |  |  |
| TASK-024 | Capture monitor passed/up screenshot showing monitor tool name, public target URL, configured cadence, and pass/up state. |  |  |
| TASK-025 | Configure local/private Jenkins or local public-target execution so Playwright and Gatling use `APP_BASE_URL=<PUBLIC_APP_BASE_URL>`. |  |  |
| TASK-026 | Run Playwright against `APP_BASE_URL=<PUBLIC_APP_BASE_URL>` through Jenkins or `scripts/run-playwright-container` and capture passed-run evidence. |  |  |
| TASK-027 | Ask the user to run Jenkins job `meta-container-ci-cd` or the approved Gatling runner with `RUN_GATLING_MAX_LIMIT=true` and `APP_BASE_URL=<PUBLIC_APP_BASE_URL>` for public max-limit evidence. |  |  |
| TASK-028 | Ask the user to run Jenkins job `meta-container-ci-cd` or the approved Gatling runner with `APP_BASE_URL=<PUBLIC_APP_BASE_URL>` for 5-minute load and 5-minute stress evidence. |  |  |
| TASK-029 | Record public Gatling result summaries in `docs/public-app-bonus.md` using only values from generated logs or reports. |  |  |

### Implementation Phase 5

- GOAL-005: Shut down AWS resources and close out evidence.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-030 | Terminate the EC2 instance immediately after public evidence capture. |  |  |
| TASK-031 | Verify no Elastic IP, load balancer, NAT Gateway, or extra paid resource remains. |  |  |
| TASK-032 | Update `docs/submission.md` to keep local base evidence and public EC2 bonus evidence separate. |  |  |
| TASK-033 | Update `docs/public-app-bonus.md` with final evidence paths, commands, screenshots, public URL, selected path, cost-control notes, and remaining risks. |  |  |
| TASK-034 | Create or update `docs/changelog/10-aws-ec2-public-vm-bonus.changelog.md` with implementation, validation, date, and remaining risks. |  |  |
| TASK-035 | Run `git diff --check`. |  |  |
| TASK-036 | Run `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md` and manually review public-IP evidence warnings. |  |  |
| TASK-037 | Run `rtk git status` and confirm Plan 10 changes are scoped. |  |  |

## 3. Alternatives

- **ALT-001**: Use Render as the primary path. Rejected because it exposes a public URL, not a literal public IP, and free-tier behavior can compromise Gatling graphs.
- **ALT-002**: Deploy Jenkins on EC2. Rejected because the bonus target is the public website, and Jenkins on EC2 increases cost, memory pressure, and security risk.
- **ALT-003**: Run Gatling on the EC2 Tomcat host. Rejected because it distorts performance results by making the load generator compete with Tomcat for CPU and memory.
- **ALT-004**: Use a load balancer or Auto Scaling Group. Rejected because one short-lived Tomcat VM is sufficient and cheaper for evidence capture.
- **ALT-005**: Use home router port forwarding. Rejected as primary because it depends on ISP/router/laptop availability and is weaker than a real EC2 public IP.
- **ALT-006**: Reuse local `localhost` evidence for the bonus claim. Rejected because bullets 6 through 10 must target the public application URL.

## 4. Dependencies

- **DEP-001**: AWS bootcamp credentials with permission to launch or use EC2.
- **DEP-002**: Bootcamp-approved AWS region, EC2 instance type, AMI, key pair, and security group capabilities.
- **DEP-003**: Public IPv4 or AWS public DNS assigned to the EC2 instance.
- **DEP-004**: SSH access from the operator machine to the EC2 instance.
- **DEP-005**: Docker Engine, Docker Compose plugin, Git, and curl installed on the EC2 instance.
- **DEP-006**: Public GitHub repository `https://github.com/y0ncha/meta-final-project.git`.
- **DEP-007**: Existing source-controlled Docker Compose stack with service `tomcat`.
- **DEP-008**: UptimeRobot account access, or SiteMonitorLite access if UptimeRobot is blocked.
- **DEP-009**: Browser access from outside the EC2 instance to verify public reachability.
- **DEP-010**: User-provided Jenkins/Gatling artifacts are required because the agent must not run Gatling directly.
- **DEP-011**: AWS CloudShell or local AWS CLI v2 access is optional but preferred for metadata, security-group evidence, and cleanup verification.

## 5. Files

- **FILE-001**: `docs/plans/10-aws-ec2-public-vm-bonus.md` - this AWS EC2 Tomcat-only implementation plan.
- **FILE-002**: `docs/public-app-bonus.md` - selected AWS setup details, public URL, evidence paths, validation results, cost controls, and bonus claim status.
- **FILE-003**: `docs/submission.md` - submission-facing separation between local base evidence and public EC2 bonus evidence.
- **FILE-004**: `docs/changelog/10-aws-ec2-public-vm-bonus.changelog.md` - closeout record for this plan.
- **FILE-005**: `output/public-app/` - ignored local evidence staging directory for screenshots, copied Jenkins logs, public URL notes, and manual artifacts.
- **FILE-006**: `scripts/deploy-war` - existing WAR deployment script used on EC2 after starting only Tomcat.
- **FILE-007**: `scripts/run-playwright-container` - existing Playwright runner used with public `APP_BASE_URL`.
- **FILE-008**: `scripts/run-gatling-container`, `scripts/run-gatling-max-limit`, `scripts/run-gatling-load-5m`, and `scripts/run-gatling-stress-5m` - existing Gatling runners invoked by local/private Jenkins or user-approved manual execution for public-target evidence.
- **FILE-009**: `docker-compose.yml` - existing container orchestration; use only service `tomcat` on EC2.

## 6. Testing

- **TEST-001**: `rtk git status` must show branch `feature/10-aws-ec2-public-vm-bonus`; Plan 10 changes must be scoped.
- **TEST-002**: AWS EC2 console or AWS CLI output must show one running VM in the selected region with a public IPv4 or public DNS.
- **TEST-003**: EC2 security group must expose inbound `tcp/8080` publicly and must not expose inbound `tcp/8081` publicly, verified by AWS CLI output or console evidence.
- **TEST-004**: EC2 security group must restrict inbound `tcp/22` to the operator IP wherever the bootcamp account permits it.
- **TEST-005**: On EC2, `docker --version` must print an installed Docker version.
- **TEST-006**: On EC2, `docker compose version` must print an installed Compose plugin version.
- **TEST-007**: On EC2, `docker compose up -d tomcat` must start only Tomcat.
- **TEST-008**: On EC2, `docker compose ps` must not show the Jenkins service running.
- **TEST-009**: On EC2, `./scripts/deploy-war` must pass from the repository root.
- **TEST-010**: On EC2, `curl -fsS http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ >/dev/null` must pass.
- **TEST-011**: From an external browser or network, `http://<EC2_PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` or the public DNS equivalent must load.
- **TEST-012**: UptimeRobot or SiteMonitorLite must show a passed/up monitor for `PUBLIC_APP_BASE_URL` at a 5-minute cadence.
- **TEST-013**: Playwright public-target run must pass with the same five validations as `tests/playwright/meta-functional.spec.js`.
- **TEST-014**: Public Gatling max-limit evidence must include log, HTML report, PDF report, and terminal or Jenkins-console screenshot.
- **TEST-015**: Public Gatling 5-minute load evidence must include log, HTML report, PDF report, and terminal or Jenkins-console screenshot.
- **TEST-016**: Public Gatling 5-minute stress evidence must include log, HTML report, PDF report, and terminal or Jenkins-console screenshot.
- **TEST-017**: `docs/public-app-bonus.md` must list the selected path, AWS details, public URL, cost-control decisions, and evidence path for every public bonus artifact.
- **TEST-018**: AWS console or AWS CLI cleanup verification must show the EC2 instance is terminated and no Elastic IP, load balancer, NAT Gateway, or extra paid resource remains.
- **TEST-019**: `docs/submission.md` must not treat public bonus evidence as a replacement for the required local `localhost:8080/...` screenshot.
- **TEST-020**: `git diff --check` must pass.
- **TEST-021**: `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md` must pass with no failures; manual public-IP evidence items must be documented.
- **TEST-022**: No Gatling command may be run directly by the agent while validating this plan; Gatling execution must be performed by the user through Jenkins or by a user-approved manual command outside the agent workflow.

## 7. Risks & Assumptions

- **RISK-001**: AWS bootcamp accounts can restrict regions, instance types, public IPv4 assignment, key pairs, security group rules, or service availability.
- **RISK-002**: Even small AWS resources cost money if left running; cleanup verification is mandatory.
- **RISK-003**: Very small EC2 instances can run out of memory if anything beyond Tomcat is started.
- **RISK-004**: Public IPv4 address or public DNS can change if the instance is stopped and restarted.
- **RISK-005**: Public network latency can change Gatling response-time graphs; graph explanations must describe the observed public-run behavior.
- **RISK-006**: UptimeRobot may need several minutes to show a clean passed state after monitor creation.
- **RISK-007**: Exposing Jenkins publicly creates avoidable security risk; Jenkins must stay local/private.
- **RISK-008**: The final submission deadline is 2026-06-15 at midnight, so AWS setup troubleshooting time is limited.
- **RISK-009**: Cost estimates can drift by region, instance type, traffic volume, or forgotten resources; keep the evidence window short and verify cleanup.
- **ASSUMPTION-001**: The app context path remains `/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **ASSUMPTION-002**: Local Tomcat remains reachable at `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **ASSUMPTION-003**: Local/private Jenkins can run or trigger Playwright and Gatling with `APP_BASE_URL` set to the public EC2 application URL.
- **ASSUMPTION-004**: UptimeRobot remains acceptable as the official availability monitor unless explicitly replaced by the instructor.
- **ASSUMPTION-005**: The instructor accepts AWS EC2 public IPv4 or AWS public DNS evidence as satisfying the public-IP bonus wording.
- **ASSUMPTION-006**: The user accepts a short AWS spend window if expected cost remains within roughly `$10-$20`.

## 8. Related Specifications / Further Reading

- [Project contribution workflow](../../contribution.md)
- [Project compliance rules](../../rules/compliance.md)
- [Submission checklist](../submission.md)
- [Jenkins documentation](../jenkins.md)
- [Monitoring documentation](../monitoring.md)
- [Playwright documentation](../playwright.md)
- [Gatling documentation](../gatling.md)
- [UptimeRobot monitor setup documentation](https://uptimerobot.com/help/)
- [Amazon EC2 documentation](https://docs.aws.amazon.com/ec2/)
- [AWS CLI v2 documentation](https://docs.aws.amazon.com/cli/latest/userguide/)
