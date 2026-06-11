---
goal: AWS EC2 Bootcamp Public VM Bonus Evidence
version: 3.0
date_created: 2026-06-11
last_updated: 2026-06-11
owner: Project team
status: "Planned"
tags:
  - infrastructure
  - aws
  - ec2
  - public-vm
  - public-ip
  - bonus
  - monitoring
  - devops-final-project
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

This plan captures the optional public-IP bonus by deploying the existing containerized MeTA Tomcat and Jenkins stack on an AWS EC2 Ubuntu VM provided through the AWS bootcamp account. The public evidence target is the Tomcat application, not Jenkins. Jenkins remains private, IP-restricted, or reachable only through an SSH tunnel. Home router port forwarding is no longer the preferred path because it is weaker evidence and depends on the home ISP, router, laptop uptime, and changing IP behavior.

## 1. Requirements & Constraints

- **REQ-001**: Use AWS EC2 as the primary public VM path when the bootcamp account allows EC2 instance creation.
- **REQ-002**: Expose the application, not Jenkins, through a real public IPv4 address or AWS public DNS name.
- **REQ-003**: Use public application URL format `http://<EC2_PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` unless an AWS public DNS name or explicit DNS record is configured.
- **REQ-004**: Keep local base evidence for `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`; public bonus evidence does not replace the required local Tomcat screenshot.
- **REQ-005**: Run the official availability monitor against the public application URL with UptimeRobot by default, or SiteMonitorLite only if UptimeRobot is blocked and the reason is documented.
- **REQ-006**: Do not use a Jenkins scheduled availability check as the official 5-minute availability-monitor proof unless the instructor explicitly re-approves that design.
- **REQ-007**: Run public-target Playwright, Gatling max-limit, Gatling 5-minute load, and Gatling 5-minute stress evidence against the same public application URL before claiming the bonus.
- **REQ-008**: Keep Jenkins private or access-restricted. Do not expose Jenkins `8081` to `0.0.0.0/0`.
- **REQ-009**: Use an EC2 security group with inbound `tcp/8080` public for Tomcat, inbound `tcp/22` restricted to the operator IP for SSH, and inbound `tcp/8081` either absent, restricted to the operator IP, or replaced by SSH tunnel access.
- **REQ-010**: Use Ubuntu LTS or another Docker-supported Linux image approved by the bootcamp account.
- **REQ-011**: Install Docker Engine, Docker Compose plugin, Git, and curl on the EC2 VM.
- **REQ-012**: Clone the public GitHub repository `https://github.com/y0ncha/meta-final-project.git` onto the EC2 VM.
- **REQ-013**: Run the same source-controlled Docker Compose stack on EC2 instead of creating a separate cloud-specific deployment path.
- **REQ-014**: Record the AWS region, instance type, AMI, public IPv4 or public DNS, security group rules, SSH access mode, public app URL, monitor target, Jenkins target configuration, and evidence status in `docs/public-app-bonus.md`.
- **REQ-015**: Keep public bonus evidence separate from local base evidence using `output/public-app/` for screenshots, copied logs, and notes.
- **REQ-016**: Do not claim the public-IP bonus unless all required public-target evidence exists and uses the same public application URL.
- **REQ-017**: Create or update `docs/changelog/10-public-vm-bonus.changelog.md` when this plan is implemented, abandoned, or superseded.
- **REQ-018**: Before executing the monitoring portion, update `rules/compliance.md`, `docs/monitoring.md`, and any affected docs to reflect the instructor's latest clarification that Jenkins should not be used as the official 5-minute availability monitor.
- **SEC-001**: Do not commit AWS console credentials, AWS access keys, SSH private keys, Jenkins secrets, UptimeRobot credentials, SiteMonitorLite credentials, cookies, API keys, or sensitive screenshots.
- **SEC-002**: Do not expose Jenkins `tcp/8081` publicly to the internet.
- **SEC-003**: Restrict SSH `tcp/22` to the operator public IP wherever the bootcamp account allows source-IP restriction.
- **SEC-004**: Delete, stop, or otherwise clean up the EC2 VM after evidence capture if the bootcamp account has time, budget, or lab-lifecycle limits.
- **CON-001**: Read `AGENTS.md`, `contribution.md`, and `rules/compliance.md` before implementation.
- **CON-002**: Preserve filename `docs/plans/10-public-vm-bonus.md` for numbered plan continuity.
- **CON-003**: Use branch `feature/10-public-vm-bonus` for this plan unless the user explicitly requests another branch.
- **CON-004**: Do not run Gatling directly as the agent. If Gatling validation is needed, ask the user to run the required Gatling or Jenkins command and provide output or artifacts.
- **CON-005**: Do not replace the containerized project track with host Tomcat, host Jenkins, `/usr/local/tomcat8`, or `/Users/yonatan/.jenkins`.
- **CON-006**: Do not use Vercel, Netlify, Render, or another PaaS path as the primary solution because those paths weaken the Tomcat, Jenkins, WAR, and public-IP evidence story.
- **CON-007**: Treat home router port forwarding as a weak fallback only, not as the default plan.
- **GUD-001**: Prefer EC2 because AWS bootcamp credentials are available and EC2 is the standard AWS VM service most likely to be allowed in a managed lab account.
- **GUD-002**: Prefer the smallest bootcamp-approved EC2 instance that can run Jenkins and Tomcat reliably. If memory is constrained, use the smallest larger allowed instance instead of debugging avoidable out-of-memory failures.
- **GUD-003**: Prefer AWS Lightsail only if EC2 is blocked and the bootcamp account explicitly allows Lightsail.
- **PAT-001**: Follow existing repository patterns: source-controlled scripts in `scripts/`, documentation in `docs/`, implementation plans in `docs/plans/`, closeout in `docs/changelog/`, and generated evidence under ignored `output/`.
- **PAT-002**: Keep public bonus evidence labels explicit by including the public app URL in screenshots, logs, monitor configuration, and documentation wherever possible.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Confirm AWS bootcamp account capabilities and prepare the evidence record.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Run `rtk git status` and confirm branch `feature/10-public-vm-bonus`. |  |  |
| TASK-002 | Read `AGENTS.md`, `contribution.md`, `rules/compliance.md`, `docs/plans/10-public-vm-bonus.md`, and `docs/changelog/` before editing implementation files. |  |  |
| TASK-003 | Log in to the AWS bootcamp account and identify the allowed AWS region, allowed EC2 instance families, allowed AMIs, lab duration, and whether public IPv4 assignment is enabled. |  |  |
| TASK-004 | Confirm whether the account allows creating security groups with inbound `tcp/8080` from `0.0.0.0/0`. |  |  |
| TASK-005 | Confirm whether the account allows restricting inbound `tcp/22` to the operator public IP. |  |  |
| TASK-006 | Create or update `docs/public-app-bonus.md` with fields `selected_path`, `aws_account_type`, `aws_region`, `ec2_instance_type`, `ami_name`, `public_ipv4`, `public_dns`, `public_app_url`, `security_group_rules`, `jenkins_access_mode`, `monitor_tool`, `monitor_target`, `playwright_target`, `gatling_target`, `bonus_claim_status`, and `remaining_blockers`. |  |  |
| TASK-007 | Keep `output/public-app/` ignored through existing `.gitignore` rule `output/**`; do not add a tracked `.gitkeep` unless repository policy changes. |  |  |

