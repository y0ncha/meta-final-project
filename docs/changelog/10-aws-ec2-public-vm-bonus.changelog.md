# Plan 10 AWS EC2 Public VM Bonus Changelog

- Plan: `docs/plans/10-aws-ec2-public-vm-bonus.md`
- Date: 2026-06-12
- Status: In progress; local scaffolding aligned, public EC2 evidence still pending.

## What Changed

- Kept Plan 10 scoped to the AWS EC2 Tomcat-only path: expose the app on public `tcp/8080`, keep Jenkins local/private, and avoid extra paid AWS services.
- Confirmed the plan branch is `feature/10-aws-ec2-public-vm-bonus` and the working tree was clean before this follow-up.
- Updated `docs/submission.md` so the public-IP bonus section no longer describes home router port-forwarding as the selected path.
- Updated `docs/public-app-bonus.md` as a public-host tracker and delegated final evidence readiness to Plan 11.
- Recorded local AWS CLI availability and default region without treating that as EC2 evidence.
- Preserved public-hosted bonus evidence as separate from base local submission evidence by assigning final evidence ownership to Plan 11.
- Launched AWS EC2 instance `i-055ec052f6b33983c` in `il-central-1` as a short-lived `t3.micro` Tomcat-only host.
- Verified security group `sg-01f4e4d1d0d23faf0` exposes public `tcp/8080`, restricts `tcp/22` to the operator IP, and has no public `tcp/8081`.
- Installed Docker, Docker Compose, Git, curl, and Maven on EC2 because `scripts/deploy-war` needs Maven to build the WAR.
- Cloned the public GitHub repository on EC2, deployed the WAR to the Tomcat container only, and verified the public app URL.
- Ran Playwright against the public EC2 app URL and staged artifacts under `output/public-app/playwright/`.
- Ran the monitoring check script against the public EC2 app URL and staged `output/public-app/monitoring/latest-check.txt`.
- Added `TOMCAT_RESTART_POLICY` to `docker-compose.yml`, defaulting to `no`, so EC2 can opt into `unless-stopped` through `.env` or an inline environment variable without changing local behavior.
- Identified that EC2 restart-policy validation is still pending because the recorded EC2 checkout is the merge-base commit, while `TOMCAT_RESTART_POLICY` support is introduced by this branch.
- Updated the public host tracker to use the current Elastic IP `51.84.219.74`.
- Documented that the live EC2 checkout must pull a commit containing this Compose change before its uncommitted `.env` can apply the public `APP_BASE_URL` and `TOMCAT_RESTART_POLICY=unless-stopped` settings.

## Why

Plan 10 now chooses AWS EC2 because it gives the strongest public-IP bonus story. The submission checklist still described home router port-forwarding as primary, which contradicted the current plan and could cause the wrong evidence to be captured.

## Validation

- `rtk git status` - confirmed branch `feature/10-aws-ec2-public-vm-bonus`.
- `sed -n '1,260p' AGENTS.md`
- `sed -n '1,260p' contribution.md`
- `sed -n '1,320p' rules/compliance.md`
- `sed -n '1,360p' docs/plans/10-aws-ec2-public-vm-bonus.md`
- `git diff --check` - passed.
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md` - passed with `70 pass`, `0 warn`, `0 fail`, and `9 manual` items requiring human review.
- `aws --version` - confirmed AWS CLI v2.35.2 is installed.
- `aws configure get region` - local default region is `il-central-1`.
- `aws sts get-caller-identity --output json` - authenticated successfully; account id redacted in repository notes.
- `aws ec2 describe-vpcs --filters Name=is-default,Values=true ...` - found default VPC `vpc-0e87ee26cebf894d3`.
- `aws ec2 describe-subnets --filters Name=default-for-az,Values=true ...` - selected public subnet `subnet-096ef9f2436c50d00`.
- `aws ec2 describe-security-groups ...` - verified `tcp/22`, `tcp/8080`, and no `tcp/8081` on `sg-01f4e4d1d0d23faf0`.
- `aws ssm get-parameter --name /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id ...` - selected AMI `ami-009a79814e701124d`.
- `aws ec2 run-instances ...` - launched `i-055ec052f6b33983c`.
- EC2 `docker --version` - Docker 29.5.3.
- EC2 `docker compose version` - Docker Compose v5.1.4.
- EC2 `git --version` - Git 2.34.1.
- EC2 `mvn --version` - Maven 3.6.3.
- EC2 `git rev-parse HEAD` - deployed public repository commit `debe9c710bd0d9826b487af7df06fb87f278c467`.
- EC2 `TOMCAT_RESTART_POLICY=unless-stopped docker compose up -d tomcat` - pending rerun after the EC2 checkout is updated to a commit containing the Compose restart-policy field.
- EC2 `./scripts/deploy-war` - Maven build succeeded and deployed the WAR.
- EC2 `docker compose ps` - showed only `meta-tomcat`, no Jenkins service.
- EC2 `curl -fsS http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ >/dev/null` - passed.
- EC2 restart-policy validation - pending; the recorded EC2 checkout is `debe9c710bd0d9826b487af7df06fb87f278c467`, which does not contain the branch Compose restart-policy field.
- EC2 `.env` update for public `APP_BASE_URL` and `TOMCAT_RESTART_POLICY=unless-stopped` - pending effect until the branch Compose change is present on EC2.
- EC2 `systemctl is-enabled docker` - returned `enabled`.
- EC2 `systemctl is-active docker` - returned `active`.
- Local `curl -I --connect-timeout 10 http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` - returned `HTTP/1.1 200`; this proves public app reachability, not restart-policy behavior.
- `APP_BASE_URL=http://51.84.147.234:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ ./scripts/run-playwright-container` - passed 1 Playwright test before the Elastic IP changed.
- `APP_BASE_URL=http://51.84.219.74:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ JOB_NAME=meta-monitoring BUILD_NUMBER=public-ec2-restart-policy ./scripts/run-monitoring-check` - passed.
- Manual public-IP review - public EC2 evidence remains explicitly pending; no public-IP bonus is claimed from local docs.

## Remaining Risks And Follow-Up

- Official UptimeRobot or SiteMonitorLite monitor UI evidence is still pending.
- Public Gatling evidence is still pending.
- EC2 restart-policy validation is still pending until EC2 pulls a commit containing this branch's Compose change and Tomcat is recreated with `TOMCAT_RESTART_POLICY=unless-stopped`.
- The agent must not run Gatling directly. Public-target Gatling max-limit, load, and stress evidence must come from user-run Jenkins or runner artifacts.
- The EC2 instance is currently running and should be terminated immediately after remaining public evidence is captured.
- EC2 cleanup verification is mandatory before claiming the evidence window is closed.
