# Plan 10 Changelog - AWS EC2 Bootcamp Public VM Bonus

## 2026-06-11 AWS EC2 Bootcamp VM Replan

### Completed Plan

- Plan: `docs/plans/10-public-vm-bonus.md`
- Completed: 2026-06-11

### What Changed

- Renamed Plan 10 from `Public App Exposure Bonus Evidence` to `AWS EC2 Bootcamp Public VM Bonus Evidence`.
- Changed the primary public-exposure path from home router port forwarding to an AWS EC2 Ubuntu VM using the provided bootcamp credentials.
- Reframed home router port forwarding as a weak last-resort fallback instead of the default path.
- Added AWS-specific tasks for bootcamp account capability checks, EC2 provisioning, security group rules, Docker installation, repository clone, Compose startup, WAR deployment, public browser validation, and cleanup risk tracking.
- Added explicit Jenkins exposure constraints: Tomcat `tcp/8080` may be public, Jenkins `tcp/8081` must stay private, operator-IP restricted, or tunnel-only.
- Added a follow-up requirement to update monitoring and compliance documentation for the instructor's latest clarification that Jenkins scheduled checks should not be used as the official 5-minute availability-monitor proof.

### Why

The instructor said the website must be accessible from the internet, and the user now has AWS bootcamp credentials. EC2 is stronger and more defensible than home router port forwarding because it provides a standard public VM, AWS-managed networking, clearer security group evidence, and a cleaner defense story.

### Validation

- `rtk read contribution.md`: confirmed plan and changelog workflow requirements.
- `rtk read rules/compliance.md`: confirmed current assignment constraints and noted the stale Jenkins scheduled-monitor wording that must be reconciled before final compliance validation.
- `rtk read docs/plans/10-public-vm-bonus.md`: inspected the previous Plan 10 port-forwarding-first design before rewriting.
- `git diff --check`: passed with no whitespace errors.
- `rg -n "goal:|AWS EC2|bootcamp|port forwarding|primary|last-resort|tcp/8081|official 5-minute" docs/plans/10-public-vm-bonus.md docs/changelog/10-public-vm-bonus.changelog.md`: confirmed the new AWS EC2 plan name, bootcamp context, Jenkins exposure guardrails, and port-forwarding fallback wording.
- `rg -n "Use Path A home port-forwarding as the primary|primary free path is home|Public App Exposure Bonus Evidence" docs/plans/10-public-vm-bonus.md docs/changelog/10-public-vm-bonus.changelog.md`: found only the expected changelog sentence documenting the old plan name.
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules rules/compliance.md`: passed with `fail=0`, `warn=0`, and 9 manual-review items.

### Remaining Risks And Follow-Up

- AWS bootcamp account permissions are not yet verified; EC2 region, instance type, AMI, public IPv4 behavior, and security group permissions must be checked in the AWS console.
- `rules/compliance.md` still needs a follow-up update for the instructor's latest monitoring clarification before the public evidence flow can be treated as fully compliant.
- No public VM has been provisioned yet, and no public monitor, Playwright, or Gatling evidence exists yet.