### Implementation Phase 2

- GOAL-002: Provision the AWS EC2 public VM.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-008 | Launch one EC2 Ubuntu LTS instance in the bootcamp-approved region. |  |  |
| TASK-009 | Select a bootcamp-approved instance type with enough memory for Docker, Jenkins, Tomcat, Playwright runner startup, and Gatling runner startup. |  |  |
| TASK-010 | Configure EC2 public IPv4 assignment or record the AWS public DNS name if the bootcamp account exposes DNS instead of a stable IPv4. |  |  |
| TASK-011 | Configure inbound security group rule `tcp/22` from the operator public IP only. |  |  |
| TASK-012 | Configure inbound security group rule `tcp/8080` from `0.0.0.0/0` for public Tomcat application access. |  |  |
| TASK-013 | Do not configure inbound security group rule `tcp/8081` from `0.0.0.0/0`. |  |  |
| TASK-014 | If Jenkins browser access is needed, configure either inbound `tcp/8081` from the operator public IP only or SSH tunnel `ssh -L 8081:localhost:8081 <vm-user>@<EC2_PUBLIC_IP>`. |  |  |
| TASK-015 | Record the AWS region, AMI, instance type, public IPv4 or public DNS, security group ID, and security group inbound rules in `docs/public-app-bonus.md`. |  |  |

