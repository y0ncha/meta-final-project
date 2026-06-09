# 10 - Public VM Bonus

## Goal
Deploy the same Docker Compose stack on a public VM and run required evidence against the public target.

## Deliverables
- Public VM with Docker.
- Same project repository cloned on the VM.
- Running Tomcat/Jenkins stack.
- Public app URL.
- Bonus evidence from monitor, Playwright, and Gatling.

## Implementation
- Provision Ubuntu or another supported Linux VM.
- Install Docker and Docker Compose.
- Open firewall/security group for Tomcat, preferably `8080`.
- Clone the GitHub repo.
- Run the same Compose stack.
- Deploy the same WAR under Tomcat `webapps`.
- Set `APP_BASE_URL=http://<public-ip>:8080/meta/`.
- Run UptimeRobot, Playwright, and Gatling against the public URL.

## Validation
- Public URL loads from outside the VM.
- UptimeRobot passes against the public URL.
- Playwright passes against the public URL.
- Gatling max/load/stress runs target the public URL.

## Human Configuration Needed
- Cloud provider account.
- VM creation.
- SSH key.
- Firewall/security group.
- Public IP.
- Optional domain/DNS if chosen.
