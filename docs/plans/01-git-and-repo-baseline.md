---
goal: Git and repository baseline for the MTA DevOps final project
version: 1.0
date_created: 2026-06-09
last_updated: 2026-06-09
owner: Project team
status: 'Completed'
tags: [process, infrastructure, git, baseline, devops-final-project]
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-green)

Completed on 2026-06-09. Completion evidence is tracked in `docs/changelog/01-git-and-repo-baseline.changelog.md`.

Create a clean Git repository baseline for the MTA 2026 Semester B DevOps final project before adding the JSP application, Docker Compose stack, Jenkins jobs, Playwright tests, Gatling simulations, HAR capture, and submission evidence. This plan defines exactly which files enter the first public baseline and which local/generated artifacts must stay out of Git.

## 1. Requirements & Constraints

- **REQ-001**: Initialize Git in `/Users/yonatan/Library/CloudStorage/OneDrive-TheAcademicCollegeofTel-AvivJaffa-MTA/GoodNotes/שנה ג/סמסטר ב/DevOps/final project` if `.git/` does not already exist.
- **REQ-002**: Create a first commit named `chore: initialize devops final project repository` after the repository scaffold is created.
- **REQ-003**: Create `.gitignore` at the project root before staging files.
- **REQ-004**: Create `README.md` at the project root with the project purpose, local Tomcat URL, Jenkins URL, repository status, and evidence policy.
- **REQ-005**: Create `docs/repository-baseline.md` to record baseline decisions, ignored artifact classes, and commands used for validation.
- **REQ-006**: Create `scripts/README.md` so the `scripts/` directory is tracked without adding executable automation before it is needed.
- **REQ-007**: Create `output/.gitkeep` so the `output/` evidence root is present while generated evidence files remain ignored.
- **REQ-008**: Keep generated evidence out of Git, including Playwright reports, screenshots, HAR files, Gatling reports, Gatling PDFs, Jenkins logs, Docker volumes, and temporary runtime files.
- **REQ-009**: Keep lecture PDFs and assignment PDFs out of Git because the public GitHub repository should contain the project implementation and defensible evidence references, not copied course material.
- **REQ-010**: Keep local agent/workflow metadata out of Git, including `.agents/`, `.codex/`, `skills-lock.json`, and editor/system files.
- **REQ-011**: Keep `AGENTS.md` and `contribution.md` tracked unless a later explicit decision removes them; `AGENTS.md` is the local agent operating handbook, and `contribution.md` contains the assignment compliance rules used by the implementation plans.
- **REQ-012**: Do not configure a GitHub remote in this phase unless the exact repository URL is already known.
- **REQ-013**: If no GitHub remote is configured, `README.md` must state `Public GitHub repository: not configured yet`.
- **SEC-001**: Do not commit credentials, tokens, `.env` files, private keys, Jenkins secrets, Docker volume contents, or UptimeRobot credentials.
- **SEC-002**: Do not commit generated browser traces or HAR files until they are explicitly reviewed for sensitive data; final submission evidence can live under ignored `output/`.
- **CON-001**: Use the current local Git installation; do not install, upgrade, or replace Git during this phase.
- **CON-002**: Prefer `rtk` wrappers for noisy inspection output, but use direct `git` commands for exact repository state checks.
- **CON-003**: The workspace currently starts without `.git/`; implementation must handle that initial state directly.
- **CON-004**: The project root is in a OneDrive-backed folder, so `.DS_Store`, sync metadata, and transient generated files must be ignored before the first commit.
- **CON-005**: This plan is stored in `.agents/plans/01-git-and-repo-baseline.md` by explicit user request, even though the generic planning skill normally writes new plans under `/plan/`.
- **GUD-001**: Keep the baseline commit small, readable, and easy to defend during the final project defense.
- **GUD-002**: Do not add application source code, Docker configuration, Jenkins configuration, Playwright configuration, Gatling configuration, or HAR artifacts in this phase.
- **GUD-003**: Use deterministic file names and stable directory names that later plans can reference.
- **PAT-001**: Generated evidence belongs under `output/` and is ignored by Git unless a later plan explicitly tracks a small text index.
- **PAT-002**: Human-facing project notes belong under `docs/`.
- **PAT-003**: Repeatable command wrappers belong under `scripts/`, but this phase tracks only `scripts/README.md`.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Verify the starting repository state and local Git identity without changing files.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Run `git rev-parse --is-inside-work-tree` from `/Users/yonatan/Library/CloudStorage/OneDrive-TheAcademicCollegeofTel-AvivJaffa-MTA/GoodNotes/שנה ג/סמסטר ב/DevOps/final project`; record `false` or the Git error message in `docs/repository-baseline.md` after that file exists. | | |
| TASK-002 | Run `git --version` and record the exact output in `docs/repository-baseline.md` after that file exists. | | |
| TASK-003 | Run `git config --global user.name` and `git config --global user.email`; if either command prints nothing, stop before the first commit and configure the missing value using the real project team identity. | | |
| TASK-004 | Run `find . -maxdepth 2 -type f -print` and identify files that must not be staged: `.DS_Store`, `skills-lock.json`, `final-project.pdf`, `classes/*.pdf`, `.agents/*`, and future generated `output/*` files. | | |