### Implementation Phase 3

- GOAL-003: Install runtime dependencies and deploy the existing containerized stack on EC2.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-016 | SSH into the EC2 instance with the bootcamp-provided key or credential flow. |  |  |
| TASK-017 | Install Docker Engine, Docker Compose plugin, Git, and curl using the package path appropriate for the selected Ubuntu image. |  |  |
| TASK-018 | Verify `docker --version` prints an installed Docker version on the EC2 VM. |  |  |
| TASK-019 | Verify `docker compose version` prints an installed Compose plugin version on the EC2 VM. |  |  |
| TASK-020 | Clone `https://github.com/y0ncha/meta-final-project.git` onto the EC2 VM. |  |  |
| TASK-021 | Check out the commit or branch selected for final evidence and record its `git rev-parse HEAD` value in `docs/public-app-bonus.md`. |  |  |
| TASK-022 | Run `docker compose up -d tomcat jenkins` on the EC2 VM from the repository root. |  |  |
| TASK-023 | Run `./scripts/deploy-war` on the EC2 VM from the repository root. |  |  |
| TASK-024 | Verify from the EC2 VM that `curl -fsS http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ >/dev/null` passes. |  |  |
| TASK-025 | Verify from an external browser or network that `http://<EC2_PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` or the public DNS equivalent loads. |  |  |
| TASK-026 | Record the public URL and verification result in `docs/public-app-bonus.md`. |  |  |

### Implementation Phase 4

- GOAL-004: Configure public monitoring using an external monitor instead of Jenkins scheduling.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-027 | Define canonical public target variable `PUBLIC_APP_BASE_URL=http://<EC2_PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` in `docs/public-app-bonus.md`, or use the AWS public DNS equivalent if DNS is the selected URL. |  |  |
| TASK-028 | Configure UptimeRobot monitor with URL `PUBLIC_APP_BASE_URL`, interval `5 minutes`, and monitor type `HTTP(s)`. |  |  |
| TASK-029 | If UptimeRobot is unavailable, configure SiteMonitorLite with the same `PUBLIC_APP_BASE_URL`, interval `5 minutes`, and document why UptimeRobot was replaced. |  |  |
| TASK-030 | Capture monitor passed/up screenshot showing monitor tool name, public target URL, configured cadence, and pass/up state. |  |  |
| TASK-031 | Do not present Jenkins `meta-monitoring` or any Jenkins cron schedule as the official 5-minute availability evidence unless the instructor explicitly re-approves it. |  |  |
| TASK-032 | Update `rules/compliance.md`, `docs/monitoring.md`, `docs/jenkins.md`, and `docs/submission.md` so the official monitoring evidence points to UptimeRobot or SiteMonitorLite instead of Jenkins-scheduled availability checks. |  |  |

### Implementation Phase 5

- GOAL-005: Configure Jenkins and browser automation to target the public application URL.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-033 | Access Jenkins through the selected private path: operator-IP-only `tcp/8081` or SSH tunnel `ssh -L 8081:localhost:8081 <vm-user>@<EC2_PUBLIC_IP>`. |  |  |
| TASK-034 | Configure Jenkins job `meta-container-ci-cd` from SCM with repository URL `https://github.com/y0ncha/meta-final-project.git` and script path `Jenkinsfile`. |  |  |
| TASK-035 | Configure Jenkins job `meta-container-ci-cd` or its build environment so Playwright and Gatling stages use `APP_BASE_URL=<PUBLIC_APP_BASE_URL>`. |  |  |
| TASK-036 | Run Playwright against `APP_BASE_URL=<PUBLIC_APP_BASE_URL>` through Jenkins or `scripts/run-playwright-container` and capture passed-run evidence. |  |  |
| TASK-037 | Capture Playwright screenshot evidence under `output/playwright/` or `output/public-app/playwright/` and label it as public-target evidence in `docs/public-app-bonus.md`. |  |  |

