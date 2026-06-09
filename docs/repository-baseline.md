# Repository Baseline

## Baseline Date

2026-06-09

## Commands Run

- `git rev-parse --is-inside-work-tree`: `true`
- `git --version`: `git version 2.50.1 (Apple Git-155)`
- `git config --global user.name`: `y0ncha`
- `git config --global user.email`: `yonatancs@mta.ac.il`
- `find . -maxdepth 2 -type f -print`: used to identify local files that must not be staged.

## Tracked Baseline Files

- `.gitignore`
- `README.md`
- `AGENTS.md`
- `contribution.md`
- `docs/repository-baseline.md`
- `scripts/README.md`
- `output/.gitkeep`

## Ignored Artifact Classes

- Local agent and workspace metadata: `.agents/`, `.codex/`, `skills-lock.json`
- Course material and assignment PDFs: `classes/`, `*.pdf`
- Generated evidence: `output/**` except `output/.gitkeep`
- Java and Maven output: `target/`, `*.class`, `*.war`
- Docker and Jenkins local state: `.docker/`, `docker-data/`, `jenkins_home/`, `.jenkins/`, `*.log`
- Node and browser test output: `node_modules/`, `playwright-report/`, `test-results/`, `.playwright/`, `blob-report/`
- Gatling output: `gatling-results/`, `results/`
- Environment and secret files: `.env`, `.env.*`, keys, certificates, `secrets/`, `credentials/`
- Temporary, editor, and OS files: `.DS_Store`, `.idea/`, `.vscode/`, swap files, caches, and temp files

## Next Plan

`.agents/plans/02-docker-compose-foundation.md`
