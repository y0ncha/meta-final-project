# 12 - Compliance Validator Skill

## Goal
Create a project-local Codex skill that validates a project, folder, or file against local compliance rules.

## Deliverables
- `.agents/skills/compliance-validator/SKILL.md`.
- `.agents/skills/compliance-validator/scripts/validate_compliance.py`.
- `.agents/skills/compliance-validator/agents/openai.yaml`.

## Implementation
- Keep the skill local under `.agents/skills/`, not the global Codex skills directory.
- Default the rules source to `.agents/rules/compliance.md`.
- Support pointed validation through a `--target` argument.
- Fail clearly when the default rules file is missing instead of silently substituting another source.
- Provide a `--rules` override for deliberate validation against another local rules file.

## Validation
- Run the skill structure validator.
- Run the compliance script against a known local rules file.
- Confirm the default missing-rules path reports a clear configuration error while `.agents/rules/compliance.md` is absent.