### Implementation Phase 6

- GOAL-006: Produce public-target Gatling evidence without inventing results.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-038 | Ask the user to run Jenkins job `meta-container-ci-cd` with `RUN_GATLING_MAX_LIMIT=true` and `APP_BASE_URL=<PUBLIC_APP_BASE_URL>` for public max-limit evidence. |  |  |
| TASK-039 | Ask the user to run Jenkins job `meta-container-ci-cd` with `APP_BASE_URL=<PUBLIC_APP_BASE_URL>` for 5-minute load and 5-minute stress evidence. |  |  |
| TASK-040 | Collect Gatling public max-limit log, HTML report, PDF report, and terminal or Jenkins-console screenshot. |  |  |
| TASK-041 | Collect Gatling public load-test log, HTML report, PDF report, and terminal or Jenkins-console screenshot. |  |  |
| TASK-042 | Collect Gatling public stress-test log, HTML report, PDF report, and terminal or Jenkins-console screenshot. |  |  |
| TASK-043 | Record public Gatling result summaries in `docs/public-app-bonus.md` using only values from generated logs or reports. |  |  |

### Implementation Phase 7

- GOAL-007: Use fallback paths only if EC2 is blocked.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-044 | If EC2 instance launch is blocked by the bootcamp account, check whether AWS Lightsail is allowed in the same account. |  |  |
| TASK-045 | If Lightsail is allowed, provision one Ubuntu Lightsail instance, attach or record its public IP, expose only Tomcat `tcp/8080` publicly, and keep SSH/Jenkins restricted. |  |  |
| TASK-046 | If both EC2 and Lightsail are blocked, evaluate Oracle Cloud Always Free or another instructor-approved public VM provider. |  |  |
| TASK-047 | Use home router port forwarding only as a last-resort fallback after documenting why AWS and public VM paths were blocked. |  |  |
| TASK-048 | Do not use ngrok, Cloudflare Tunnel, Vercel, Netlify, Render, or another tunnel/PaaS path unless the instructor explicitly approves it for the public-IP wording. |  |  |

### Implementation Phase 8

- GOAL-008: Validate, document, and close out the AWS EC2 public VM bonus plan.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-049 | Update `docs/submission.md` to keep local base evidence and public bonus evidence separate. |  |  |
| TASK-050 | Update `docs/public-app-bonus.md` with final evidence paths, commands, screenshots, public URL, selected path, and remaining risks. |  |  |
| TASK-051 | Create or update `docs/changelog/10-public-vm-bonus.changelog.md` with what changed, why it changed, validation commands or artifacts, selected path, and remaining risks. |  |  |
| TASK-052 | Run `git diff --check`. |  |  |
| TASK-053 | Run `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md` and confirm zero failures after policy docs are updated for the latest instructor clarification. |  |  |
| TASK-054 | Run `rtk git status` and confirm Plan 10 changes are scoped. |  |  |

## 3. Alternatives

