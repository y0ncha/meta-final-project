# Public App Bonus Evidence Tracker

This file tracks the optional public-IP bonus evidence for the AWS EC2 Tomcat-only path. It is not final submission evidence until the public application URL, monitoring, Playwright, and Gatling artifacts are captured against the same public target.

## Selected Path

| Field | Value |
|------|-------|
| selected_path | AWS EC2 Tomcat-only public VM |
| public_host_scope | Tomcat container only |
| jenkins_access_mode | Local/private Jenkins only; Jenkins is not deployed to EC2 |
| cost_budget_note | User has `$100` AWS credit and accepts a short evidence window if expected cost remains roughly `$10-$20` |
| cost_control_policy | No load balancer, NAT Gateway, RDS, ECS, EKS, Auto Scaling Group, Elastic IP, or extra paid service unless explicitly approved |
| cleanup_policy | Terminate EC2 and verify no extra paid resource remains immediately after public evidence capture |
| bonus_claim_status | Not claimable yet |

## AWS Account And CLI

| Field | Value |
|------|-------|
| aws_account_type | Bootcamp-provided AWS account |
| aws_account_id | Redacted in repository notes |
| aws_cli_mode | Local Homebrew awscli or AWS CloudShell, if available |
| aws_region | Pending |
| aws_region_name | Pending |

## EC2 And Networking

| Field | Value |
|------|-------|
| ec2_instance_id | Pending |
| ec2_instance_type | Pending cheapest viable Tomcat-only instance |
| ami_id | Pending |
| ami_name | Pending Ubuntu LTS |
| public_ipv4 | Pending |
| public_dns | Pending |
| public_app_url | Pending |
| security_group_id | Pending |
| security_group_rules | Pending: `tcp/22` from operator IP only, `tcp/8080` from `0.0.0.0/0`, no `tcp/8081` rule |
| ssh_access_mode | Pending operator-IP-only `tcp/22` |

## EC2 Deployment Contract

The EC2 VM must run only the Tomcat application service:

- Clone `https://github.com/y0ncha/meta-final-project.git`.
- Start only Tomcat with `docker compose up -d tomcat`.
- Deploy the WAR with `./scripts/deploy-war`.
- Do not start Jenkins on EC2.
- Do not expose `tcp/8081`.
- Run Playwright and Gatling from local/private Jenkins or local runners against the EC2 public app URL.

## Public Evidence Targets

| Field | Value |
|------|-------|
| PUBLIC_APP_BASE_URL | Pending |
| monitor_tool | Pending |
| monitor_target | Pending |
| playwright_target | Pending |
| gatling_target | Pending |

All public-target evidence must use the same `PUBLIC_APP_BASE_URL`.

## Cost Controls

- Keep the EC2 evidence window short.
- Use the cheapest viable VM because the EC2 host runs Tomcat only.
- Avoid NAT Gateway, load balancer, Elastic IP, RDS, ECS, EKS, and Auto Scaling.
- Run Gatling from outside the EC2 host so the load generator does not consume EC2 CPU or memory.
- Terminate the EC2 instance immediately after evidence capture.
- Verify no extra paid AWS resources remain.

## Remaining Blockers

- Launch EC2 Tomcat-only instance.
- Verify public `tcp/8080` and restricted `tcp/22` security group rules.
- Verify no public Jenkins `tcp/8081` rule.
- Deploy Tomcat WAR on EC2.
- Record public IPv4 or public DNS.
- Verify public app URL externally.
- Configure external 5-minute monitor against the public app URL.
- Run public-target Playwright evidence.
- Collect user-run public-target Gatling max-limit, load, and stress evidence.
- Terminate AWS resources and record cleanup verification.