### Implementation Phase 2

- GOAL-002: Create the baseline project scaffold with tracked documentation roots and ignored evidence roots.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-005 | Run `git init` from the project root only if `.git/` does not exist. | | |
| TASK-006 | Create `docs/` if it does not exist. | | |
| TASK-007 | Create `scripts/` if it does not exist. | | |
| TASK-008 | Create `output/` if it does not exist. | | |
| TASK-009 | Create `output/.gitkeep` containing exactly one line: `# Keeps the ignored evidence output root visible in Git.` | | |
| TASK-010 | Create `scripts/README.md` with a short statement that executable scripts will be added by later plans and must be runnable from the project root. | | |

### Implementation Phase 3

- GOAL-003: Add a root `.gitignore` that prevents accidental staging of generated, local, private, or course-material files.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-011 | Create `.gitignore` with sections named `# macOS and editor files`, `# Local agent and workspace metadata`, `# Java and Maven build output`, `# Docker and Jenkins local state`, `# Node and browser test output`, `# Gatling output`, `# Evidence output`, `# Course material and PDFs`, `# Environment and secrets`, and `# Temporary files`. | | |
| TASK-012 | Under `# macOS and editor files`, ignore `.DS_Store`, `.idea/`, `.vscode/`, and `*.swp`. | | |
| TASK-013 | Under `# Local agent and workspace metadata`, ignore `.agents/`, `.codex/`, and `skills-lock.json`. | | |
| TASK-014 | Under `# Java and Maven build output`, ignore `target/`, `*.class`, and `*.war`. | | |
| TASK-015 | Under `# Docker and Jenkins local state`, ignore `.docker/`, `docker-data/`, `jenkins_home/`, `.jenkins/`, and `*.log`. | | |
| TASK-016 | Under `# Node and browser test output`, ignore `node_modules/`, `playwright-report/`, `test-results/`, `.playwright/`, and `blob-report/`. | | |
| TASK-017 | Under `# Gatling output`, ignore `gatling-results/` and `results/`. | | |
| TASK-018 | Under `# Evidence output`, ignore `output/**`, then unignore `!output/` and `!output/.gitkeep`. | | |
| TASK-019 | Under `# Course material and PDFs`, ignore `classes/`, `*.pdf`, and `*.side`; Selenium `.side` files remain ignored because this project explicitly uses Playwright unless the lecturer later requires Selenium IDE. | | |
| TASK-020 | Under `# Environment and secrets`, ignore `.env`, `.env.*`, `*.pem`, `*.key`, `*.p12`, `*.jks`, `secrets/`, and `credentials/`. | | |
| TASK-021 | Under `# Temporary files`, ignore `tmp/`, `temp/`, `.cache/`, `.rtk/`, and `*.tmp`. | | |

### Implementation Phase 4