- **ALT-001**: Use home router port forwarding as the primary path. Rejected because it is weaker evidence, depends on ISP/router behavior, requires the laptop to stay awake and reachable, and may fail under CGNAT or changing home public IP conditions.
- **ALT-002**: Use AWS Lightsail as the primary path. Rejected as primary because bootcamp or AWS Academy accounts commonly expose EC2 first and may not allow Lightsail; Lightsail remains a fallback if EC2 is blocked and Lightsail is allowed.
- **ALT-003**: Use GCP Compute Engine. Rejected because the user does not appear to have an available GCP free-tier path.
- **ALT-004**: Use Oracle Cloud Always Free. Rejected as primary because signup and capacity availability can be unreliable close to the submission deadline; acceptable fallback if AWS is blocked.
- **ALT-005**: Use Vercel, Netlify, Render, or another PaaS deployment. Rejected because those paths weaken the Tomcat `webapps`, WAR deployment, Jenkins, and public-IP evidence story.
- **ALT-006**: Expose Jenkins publicly with the application. Rejected because the instructor needs the website accessible from the internet, not public Jenkins access.
- **ALT-007**: Use ngrok, Cloudflare Tunnel, or another tunnel as the primary solution. Rejected because the PDF and instructor wording ask for internet access through a public target; tunnels are weaker evidence unless explicitly approved.
- **ALT-008**: Reuse local `localhost` evidence for the bonus claim. Rejected because bullets 6 through 10 must target the public application URL.
- **ALT-009**: Claim a max limit from a non-failing Gatling run. Rejected because `rules/compliance.md` forbids invented performance numbers; a non-failing run is only a tested lower bound.

## 4. Dependencies

- **DEP-001**: AWS bootcamp credentials with permission to launch or use EC2.
- **DEP-002**: Bootcamp-approved AWS region, EC2 instance type, AMI, key pair, and security group capabilities.
- **DEP-003**: Public IPv4 or AWS public DNS assigned to the EC2 instance.
- **DEP-004**: SSH access from the operator machine to the EC2 instance.
- **DEP-005**: Docker Engine, Docker Compose plugin, Git, and curl installed on the EC2 instance.
- **DEP-006**: Public GitHub repository `https://github.com/y0ncha/meta-final-project.git`.
- **DEP-007**: Existing source-controlled Docker Compose stack with services `tomcat` and `jenkins`.
- **DEP-008**: UptimeRobot account access, or SiteMonitorLite access if UptimeRobot is blocked.
- **DEP-009**: Browser access from outside the EC2 instance to verify public reachability.
- **DEP-010**: User-provided Jenkins/Gatling artifacts are required because the agent must not run Gatling directly.
- **DEP-011**: Instructor clarification must be reflected in policy docs before final compliance validation if Jenkins scheduled monitoring is no longer accepted.

## 5. Files

- **FILE-001**: `docs/plans/10-public-vm-bonus.md` - this executable AWS EC2 public VM implementation plan.
- **FILE-002**: `docs/public-app-bonus.md` - selected path, AWS setup details, public URL, evidence paths, validation results, and bonus claim status.
- **FILE-003**: `rules/compliance.md` - policy update required to reflect the latest instructor monitoring clarification.
- **FILE-004**: `docs/monitoring.md`, `docs/jenkins.md`, and `docs/submission.md` - documentation updates required for public EC2 evidence and official external monitoring.
- **FILE-005**: `docs/changelog/10-public-vm-bonus.changelog.md` - closeout changelog for the public VM bonus work.
- **FILE-006**: `output/public-app/` - ignored local evidence staging directory for screenshots, copied Jenkins logs, public URL notes, and manual artifacts.
- **FILE-007**: `scripts/run-playwright-container` - existing Playwright runner used with public `APP_BASE_URL`.
- **FILE-008**: `scripts/run-gatling-container`, `scripts/run-gatling-max-limit`, `scripts/run-gatling-load-5m`, and `scripts/run-gatling-stress-5m` - existing Gatling runners invoked by Jenkins for public-target evidence.
- **FILE-009**: `Jenkinsfile` - existing CI/CD Pipeline; edit only if public `APP_BASE_URL` cannot be injected through Jenkins configuration or command environment.
- **FILE-010**: `docker-compose.yml` - existing container orchestration; edit only if the EC2 VM requires a documented cloud-safe adjustment.

## 6. Testing

