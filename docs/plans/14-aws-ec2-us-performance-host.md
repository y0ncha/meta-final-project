---
goal: AWS CLI US EC2 Performance Host for Public Tomcat Evidence
version: 1.0
date_created: 2026-06-15
last_updated: 2026-06-15
owner: Yonatan
status: 'Planned'
tags:
  - infrastructure
  - aws
  - ec2
  - performance
  - public-vm
  - tomcat
  - devops-final-project
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

This plan provisions a second AWS EC2 public Tomcat host in a US region using AWS CLI only. The new host replaces the underpowered `t3.micro` public evidence VM when public Gatling evidence needs server capacity closer to the local Docker environment. Jenkins remains local/private. The EC2 instance runs only the Tomcat container and the WAR-backed application at `/yonatan-csasznik-yoed-halberstam-niv-levin/`.

The target region is `us-east-1`. The primary instance type is `c7i.xlarge` with `4 vCPU` and `8 GiB RAM`. If `c7i.xlarge` is unavailable in the bootcamp account, the only approved automatic fallback is `c6i.xlarge`. If both are unavailable, implementation must stop and report the AWS account limit instead of selecting a smaller instance.

## 1. Requirements & Constraints

- **REQ-001**: Provision exactly one new EC2 instance in AWS region `us-east-1` using AWS CLI v2 commands.
- **REQ-002**: Use EC2 instance type `c7i.xlarge` unless AWS CLI availability checks prove it unavailable; use `c6i.xlarge` only as the approved fallback.
- **REQ-003**: Use Ubuntu Server 22.04 LTS amd64 from AWS SSM public parameter `/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id`.
- **REQ-004**: Use one `gp3` root EBS volume with `30 GiB`, `DeleteOnTermination=true`, and no extra EBS volumes.
- **REQ-005**: Allocate and associate one Elastic IP so the public evidence URL remains stable during the evidence window.
- **REQ-006**: Expose the public application URL as `http://<US_EC2_PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **REQ-007**: Deploy only the Tomcat application service on EC2. Do not start Jenkins on EC2.
- **REQ-008**: Use the existing repository deployment command `./scripts/deploy-war` on the EC2 host after starting Tomcat.
- **REQ-009**: Keep local/private Jenkins as the only Jenkins runtime. Jenkins may target the US EC2 app by setting `APP_BASE_URL=<US_PUBLIC_APP_BASE_URL>`.
- **REQ-010**: Run Gatling and Playwright from local/private Jenkins or local runners, not from the EC2 Tomcat host.
- **REQ-011**: Capture local Docker capacity before provisioning with `docker info --format 'DockerCPUs={{.NCPU}} DockerMemoryBytes={{.MemTotal}}'` and store the result in `output/aws-us-performance-host/local-docker-info.txt`.
- **REQ-012**: Capture EC2 Docker capacity after provisioning with `docker info --format 'DockerCPUs={{.NCPU}} DockerMemoryBytes={{.MemTotal}}'` and store the result in `output/aws-us-performance-host/ec2-docker-info.txt`.
- **REQ-013**: Do not claim perfect local-performance parity unless EC2 Docker CPU count is greater than or equal to the local Docker CPU count and EC2 Docker memory bytes are greater than or equal to the local Docker memory bytes.
- **REQ-014**: If EC2 capacity is lower than local Docker capacity, document the gap in `docs/public-app-bonus.md` and describe the US host as a larger public host, not as local-equivalent.
- **REQ-015**: Update `docs/public-app-bonus.md` with the US EC2 instance ID, instance type, AMI ID, region, Elastic IP, security group ID, public app URL, repository commit, deployment validation, and cleanup status.
- **REQ-016**: Keep the previous `il-central-1` EC2 host details in `docs/public-app-bonus.md` as historical evidence unless the user explicitly asks to remove them.
- **REQ-017**: Keep `TOMCAT_RESTART_POLICY=unless-stopped` only on the EC2 host through the host-local ignored `.env`; do not change local Compose defaults.
- **REQ-018**: Use a short evidence window and terminate the US EC2 resources after public evidence capture is complete.
- **SEC-001**: Do not commit AWS credentials, AWS account IDs, AWS access keys, AWS session tokens, SSH private keys, `.pem` files, `.env` files, cookies, API keys, or private IP-only operational notes.
- **SEC-002**: Restrict inbound SSH `tcp/22` to the operator public IP as `<OPERATOR_PUBLIC_IP>/32`.
- **SEC-003**: Allow inbound Tomcat `tcp/8080` from `0.0.0.0/0` only for the public application.
- **SEC-004**: Do not allow inbound Jenkins `tcp/8081` from any source.
- **SEC-005**: Do not attach an IAM instance profile unless a later task explicitly requires AWS API access from inside the EC2 instance.
- **CON-001**: Do not modify `docker-compose.yml`, `pom.xml`, JSP code, Gatling Scala code, Playwright tests, Jenkinsfile, or `scripts/deploy-war` while executing this infrastructure plan.
- **CON-002**: Do not run broad Gatling discovery against the public host until the application URL, monitor target, and instance capacity have been recorded.
- **CON-003**: Do not use AWS Console as the implementation path; AWS Console may be used only for read-only visual verification after CLI commands succeed.
- **CON-004**: Do not use ECS, EKS, ALB, NAT Gateway, RDS, Auto Scaling Group, CloudFront, Route 53, or any extra paid AWS service.
- **CON-005**: Stop implementation if `us-east-1` is blocked by the bootcamp account instead of silently using the existing `il-central-1` VM.
- **GUD-001**: Prefer deterministic AWS CLI commands with explicit names, tags, and `--region us-east-1`.
- **GUD-002**: Prefer larger single-instance capacity over extra AWS services because the assignment evidence needs one public Tomcat URL, not a production architecture.
- **GUD-003**: Prefer `c7i.xlarge` because CPU-bound public Gatling evidence is the current bottleneck; use `c6i.xlarge` only for account availability fallback.
- **PAT-001**: Follow existing repository patterns: implementation plans in `docs/plans/`, public-host tracking in `docs/public-app-bonus.md`, generated raw evidence under ignored `output/`, and submission-ready evidence under `submission/`.
- **PAT-002**: Preserve the canonical Tomcat context path `yonatan-csasznik-yoed-halberstam-niv-levin` everywhere.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Capture the local capacity baseline and define the AWS CLI execution variables.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Run `rtk git status` from the repository root and confirm existing untracked or modified files are not part of this plan unless explicitly listed in Section 5. | No | N/A |
| TASK-002 | Create ignored directory `output/aws-us-performance-host/` for raw CLI evidence and capacity snapshots. | No | N/A |
| TASK-003 | Run `docker info --format 'DockerCPUs={{.NCPU}} DockerMemoryBytes={{.MemTotal}}'` locally and write the exact output to `output/aws-us-performance-host/local-docker-info.txt`. | No | N/A |
| TASK-004 | Run `aws --version` and write the exact output to `output/aws-us-performance-host/aws-cli-version.txt`. | No | N/A |
| TASK-005 | Run `aws sts get-caller-identity --query 'Arn' --output text` only to confirm authentication; do not write account IDs or ARNs into committed files. | No | N/A |
| TASK-006 | Export exact shell variables for this plan: `AWS_REGION=us-east-1`, `EC2_NAME=meta-us-performance-public-app-20260615`, `KEY_NAME=meta-us-performance-20260615`, `SG_NAME=meta-us-performance-app-sg`, `INSTANCE_TYPE_PRIMARY=c7i.xlarge`, `INSTANCE_TYPE_FALLBACK=c6i.xlarge`, `ROOT_VOLUME_GB=30`, and `APP_CONTEXT=yonatan-csasznik-yoed-halberstam-niv-levin`. | No | N/A |
| TASK-007 | Set `OPERATOR_CIDR` with `OPERATOR_CIDR="$(printf '%s/32' "$(curl -fsS https://checkip.amazonaws.com)")"` and record only the `/32` value in `output/aws-us-performance-host/operator-cidr.txt`; do not commit this file. | No | N/A |

### Implementation Phase 2

- GOAL-002: Create US EC2 networking with AWS CLI and no public Jenkins exposure.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-008 | Run `aws ec2 describe-regions --region us-east-1 --region-names us-east-1 --query 'Regions[0].RegionName' --output text` and stop unless the output is exactly `us-east-1`. | No | N/A |
| TASK-009 | Run `aws ec2 describe-instance-type-offerings --region us-east-1 --location-type availability-zone --filters Name=instance-type,Values=c7i.xlarge --query 'InstanceTypeOfferings[0].InstanceType' --output text`; set `INSTANCE_TYPE=c7i.xlarge` only if the output is `c7i.xlarge`. | No | N/A |
| TASK-010 | If TASK-009 output is `None`, run the same `describe-instance-type-offerings` command for `c6i.xlarge`; set `INSTANCE_TYPE=c6i.xlarge` only if the output is `c6i.xlarge`; stop if the output is also `None`. | No | N/A |
| TASK-011 | Resolve `VPC_ID` using `aws ec2 describe-vpcs --region us-east-1 --filters Name=is-default,Values=true --query 'Vpcs[0].VpcId' --output text` and stop if the output is `None`. | No | N/A |
| TASK-012 | Resolve `SUBNET_ID` using `aws ec2 describe-subnets --region us-east-1 --filters Name=vpc-id,Values=${VPC_ID} Name=default-for-az,Values=true --query 'Subnets[0].SubnetId' --output text` and stop if the output is `None`. | No | N/A |
| TASK-013 | Create security group `meta-us-performance-app-sg` with `aws ec2 create-security-group --region us-east-1 --group-name meta-us-performance-app-sg --description 'Meta final project US performance Tomcat host' --vpc-id ${VPC_ID} --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=meta-us-performance-app-sg},{Key=Project,Value=meta-final-project},{Key=Plan,Value=14-aws-ec2-us-performance-host}]' --query 'GroupId' --output text` and store the returned ID as `SG_ID`. | No | N/A |
| TASK-014 | Authorize SSH ingress with `aws ec2 authorize-security-group-ingress --region us-east-1 --group-id ${SG_ID} --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges="[{CidrIp=${OPERATOR_CIDR},Description='operator ssh'}]"`. | No | N/A |
| TASK-015 | Authorize Tomcat ingress with `aws ec2 authorize-security-group-ingress --region us-east-1 --group-id ${SG_ID} --ip-permissions IpProtocol=tcp,FromPort=8080,ToPort=8080,IpRanges="[{CidrIp=0.0.0.0/0,Description='public tomcat app'}]"`. | No | N/A |
| TASK-016 | Verify no Jenkins ingress with `aws ec2 describe-security-groups --region us-east-1 --group-ids ${SG_ID} --query 'SecurityGroups[0].IpPermissions[?FromPort==\`8081\`]' --output text`; output must be empty. | No | N/A |

### Implementation Phase 3

- GOAL-003: Launch the larger US EC2 host and attach a stable public IPv4 address.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-017 | Resolve `AMI_ID` with `aws ssm get-parameter --region us-east-1 --name /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id --query 'Parameter.Value' --output text`. | No | N/A |
| TASK-018 | Create a temporary key pair with `aws ec2 create-key-pair --region us-east-1 --key-name meta-us-performance-20260615 --key-type rsa --query 'KeyMaterial' --output text` and write the private key only to `/private/tmp/meta-us-performance-20260615.pem`; run `chmod 600 /private/tmp/meta-us-performance-20260615.pem`. | No | N/A |
| TASK-019 | Launch the EC2 instance with `aws ec2 run-instances --region us-east-1 --image-id ${AMI_ID} --instance-type ${INSTANCE_TYPE} --key-name meta-us-performance-20260615 --security-group-ids ${SG_ID} --subnet-id ${SUBNET_ID} --associate-public-ip-address --block-device-mappings 'DeviceName=/dev/sda1,Ebs={VolumeSize=30,VolumeType=gp3,DeleteOnTermination=true}' --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=meta-us-performance-public-app-20260615},{Key=Project,Value=meta-final-project},{Key=Plan,Value=14-aws-ec2-us-performance-host}]' --query 'Instances[0].InstanceId' --output text` and store the returned ID as `INSTANCE_ID`. | No | N/A |
| TASK-020 | Wait for the instance with `aws ec2 wait instance-running --region us-east-1 --instance-ids ${INSTANCE_ID}` and `aws ec2 wait instance-status-ok --region us-east-1 --instance-ids ${INSTANCE_ID}`. | No | N/A |
| TASK-021 | Allocate an Elastic IP with `aws ec2 allocate-address --region us-east-1 --domain vpc --tag-specifications 'ResourceType=elastic-ip,Tags=[{Key=Name,Value=meta-us-performance-public-ip-20260615},{Key=Project,Value=meta-final-project},{Key=Plan,Value=14-aws-ec2-us-performance-host}]' --query 'AllocationId' --output text` and store the returned ID as `ALLOCATION_ID`. | No | N/A |
| TASK-022 | Associate the Elastic IP with `aws ec2 associate-address --region us-east-1 --instance-id ${INSTANCE_ID} --allocation-id ${ALLOCATION_ID}`. | No | N/A |
| TASK-023 | Resolve `US_EC2_PUBLIC_IP` with `aws ec2 describe-addresses --region us-east-1 --allocation-ids ${ALLOCATION_ID} --query 'Addresses[0].PublicIp' --output text`. | No | N/A |
| TASK-024 | Write `INSTANCE_ID`, `INSTANCE_TYPE`, `AMI_ID`, `SG_ID`, `ALLOCATION_ID`, `US_EC2_PUBLIC_IP`, and `US_PUBLIC_APP_BASE_URL=http://${US_EC2_PUBLIC_IP}:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` into `output/aws-us-performance-host/aws-resource-summary.env`; do not include AWS account ID or private key path in committed docs. | No | N/A |

### Implementation Phase 4

- GOAL-004: Bootstrap the EC2 host and deploy only the Tomcat WAR application.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-025 | SSH to the instance with `ssh -i /private/tmp/meta-us-performance-20260615.pem ubuntu@${US_EC2_PUBLIC_IP} 'cloud-init status --wait'`. | No | N/A |
| TASK-026 | Install host tools on EC2 with `ssh -i /private/tmp/meta-us-performance-20260615.pem ubuntu@${US_EC2_PUBLIC_IP} 'sudo apt-get update && sudo apt-get install -y git curl maven ca-certificates && curl -fsSL https://get.docker.com -o /tmp/get-docker.sh && sudo sh /tmp/get-docker.sh && sudo usermod -aG docker ubuntu'`. | No | N/A |
| TASK-027 | Open a new SSH session after TASK-026 so group membership applies, then run `docker --version`, `docker compose version`, `git --version`, `mvn --version`, and `curl --version`; write outputs to `output/aws-us-performance-host/ec2-tool-versions.txt`. | No | N/A |
| TASK-028 | Clone or update the repository on EC2 with `git clone https://github.com/y0ncha/meta-final-project.git ~/meta-final-project` if missing; otherwise run `cd ~/meta-final-project && git fetch origin && git checkout main && git pull --ff-only origin main`. | No | N/A |
| TASK-029 | Record the EC2 repository commit with `cd ~/meta-final-project && git rev-parse HEAD` and write the output to `output/aws-us-performance-host/ec2-git-commit.txt`. | No | N/A |
| TASK-030 | Create ignored EC2 file `~/meta-final-project/.env` containing exactly `APP_BASE_URL=http://${US_EC2_PUBLIC_IP}:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` and `TOMCAT_RESTART_POLICY=unless-stopped`. | No | N/A |
| TASK-031 | Start only Tomcat with `cd ~/meta-final-project && TOMCAT_RESTART_POLICY=unless-stopped docker compose up -d tomcat`; do not start Jenkins. | No | N/A |
| TASK-032 | Deploy the WAR with `cd ~/meta-final-project && ./scripts/deploy-war`. | No | N/A |
| TASK-033 | Verify Jenkins is not running with `cd ~/meta-final-project && docker compose ps --services --filter status=running`; output must contain `tomcat` and must not contain `jenkins`. | No | N/A |
| TASK-034 | Verify restart policy with `docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' meta-tomcat`; output must be `unless-stopped`. | No | N/A |

### Implementation Phase 5

- GOAL-005: Validate public reachability and compare EC2 capacity against local Docker capacity.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-035 | On EC2, run `curl -fsS http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ >/dev/null` and record pass or fail in `output/aws-us-performance-host/ec2-local-curl.txt`. | No | N/A |
| TASK-036 | From the local machine, run `curl -I --connect-timeout 10 http://${US_EC2_PUBLIC_IP}:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` and record the headers in `output/aws-us-performance-host/public-curl-headers.txt`; status must be `HTTP/1.1 200` or `HTTP/1.1 302` followed by a successful app load. | No | N/A |
| TASK-037 | On EC2, run `docker info --format 'DockerCPUs={{.NCPU}} DockerMemoryBytes={{.MemTotal}}'` and write the exact output to `output/aws-us-performance-host/ec2-docker-info.txt`. | No | N/A |
| TASK-038 | Compare `output/aws-us-performance-host/local-docker-info.txt` and `output/aws-us-performance-host/ec2-docker-info.txt`; write `capacity_match=true` only if EC2 CPU and memory are both greater than or equal to local Docker CPU and memory, otherwise write `capacity_match=false` with the exact gap. | No | N/A |
| TASK-039 | Run public Playwright smoke validation from local/private runner with `APP_BASE_URL=http://${US_EC2_PUBLIC_IP}:8080/yonatan-csasznik-yoed-halberstam-niv-levin/ ./scripts/run-playwright-container` and write the run path to `output/aws-us-performance-host/public-playwright-run.txt`. | No | N/A |
| TASK-040 | After Plan 13 users/sec changes are complete, run local/private Jenkins with `RUN_GATLING_TESTS=true` and `APP_BASE_URL=http://${US_EC2_PUBLIC_IP}:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`; record the exact `APP_BASE_URL`, Jenkins build number, and pass/fail boundary in `output/aws-us-performance-host/public-gatling-run.txt`. | No | N/A |
| TASK-041 | Update `docs/public-app-bonus.md` with a new section `US Performance Host`, including `aws_region`, `instance_id`, `instance_type`, `ami_id`, `public_ipv4`, `public_app_url`, `security_group_id`, `elastic_ip_allocation_id`, `repository_commit`, `capacity_match`, `playwright_target`, and `gatling_target`. | No | N/A |

### Implementation Phase 6

- GOAL-006: Close the evidence window and clean up AWS resources through AWS CLI.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-042 | After public evidence is captured and no explicit review-hold instruction exists, proceed directly to termination; do not stop the instance as a default end state. | No | N/A |
| TASK-043 | Terminate the instance with `aws ec2 terminate-instances --region us-east-1 --instance-ids ${INSTANCE_ID}` and wait with `aws ec2 wait instance-terminated --region us-east-1 --instance-ids ${INSTANCE_ID}`. | No | N/A |
| TASK-044 | Release the Elastic IP with `aws ec2 release-address --region us-east-1 --allocation-id ${ALLOCATION_ID}`. | No | N/A |
| TASK-045 | Delete the key pair with `aws ec2 delete-key-pair --region us-east-1 --key-name meta-us-performance-20260615`; delete local private key `/private/tmp/meta-us-performance-20260615.pem` after TASK-043 and TASK-046 complete. | No | N/A |
| TASK-046 | Delete the security group with `aws ec2 delete-security-group --region us-east-1 --group-id ${SG_ID}` after the instance has terminated and all ENIs have detached. | No | N/A |
| TASK-047 | Run `aws ec2 describe-instances --region us-east-1 --filters Name=tag:Plan,Values=14-aws-ec2-us-performance-host Name=instance-state-name,Values=pending,running,stopping,stopped --query 'Reservations[].Instances[].InstanceId' --output text` and verify no active instance IDs remain. | No | N/A |
| TASK-048 | Run `aws ec2 describe-addresses --region us-east-1 --filters Name=tag:Plan,Values=14-aws-ec2-us-performance-host --query 'Addresses[].AllocationId' --output text` and verify no Elastic IP allocation IDs remain. | No | N/A |
| TASK-049 | Update `docs/public-app-bonus.md` cleanup status with the termination timestamp, Elastic IP release status, security group deletion status, and any AWS cleanup blockers. | No | N/A |
| TASK-050 | Run `git diff --check` and `rtk git status`; confirm only plan and documentation files changed. | No | N/A |

## 3. Alternatives

- **ALT-001**: Resize the existing `il-central-1` `t3.micro` instance. Rejected because the user requested another EC2 in the US and because preserving historical public evidence details avoids confusing the original Plan 10 record.
- **ALT-002**: Use `t3.large` or `t3.xlarge`. Rejected because burstable credits can distort Gatling evidence during repeated tests.
- **ALT-003**: Use `c7i.2xlarge` or larger. Rejected as the default because `c7i.xlarge` is the smallest non-burstable CPU-focused choice in this plan that meets the `4 vCPU` and `8 GiB RAM` target while materially improving over `t3.micro`.
- **ALT-004**: Use ECS, EKS, ALB, or Auto Scaling. Rejected because the assignment needs a public Tomcat app URL, not production AWS architecture.
- **ALT-005**: Run Gatling on the EC2 host. Rejected because it would make the load generator compete with Tomcat and invalidate the server-capacity comparison.
- **ALT-006**: Move Jenkins to EC2. Rejected because it increases cost and attack surface, and the repository public-host contract keeps Jenkins local/private.
- **ALT-007**: Use the AWS Console as the primary setup path. Rejected because the user explicitly requested AWS CLI.

## 4. Dependencies

- **DEP-001**: AWS CLI v2 authenticated locally with permission for EC2, SSM public parameters, Elastic IPs, key pairs, and security groups in `us-east-1`.
- **DEP-002**: Bootcamp AWS account allows `c7i.xlarge` or `c6i.xlarge` in `us-east-1`.
- **DEP-003**: Default VPC and public subnet exist in `us-east-1`.
- **DEP-004**: Operator network allows outbound SSH to EC2 `tcp/22` and outbound HTTP to EC2 `tcp/8080`.
- **DEP-005**: EC2 instance has outbound internet access for `apt-get`, Docker installation, and GitHub clone.
- **DEP-006**: Public GitHub repository `https://github.com/y0ncha/meta-final-project.git` contains the final deployable code.
- **DEP-007**: Existing Docker Compose service name `tomcat` and container name `meta-tomcat` remain unchanged.
- **DEP-008**: Existing `scripts/deploy-war` remains the deployment command for the WAR-backed Tomcat context.
- **DEP-009**: Existing local/private Playwright and Gatling runners can target `APP_BASE_URL=http://<US_EC2_PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/`.
- **DEP-010**: Plan 13 users/sec max-limit refactor is completed before using the new host for final max-limit users/sec evidence.

## 5. Files

- **FILE-001**: `docs/plans/14-aws-ec2-us-performance-host.md` - this implementation plan.
- **FILE-002**: `docs/public-app-bonus.md` - future update location for US performance host details, public URL, validation results, and cleanup status.
- **FILE-003**: `docs/submission.md` - future update location if the US host replaces previous public evidence in the final submission package.
- **FILE-004**: `output/aws-us-performance-host/` - ignored raw evidence directory for AWS CLI outputs, Docker capacity snapshots, curl headers, and runner handoff notes.
- **FILE-005**: `/private/tmp/meta-us-performance-20260615.pem` - temporary SSH private key generated by AWS CLI; must never be committed.
- **FILE-006**: `scripts/deploy-war` - existing EC2 deployment command used without modification.
- **FILE-007**: `docker-compose.yml` - existing Compose definition used without modification; EC2 restart behavior comes from host-local `.env`.

## 6. Testing

- **TEST-001**: `aws --version` must show AWS CLI v2.
- **TEST-002**: `aws sts get-caller-identity --query 'Arn' --output text` must authenticate without writing account details into committed files.
- **TEST-003**: `aws ec2 describe-regions --region us-east-1 --region-names us-east-1 --query 'Regions[0].RegionName' --output text` must output `us-east-1`.
- **TEST-004**: AWS CLI must confirm `c7i.xlarge` or `c6i.xlarge` offering availability in `us-east-1`.
- **TEST-005**: Security group must include inbound `tcp/22` only from `<OPERATOR_PUBLIC_IP>/32`.
- **TEST-006**: Security group must include inbound `tcp/8080` from `0.0.0.0/0`.
- **TEST-007**: Security group must not include inbound `tcp/8081`.
- **TEST-008**: EC2 instance state and system status checks must both pass through `aws ec2 wait instance-status-ok`.
- **TEST-009**: Elastic IP must resolve to the value used in `US_PUBLIC_APP_BASE_URL`.
- **TEST-010**: EC2 `docker --version`, `docker compose version`, `git --version`, `mvn --version`, and `curl --version` must all pass.
- **TEST-011**: EC2 `docker compose ps --services --filter status=running` must include `tomcat` and must not include `jenkins`.
- **TEST-012**: EC2 `docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' meta-tomcat` must output `unless-stopped`.
- **TEST-013**: EC2 local curl to `http://localhost:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` must pass.
- **TEST-014**: Local external curl to `http://<US_EC2_PUBLIC_IP>:8080/yonatan-csasznik-yoed-halberstam-niv-levin/` must return a successful app response.
- **TEST-015**: Local Playwright public smoke run with `APP_BASE_URL=<US_PUBLIC_APP_BASE_URL>` must pass before any public Gatling run is treated as evidence-ready.
- **TEST-016**: `output/aws-us-performance-host/local-docker-info.txt` and `output/aws-us-performance-host/ec2-docker-info.txt` must exist before claiming capacity parity.
- **TEST-017**: `docs/public-app-bonus.md` must include the US host URL and `capacity_match` value before submission documents are updated to reference the US host.
- **TEST-018**: AWS cleanup validation must show no active Plan 14 EC2 instance and no Plan 14 Elastic IP after the evidence window closes.
- **TEST-019**: `git diff --check` must pass.
- **TEST-020**: `rtk git status` must show no accidental code changes to app, Jenkins, Gatling, Playwright, Maven, or Compose files.

## 7. Risks & Assumptions

- **RISK-001**: A US EC2 host can improve server CPU and memory but cannot reproduce local network latency from Israel or from Jenkins runners.
- **RISK-002**: `c7i.xlarge` or `c6i.xlarge` may be blocked by AWS bootcamp account limits, regional quotas, or unavailable capacity.
- **RISK-003**: Elastic IPs, public IPv4 addresses, EBS volumes, and running EC2 instances can continue billing until explicitly released or terminated.
- **RISK-004**: Public Gatling results can still be lower than local results if the bottleneck is public internet latency, Tomcat configuration, Docker networking, or client-side runner capacity.
- **RISK-005**: Installing Docker through `get.docker.com` depends on outbound internet access from the EC2 host.
- **RISK-006**: If Plan 13 users/sec refactor is incomplete, new public max-limit evidence can still use stale methodology and should not be submitted as final users/sec evidence.
- **RISK-007**: Keeping both the original Israel host and the new US host running increases AWS cost and evidence ambiguity.
- **ASSUMPTION-001**: The assignment accepts a US AWS public IPv4 URL as public-hosted evidence.
- **ASSUMPTION-002**: The repository `main` branch contains the final deployable Tomcat app when this plan is executed.
- **ASSUMPTION-003**: Local Docker capacity is the intended comparison baseline for "local performance", not the physical Mac host outside Docker Desktop limits.
- **ASSUMPTION-004**: The user wants a short-lived larger public evidence host, not a permanent production deployment.
- **ASSUMPTION-005**: The canonical app context path remains `/yonatan-csasznik-yoed-halberstam-niv-levin/`.

## 8. Related Specifications / Further Reading

[AWS EC2 public VM bonus plan](./10-aws-ec2-public-vm-bonus.md)
[Submission package plan](./11-submission-package.md)
[Gatling users/sec max-limit refactor plan](./13-gatling-max-limit-users-per-sec-refactor.md)
[Public app bonus tracker](../public-app-bonus.md)
[Gatling evidence guide](../gatling.md)
[Jenkins guide](../jenkins.md)
[AWS CLI EC2 commands](https://docs.aws.amazon.com/cli/latest/reference/ec2/)
[AWS CLI SSM get-parameter](https://docs.aws.amazon.com/cli/latest/reference/ssm/get-parameter.html)