- GOAL-004: Add baseline documentation that a grader or teammate can read before implementation starts.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-022 | Create `README.md` with H1 text `MTA DevOps Final Project`. | | |
| TASK-023 | In `README.md`, add a `Project Purpose` section stating that this repository contains the JSP app, containerized Tomcat deployment, Jenkins CI/CD flow, Playwright validation, Gatling performance tests, HAR evidence, and submission artifacts for the MTA 2026 Semester B DevOps final project. | | |
| TASK-024 | In `README.md`, add a `Local URLs` section with `Tomcat application: http://localhost:8080/<group-names>/` and `Jenkins: http://localhost:8081/`; keep `<group-names>` exactly as a documented assignment variable until the real group-member context path is selected in plan `03-jsp-maven-war-app.md`. | | |
| TASK-025 | In `README.md`, add a `Repository Status` section with `Public GitHub repository: not configured yet` unless `git remote get-url origin` returns a real URL before writing the file. | | |
| TASK-026 | In `README.md`, add an `Evidence Policy` section stating that generated evidence is saved under ignored `output/` and attached to the final submission package instead of committed by default. | | |
| TASK-027 | Create `docs/repository-baseline.md` with sections `Baseline Date`, `Commands Run`, `Tracked Baseline Files`, `Ignored Artifact Classes`, and `Next Plan`. | | |
| TASK-028 | In `docs/repository-baseline.md`, set `Baseline Date` to `2026-06-09`. | | |
| TASK-029 | In `docs/repository-baseline.md`, list the intended tracked files: `.gitignore`, `README.md`, `AGENTS.md`, `contribution.md`, `docs/repository-baseline.md`, `scripts/README.md`, and `output/.gitkeep`. | | |
| TASK-030 | In `docs/repository-baseline.md`, set `Next Plan` to `.agents/plans/02-docker-compose-foundation.md`. | | |

### Implementation Phase 5

- GOAL-005: Validate ignore rules and create the first baseline commit.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-031 | Run `git check-ignore -v .DS_Store skills-lock.json final-project.pdf classes/DevOps_Final\ Project_MTA_2026_SemB.pdf .agents/plans/01-git-and-repo-baseline.md output/playwright/report.html`; every path must be reported as ignored before staging. | | |
| TASK-032 | Run `git status --short --branch`; confirm only intended tracked baseline files are untracked and ignored files are absent from the short status. | | |
| TASK-033 | Run `git add .gitignore README.md AGENTS.md contribution.md docs/repository-baseline.md scripts/README.md output/.gitkeep`. | | |
| TASK-034 | Run `git diff --cached --name-only`; output must be exactly `.gitignore`, `AGENTS.md`, `README.md`, `contribution.md`, `docs/repository-baseline.md`, `output/.gitkeep`, and `scripts/README.md`, one per line. | | |
| TASK-035 | Run `git commit -m "chore: initialize devops final project repository"`. | | |
| TASK-036 | Run `git log --oneline -1`; the latest commit subject must be `chore: initialize devops final project repository`. | | |
| TASK-037 | Run `git status --short`; output must be empty immediately after the commit. | | |
| TASK-038 | Run `git remote -v`; if no remote exists, leave the remote unset and keep `README.md` marked `Public GitHub repository: not configured yet`. | | |

## 3. Alternatives

- **ALT-001**: Commit every current file in the OneDrive folder. Rejected because it would publish lecture PDFs, assignment PDFs, `.DS_Store`, local agent files, and unrelated metadata that are not required for the project repository.
- **ALT-002**: Track generated evidence under `output/` in Git. Rejected because screenshots, HAR files, Gatling reports, Playwright reports, and PDFs are final-submission artifacts; they can be large, noisy, and may contain sensitive data.
- **ALT-003**: Configure a GitHub remote during baseline setup. Rejected for this phase because the exact public repository URL is not yet defined in the local project files.
- **ALT-004**: Track `.agents/plans/` in the public repository. Rejected because `.agents/` is local execution metadata; final deliverables should be represented by `README.md`, `docs/`, source files, scripts, and generated evidence.
- **ALT-005**: Add starter shell scripts during the baseline phase. Rejected because executable automation should be introduced with the Docker, Maven, Jenkins, Playwright, and Gatling plans that define and validate each command.

## 4. Dependencies

