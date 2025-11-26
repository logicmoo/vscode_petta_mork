# Repository Guidelines

## Project Structure & Module Organization
The workspace is mirrored on host and container at `~/vscode_petta_mork`. Place custom code under `local/src`, notebooks in `local/notebooks`, and tests in `local/tests`. External dependencies must live under `upstreams/<name>` and be managed solely through `config/upstreams.list` plus the helpers inside `scripts/`. Container plumbing remains in `docker/` and `.devcontainer/`, while automation entry points (`Makefile`, `Taskfile.yml`) stay at the root alongside this guide. Keep the shared Python virtualenv in `.venv` so both host shells and devcontainers activate identical tooling.

## Build, Test, and Development Commands
- `make build` (or `task build`): build the `petta-dev` image defined in `docker/Dockerfile`.
- `make up`: open an interactive shell inside the container; run Python/Prolog tooling there so UID/GID stay aligned.
- `make bootstrap`: execute `scripts/bootstrap_repos.sh` to sync every entry in `config/upstreams.list`.
- `make lock`: execute `scripts/lock_repos.sh`, replacing AUTO/TIP entries with pinned SHAs for reproducibility.
- Run tests with `docker compose run --rm petta-dev pytest local/tests` once code exists; add language-specific runners in the same fashion.

## Coding Style & Naming Conventions
Python modules follow PEP 8 with 4-space indents, snake_case filenames (`local/src/my_module.py`), and explicit virtualenv shebangs for executables. Shell utilities stay POSIX-friendly Bash, start with `#!/usr/bin/env bash`, and include `set -euo pipefail` plus descriptive function names (see current scripts). Mirror upstream directory names (`PeTTa`, `MORK`) when cloning, and keep configuration values in lowercase `key=value` style where applicable. Document nonstandard conventions in `README.md` before relying on them.

## Testing Guidelines
Write tests next to the code they validate (e.g., `local/tests/test_scheduler.py` for `local/src/scheduler.py`). Prefer `pytest` for Python and keep fixtures deterministic so upstream pinning stays meaningful. Aim for smoke coverage over every service touched by bootstrap scripts before requesting review, and document new test commands inside the README when they extend beyond `pytest`. Prefix files with `test_` or suffix with `_spec` so discovery works without custom flags.

## Commit & Pull Request Guidelines
Adopt short, imperative commit titles similar to the current history (`Initial`). Group unrelated refactors into separate commits so bisects stay easy when upstream SHAs shift. Every pull request should include a summary of user-facing changes, which commands were run (`make bootstrap`, `pytest`, etc.), any required screenshots/logs, and references to linked issues or upstream repos. Mention whether `config/upstreams.list` was modified manually or via `make lock`, since reviewers need that detail for reproducibility.
