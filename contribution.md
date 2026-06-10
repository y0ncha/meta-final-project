# Contribution Workflow

This file defines how code and documentation changes are contributed to this repository. Assignment requirements, runtime constraints, evidence rules, and submission requirements live in `rules/compliance.md`.

## Before Implementation

- Read the relevant source plan from `docs/plans/<plan-name>.md`.
- Briefly review `docs/changelog/` before writing a new implementation plan so the plan stays aligned with prior decisions and reuses existing logic where appropriate.
- Stay on the current branch unless the user explicitly asks for a branch change or invokes the `create-implementation-plan` skill for new planned work.
- When `create-implementation-plan` is invoked, rewrite the matching source plan in `docs/plans/` and create or switch to a branch with the same plan stem, using `feature/<plan-file-stem>` unless the user explicitly requests another branch name.
- Before creating or switching branches, verify the current branch, upstream status, and working tree state; if the target branch is behind its base or branch switching is blocked by uncommitted work, report the state before editing.
- Read `rules/compliance.md` and confirm the planned change does not conflict with the project constraints.
- If the planned change conflicts with `rules/compliance.md`, stop and report the conflict before editing files or running mutating commands.

## During Implementation

- Keep each branch scoped to one implementation plan unless explicitly instructed otherwise.
- Update the implementation plan as work progresses so it remains a truthful checklist, not a stale proposal.
- Keep unrelated refactors, cleanup, formatting churn, and evidence deletion out of the branch unless the plan requires them.
- When finishing a plan, create or update `docs/changelog/<plan-file-stem>.changelog.md`.
- The changelog must include what changed, why it changed, exact validation commands or artifacts, and any remaining risks or follow-up items.

## Follow-Up Changes To Existing Plans

- If a change is an enhancement, correction, or implementation-detail change for an existing plan, update that existing `docs/plans/<plan-name>.md` and `docs/changelog/<plan-name>.changelog.md` instead of creating a standalone plan.
- Keep follow-up changes on the current branch unless the user explicitly asks for branch movement.
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
