# Public App Bonus Host Tracker

This file tracks the optional public-IP bonus host for the AWS EC2 Tomcat-only path. It is not the final evidence checklist. Plan 11 (`docs/plans/11-submission-package.md`) owns local base evidence, public-hosted bonus evidence, attachment readiness, and final submission closeout.

## Selected Path

| Field | Value |
|------|-------|
| selected_path | AWS EC2 Tomcat-only public VM |
| public_host_scope | Tomcat container only |
| jenkins_access_mode | Local/private Jenkins only; Jenkins is not deployed to EC2 |
| cost_budget_note | User has `$100` AWS credit and accepts a short evidence window if expected cost remains roughly `$10-$20` |
| cost_control_policy | No load balancer, NAT Gateway, RDS, ECS, EKS, Auto Scaling Group, or extra paid service unless explicitly approved; Elastic IP is approved only to keep the evidence URL stable |
| cleanup_policy | Terminate EC2 and release the Elastic IP immediately after public evidence capture |
| bonus_claim_status | Delegated to Plan 11; not claimable from host setup alone |

## AWS Account And CLI

| Field | Value |
|------|-------|
| aws_account_type | Bootcamp-provided AWS account |
| aws_account_id | Redacted in repository notes |
| aws_cli_mode | Local Homebrew awscli |
| aws_region | `il-central-1` |
| aws_region_name | Israel (Tel Aviv) |

## EC2 And Networking

| Field | Value |
|------|-------|
| ec2_instance_id | `i-055ec052f6b33983c` |
| ec2_instance_type | `t3.micro` |
| ami_id | `ami-009a79814e701124d` |
| ami_name | Ubuntu Server 22.04 LTS amd64 from AWS SSM public parameter |
| public_ipv4 | `51.84.219.74` |
| public_dns | `ec2-51-84-219-74.il-central-1.compute.amazonaws.com` |
| public_app_url | `http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` |
| security_group_id | `sg-01f4e4d1d0d23faf0` |
| security_group_rules | `tcp/22` from `109.186.132.220/32`, `tcp/8080` from `0.0.0.0/0`, no `tcp/8081` rule |
| ssh_access_mode | Temporary EC2 key pair `meta-public-app-20260612`; private key kept outside the repo under `/private/tmp/` |
| ec2_env_policy | EC2 checkout keeps an ignored `.env` with `APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` and `TOMCAT_RESTART_POLICY=unless-stopped`; local `.env` should stay absent or use local defaults |

## EC2 Deployment Contract

The EC2 VM must run only the Tomcat application service:

- Clone `https://github.com/y0ncha/meta-final-project.git`.
- Start only Tomcat on EC2 with `TOMCAT_RESTART_POLICY=unless-stopped docker compose up -d tomcat`, or set `TOMCAT_RESTART_POLICY=unless-stopped` in the EC2 host's uncommitted `.env`.
- Keep the EC2 Tomcat Compose service on restart policy `unless-stopped` so it starts again after EC2 stop/start or host reboot.
- Deploy the WAR with `./scripts/deploy-war`.
- Do not start Jenkins on EC2.
- Do not expose `tcp/8081`.
- Run Playwright and Gatling from local/private Jenkins or local runners against the EC2 public app URL.

## Public Target Handoff

| Field | Value |
|------|-------|
| PUBLIC_APP_BASE_URL | `http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` |
| monitor_tool | UptimeRobot UI evidence packaged; Jenkins `meta-monitoring` public-target script check passed |
| monitor_target | `http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` |
| playwright_target | `http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` |
| gatling_target | Public Gatling evidence packaged from Jenkins `MeTA/meta-ci-cd` build `#261` against `PUBLIC_APP_BASE_URL`; load and stress passed with `0 KO`, while max-limit failed at the first tested level (`8100`) and does not prove a passing public max-limit value |

All public-hosted bonus evidence classified by Plan 11 must use the same `PUBLIC_APP_BASE_URL`.

## Plan 11 Evidence Handoff

Plan 11 owns the final public-hosted evidence paths and readiness status. Use this tracker only to supply the selected public target and raw operational facts:

| Plan 11 evidence category | Host-source input from this file |
|---|---|
| Public Tomcat URL evidence | `PUBLIC_APP_BASE_URL`, `public_ipv4`, `public_dns` |
| Public monitor evidence | `monitor_target` |
| Public Playwright evidence | `playwright_target` |
| Public Gatling evidence | `gatling_target` |
| AWS cleanup evidence | `cleanup_policy`, EC2 instance id, security group id |

## Operator Command Checklist

Run these only after the EC2 instance exists and `PUBLIC_APP_BASE_URL` is known:

