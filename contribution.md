# Contribution Workflow

This file defines how code and documentation changes are contributed to this repository. Assignment requirements, runtime constraints, evidence rules, and submission requirements live in `rules/compliance.md`.

## Before Implementation

- Read the relevant source plan from `docs/plans/<plan-name>.md`.
- Rewrite the source plan into an implementation plan using the `create-implementation-plan` skill before making implementation changes.
- Read `rules/compliance.md` and confirm the implementation plan does not conflict with the project constraints.
- If the implementation plan conflicts with `rules/compliance.md`, stop and report the conflict before editing files or running mutating commands.
- Create or switch to the corresponding implementation branch before editing files.
- Use `feature/<plan-file-stem>` as the branch name unless the user explicitly requests another branch name.
- If branch creation or switching is blocked by uncommitted work, report the current Git state and ask how to handle it.

## During Implementation

- Keep each branch scoped to one implementation plan unless explicitly instructed otherwise.
- Update the implementation plan as work progresses so it remains a truthful checklist, not a stale proposal.
- Keep unrelated refactors, cleanup, formatting churn, and evidence deletion out of the branch unless the plan requires them.
- When finishing a plan, create or update `docs/changelog/<plan-file-stem>.changelog.md`.
- The changelog must include what changed, why it changed, exact validation commands or artifacts, and any remaining risks or follow-up items.

## Follow-Up Changes To Existing Plans

- If a change is an enhancement, correction, or implementation-detail change for an existing plan, update that existing `docs/plans/<plan-name>.md` and `docs/changelog/<plan-name>.changelog.md` instead of creating a standalone plan.
- Add dated follow-up notes when a later decision supersedes an earlier task, alternative, or risk. Preserve the old rationale only when it is useful history; make the current required behavior unambiguous.
- Create a new numbered plan only for a genuinely separate deliverable, workflow, or assignment requirement that cannot be evaluated as part of an existing plan.

## Before Completion

- Run the validation commands required by the implementation plan.
- Run the local compliance validator against `rules/compliance.md`.
- Do not mark the plan complete if validation fails, compliance validation fails, or required evidence is missing.
- If validation cannot be run locally, document the blocker and the exact command that should be run later.

## Commit And Merge

- Commit only after implementation validation and compliance validation pass.
- Use a commit message that names the completed plan or the concrete change.
- Merge the implementation branch back to `main` only after the branch is validated and the user has approved completion.
- After merging, verify `main` contains the completed change and no unrelated branch-only edits were lost.