- **DEP-001**: Local Git executable available on `PATH`; current observed snapshot in `contribution.md` is Git `2.50.1`, but the implementation agent must re-check with `git --version`.
- **DEP-002**: Git user name and email configured before creating the first commit.
- **DEP-003**: Write access to `/Users/yonatan/Library/CloudStorage/OneDrive-TheAcademicCollegeofTel-AvivJaffa-MTA/GoodNotes/שנה ג/סמסטר ב/DevOps/final project`.
- **DEP-004**: No GitHub repository URL is required for this phase.
- **DEP-005**: No Docker, Maven, Jenkins, Playwright, Gatling, Java, Node, npm, bun, or uv command is required for this phase.

## 5. Files

- **FILE-001**: `.gitignore` - root ignore rules for local metadata, build output, generated evidence, course PDFs, and secrets.
- **FILE-002**: `README.md` - public-facing repository overview and current local URL documentation.
- **FILE-003**: `AGENTS.md` - tracked project operating handbook that points agents to the compliance source.
- **FILE-004**: `contribution.md` - tracked project constraints, compliance rules, tool version policy, evidence standards, and submission checklist.
- **FILE-005**: `docs/repository-baseline.md` - audit note for the baseline repository decisions and validation commands.
- **FILE-006**: `scripts/README.md` - tracked scripts directory marker.
- **FILE-007**: `output/.gitkeep` - tracked evidence root marker while generated evidence remains ignored.
- **FILE-008**: `.agents/plans/01-git-and-repo-baseline.md` - this implementation plan; it remains local agent metadata and is ignored by the baseline `.gitignore`.

## 6. Testing

- **TEST-001**: Run `git rev-parse --is-inside-work-tree` after `git init`; expected output is `true`.
- **TEST-002**: Run `git check-ignore -v .DS_Store skills-lock.json final-project.pdf classes/DevOps_Final\ Project_MTA_2026_SemB.pdf .agents/plans/01-git-and-repo-baseline.md output/playwright/report.html`; expected result is that every path is ignored and the command exits with status `0`.
- **TEST-003**: Run `git diff --cached --name-only` before committing; expected tracked file set is `.gitignore`, `AGENTS.md`, `README.md`, `contribution.md`, `docs/repository-baseline.md`, `output/.gitkeep`, and `scripts/README.md`.
- **TEST-004**: Run `git log --oneline -1` after committing; expected subject is `chore: initialize devops final project repository`.
- **TEST-005**: Run `git status --short` after committing; expected output is empty.
- **TEST-006**: Run `git ls-files`; expected output contains the seven tracked baseline files and does not contain `.agents/`, `.codex/`, `skills-lock.json`, `final-project.pdf`, `classes/`, `.DS_Store`, or generated `output/` artifacts.

## 7. Risks & Assumptions

- **RISK-001**: Ignoring all `*.pdf` files prevents accidental course-material commits, but it also means final Gatling report PDFs under `output/` will not be tracked. This is intentional because final evidence is submitted by email, not committed by default.
- **RISK-002**: Tracking `AGENTS.md` and `contribution.md` exposes the local operating and compliance handbooks in the public repository. This is acceptable because they contain no secrets and help defend implementation decisions, but they can be removed later if the team wants a cleaner public repository.
- **RISK-003**: The `<group-names>` context path is not known in this phase. The README keeps it as a documented assignment variable until plan `03-jsp-maven-war-app.md` sets the real context name.
- **RISK-004**: OneDrive sync may create transient files during implementation. The `.gitignore` must be created before broad staging.
- **ASSUMPTION-001**: The public GitHub repository has not been created or selected yet.
- **ASSUMPTION-002**: This phase does not require a remote push.
- **ASSUMPTION-003**: This phase does not add production code; TDD becomes mandatory for future behavior-bearing code and scripts introduced by later plans.
- **ASSUMPTION-004**: The user wants `.agents/plans/01-git-and-repo-baseline.md` updated in place instead of creating a new `/plan/process-git-baseline-1.md` file.

## 8. Related Specifications / Further Reading

- `AGENTS.md` - local agent operating handbook that points implementation work to `contribution.md`.
- `contribution.md` - local project compliance rules, tool version policy, container topology, Playwright override, evidence standards, and submission checklist.
- `.agents/plans/00-update-project-constraints.md` - preceding plan that defines the container-first project constraints.
- `.agents/plans/02-docker-compose-foundation.md` - next plan after the Git baseline is committed.
- `final-project.pdf` - assignment contract; do not commit this file to the public Git repository.