- **TEST-001**: `rtk git status` must show branch `feature/10-public-vm-bonus`; Plan 10 changes must be scoped.
- **TEST-002**: AWS EC2 console must show one running VM in the selected region with a public IPv4 or public DNS.
- **TEST-003**: EC2 security group must expose inbound `tcp/8080` publicly and must not expose inbound `tcp/8081` publicly.
- **TEST-004**: EC2 security group must restrict inbound `tcp/22` to the operator IP wherever the bootcamp account permits it.
- **TEST-005**: On EC2, `docker --version` must print an installed Docker version.
- **TEST-006**: On EC2, `docker compose version` must print an installed Compose plugin version.
- **TEST-007**: On EC2, `docker compose up -d tomcat jenkins` must start services `tomcat` and `jenkins`.
- **TEST-008**: On EC2, `./scripts/deploy-war` must pass from the repository root.
- **TEST-009**: On EC2, `curl -fsS http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ >/dev/null` must pass.
- **TEST-010**: From an external browser or network, `http://<EC2_PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` or the public DNS equivalent must load.
- **TEST-011**: UptimeRobot or SiteMonitorLite must show a passed/up monitor for `PUBLIC_APP_BASE_URL` at a 5-minute cadence.
- **TEST-012**: Jenkins must be reachable only through the selected restricted access path.
- **TEST-013**: Playwright public-target run must pass with the same five validations as `tests/playwright/meta-functional.spec.js`.
- **TEST-014**: Public Gatling max-limit evidence must include log, HTML report, PDF report, and terminal or Jenkins-console screenshot.
- **TEST-015**: Public Gatling 5-minute load evidence must include log, HTML report, PDF report, and terminal or Jenkins-console screenshot.
- **TEST-016**: Public Gatling 5-minute stress evidence must include log, HTML report, PDF report, and terminal or Jenkins-console screenshot.
- **TEST-017**: `docs/public-app-bonus.md` must list the selected path, AWS details, public URL, and evidence path for every public bonus artifact.
- **TEST-018**: `docs/submission.md` must not treat public bonus evidence as a replacement for the required local `localhost:8080/...` screenshot.
- **TEST-019**: `git diff --check` must pass.
- **TEST-020**: `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md` must pass with zero failures after compliance docs are updated for the latest instructor clarification.
- **TEST-021**: No Gatling command may be run directly by the agent while validating this plan; Gatling execution must be performed by the user through Jenkins or by a user-approved manual command outside the agent workflow.

## 7. Risks & Assumptions

- **RISK-001**: AWS bootcamp accounts can restrict regions, instance types, public IPv4 assignment, key pairs, security group rules, or service availability.
- **RISK-002**: The AWS lab may expire, stop instances, rotate credentials, or reset resources before all evidence is captured.
- **RISK-003**: Very small EC2 instances can run out of memory when Jenkins, Docker, Playwright, and Gatling are used from one VM.
- **RISK-004**: Public IPv4 address or public DNS can change if the instance is stopped and restarted without a persistent address mechanism.
- **RISK-005**: Public network latency can change Gatling response-time graphs; graph explanations must describe the observed public-run behavior instead of copying local-run explanations.
- **RISK-006**: UptimeRobot may need several minutes to show a clean passed state after monitor creation.
- **RISK-007**: Exposing Jenkins publicly creates avoidable security risk; keep Jenkins private, restricted, or tunneled.
- **RISK-008**: The current `rules/compliance.md` may still contain stale Jenkins scheduled-monitor wording and must be updated before final compliance validation.
- **RISK-009**: The final submission deadline is 2026-06-15 at midnight, so AWS setup troubleshooting time is limited.
- **ASSUMPTION-001**: The app context path remains `/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **ASSUMPTION-002**: Local Tomcat remains reachable at `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **ASSUMPTION-003**: Jenkins can run or trigger Playwright and Gatling with `APP_BASE_URL` set to the public application URL.
- **ASSUMPTION-004**: UptimeRobot remains acceptable as the official availability monitor unless explicitly replaced by the instructor.
- **ASSUMPTION-005**: The instructor accepts AWS EC2 public IPv4 or AWS public DNS evidence as satisfying the website-accessible-from-the-internet requirement.
- **ASSUMPTION-006**: The bootcamp account is available before final submission evidence must be captured.

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