- On EC2 one-shot: `TOMCAT_RESTART_POLICY=unless-stopped docker compose up -d tomcat`
- On EC2 persistent host setup: copy `.env.example` to `.env`, set `APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` and `TOMCAT_RESTART_POLICY=unless-stopped`, then run `docker compose up -d tomcat`
- On local development: keep `.env` absent, or set `APP_BASE_URL=http://tomcat:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` and `TOMCAT_RESTART_POLICY=no`
- Before running local shell scripts from `.env`: `set -a; . ./.env; set +a`
- On EC2: `./scripts/deploy-war`
- On EC2 after restart-policy changes: `docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' meta-tomcat` should print `unless-stopped`
- On EC2: `curl -fsS http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ >/dev/null`
- Local/private browser automation: `APP_BASE_URL=<PUBLIC_APP_BASE_URL> ./scripts/run-playwright-container`
- User-run Gatling load: run the approved Jenkins or runner flow with `RUN_GATLING_LOAD_TEST=true` and `APP_BASE_URL=<PUBLIC_APP_BASE_URL>`.
- User-run Gatling stress: run the approved Jenkins or runner flow with `RUN_GATLING_STRESS_TEST=true` and `APP_BASE_URL=<PUBLIC_APP_BASE_URL>`.
- User-run Gatling max-limit discovery: run separately with `RUN_GATLING_MAX_LIMIT=true` only when intentionally rediscovering the boundary.

## EC2 Deployment Checks

| Check | Result |
|---|---|
| AWS identity | Local AWS CLI authenticated successfully; account id redacted in repository notes |
| VPC | Default VPC `vpc-0e87ee26cebf894d3` |
| Subnet | `subnet-096ef9f2436c50d00` in `il-central-1a`, public IP on launch enabled |
| Security group | `meta-public-app-sg` / `sg-01f4e4d1d0d23faf0` |
| SSH rule | `tcp/22` restricted to `109.186.132.220/32` |
| Tomcat rule | `tcp/8080` open from `0.0.0.0/0` for the public app |
| Jenkins rule | No public `tcp/8081` ingress rule |
| Instance launch | `i-055ec052f6b33983c` running as `t3.micro` |
| EC2 tools | Docker 29.5.3, Docker Compose v5.1.4, Git 2.34.1, curl 7.81.0, Maven 3.6.3 |
| Repository commit on EC2 | Final checkout returned to clean `main` at `debe9c710bd0d9826b487af7df06fb87f278c467` |
| Validated feature branch commit | `origin/feature/10-aws-ec2-public-vm-bonus` at `c51568e31e55d72475fbbdc143941933bf950ff3` |
| Running compose services | Only `meta-tomcat`; Jenkins is not running on EC2 |
| Tomcat restart policy | Validated from published branch commit `c51568e31e55d72475fbbdc143941933bf950ff3`; `docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' meta-tomcat` returned `unless-stopped` |
| EC2 `.env` | Ignored EC2 `.env` sets `APP_BASE_URL` to the public URL and `TOMCAT_RESTART_POLICY=unless-stopped`; do not commit real `.env` files |
| EC2 local app check | `curl -fsS http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ >/dev/null` passed |
| External public app check | `curl -I --connect-timeout 10 http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` returned `HTTP/1.1 200` after published-branch restart-policy validation |
| Public Playwright smoke check | Passed with 1 test and 5 validation steps against `PUBLIC_APP_BASE_URL`; Plan 11 decides whether the artifacts are submission-ready |
| Public monitoring script check | `scripts/run-monitoring-check` passed against `PUBLIC_APP_BASE_URL`; Plan 11 decides whether the artifacts are submission-ready |

## Cost Controls

- Keep the EC2 evidence window short.
- Use the cheapest viable VM because the EC2 host runs Tomcat only.
- Avoid NAT Gateway, load balancer, RDS, ECS, EKS, and Auto Scaling.
- Release the Elastic IP after evidence capture so the stable URL does not keep billing after the project window.
- Run Gatling from outside the EC2 host so the load generator does not consume EC2 CPU or memory.
- Terminate the EC2 instance immediately after evidence capture.
- Verify no extra paid AWS resources remain.

## Remaining Host And Submission Blockers

- Plan 11 still needs final public-hosted evidence classification.
- Public-hosted Tomcat, UptimeRobot monitor UI, Jenkins monitoring, Playwright evidence, and public Gatling evidence are packaged, but should be re-checked against the live `PUBLIC_APP_BASE_URL` before claiming the bonus.
- Terminate AWS resources after Plan 11 public-hosted evidence capture is complete.
- Record cleanup verification so Plan 11 can close the public-hosted bonus section honestly.
