# 12-compliance-validator-skill

## Status

- Result: Completed on 2026-06-10.

## Files Changed

- `.agents/skills/compliance-validator/SKILL.md`: Added the project-local compliance validation workflow.
- `.agents/skills/compliance-validator/scripts/validate_compliance.py`: Added a deterministic first-pass scanner for Markdown compliance rules.
- `.agents/skills/compliance-validator/agents/openai.yaml`: Added UI metadata and default prompt.
- `docs/plans/12-compliance-validator-skill.md`: Documented the local skill plan.

## Validation Performed

- `python3 /Users/yonatan/.codex/skills/.system/skill-creator/scripts/quick_validate.py .agents/skills/compliance-validator`
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target . --rules .agents/rules/contribution.md`
- `python3 .agents/skills/compliance-validator/scripts/validate_compliance.py --target .`

## Notes

- `.agents/rules/compliance.md` does not exist in the current checkout. The skill and script keep that as the default source, but report the missing file clearly rather than silently falling back to `.agents/rules/contribution.md`.
