---
name: compliance-validator
description: Validate a project, folder, or file against local Markdown compliance rules, defaulting to `.agents/rules/compliance.md`. Use when the user asks for compliance validation, assignment readiness, evidence checks, deliverable checks, rule conformance, or a report of missing artifacts against project-local rules.
---

# Compliance Validator

## Overview

Use this skill to produce an evidence-backed compliance report for a target project, folder, or file. The default rules source is `.agents/rules/compliance.md` relative to the project root.

## Workflow

1. Read the project-level operating rules first, especially `contribution.md` when it exists.
2. Locate the rule file. Use `.agents/rules/compliance.md` by default. If it is missing, stop and report that the compliance rule source is missing instead of silently substituting another file.
3. Run the bundled validator script for a first-pass evidence map:

```bash
python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules .agents/rules/compliance.md
```

For a pointed folder or file, change only `--target`:

```bash
python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target docs/submission-checklist.md --rules .agents/rules/compliance.md
```

Use `--format json` when another tool or script will consume the result.

## Report Rules

- Treat the script output as a triage aid, not an authoritative proof engine.
- Manually inspect every `warn` and `manual` item before writing the final answer.
- Cite exact rule lines and exact project files or artifacts that support the result.
- Do not invent evidence, screenshots, test results, links, or performance numbers.
- Do not mark compliance as passed when the rules file is missing, the target is missing, or evidence is placeholder-only.
- State assumptions explicitly, including any accepted project-specific overrides.

## Final Output

Use this compact shape unless the user asks for something else:

```markdown
**Compliance Result**
- Overall: pass | warn | fail
- Rules file: <path>
- Target: <path>
- Command: `<exact command>`

**Findings**
- [pass|warn|fail|manual] <rule summary> - <evidence or missing artifact>

**Next Actions**
- <smallest concrete fix or evidence capture step>
```

## Script

The reusable script is `scripts/validate_compliance.py`. It extracts Markdown bullet and numbered rules, scans text files under the target, and reports whether rule-specific evidence tokens appear in filenames or file contents.
