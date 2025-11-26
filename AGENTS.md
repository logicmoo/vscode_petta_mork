# Repository Guidelines

## Project Structure & Module Organization
The workspace is mirrored on host and container at `~/vscode_petta_mork`. Place custom code under `local/src`, notebooks in `local/notebooks`, and tests in `local/tests`. External dependencies must live under `upstreams/<name>` and be managed solely through `config/upstreams.list` plus the helpers inside `scripts/`. Container plumbing remains in `docker/` and `.devcontainer/`, while automation entry points (`Makefile`, `Taskfile.yml`) stay at the root alongside this guide. Keep the shared Python virtualenv in `.venv` so both host shells and devcontainers activate identical tooling.

## Build, Test, and Development Commands
- `make build` (or `task build`): build the `petta-dev` image defined in `docker/Dockerfile`.
- `make up`: open an interactive shell inside the container; run Python/Prolog tooling there so UID/GID stay aligned.
- `make bootstrap`: execute `scripts/bootstrap_repos.sh` to sync every entry in `config/upstreams.list`.
- `make lock`: execute `scripts/lock_repos.sh`, replacing AUTO/TIP entries with pinned SHAs for reproducibility. Only release maintainers should run this; contributors normally leave upstreams on AUTO/TIP. When making changes under `config/`, `docker/`, `scripts/`, or `upstreams/`, read the README inside each directory for context before editing.
- `make update`: for maintainers, runs `make bootstrap` followed by `make lock` to refresh upstream checkouts and re-pin SHAs in one step.
- `make unlock`: resets the fourth column in `config/upstreams.list` back to `AUTO` so upstreams follow their branches again.
- Run tests with `docker compose run --rm petta-dev pytest local/tests` once code exists; add language-specific runners in the same fashion.

## Coding Style & Naming Conventions
Python modules follow PEP 8 with 4-space indents, snake_case filenames (`local/src/my_module.py`), and explicit virtualenv shebangs for executables. Shell utilities stay POSIX-friendly Bash, start with `#!/usr/bin/env bash`, and include `set -euo pipefail` plus descriptive function names (see current scripts). Mirror upstream directory names (`PeTTa`, `MORK`) when cloning, and keep configuration values in lowercase `key=value` style where applicable. Document nonstandard conventions in `README.md` before relying on them.

## Testing Guidelines
Write tests next to the code they validate (e.g., `local/tests/test_scheduler.py` for `local/src/scheduler.py`). Prefer `pytest` for Python and keep fixtures deterministic so upstream pinning stays meaningful. Aim for smoke coverage over every service touched by bootstrap scripts before requesting review, and document new test commands inside the README when they extend beyond `pytest`. Prefix files with `test_` or suffix with `_spec` so discovery works without custom flags.

## Commit & Pull Request Guidelines
Adopt short, imperative commit titles similar to the current history (`Initial`). Group unrelated refactors into separate commits so bisects stay easy when upstream SHAs shift. Every pull request should include a summary of user-facing changes, which commands were run (`make bootstrap`, `pytest`, etc.), any required screenshots/logs, and references to linked issues or upstream repos. Mention whether `config/upstreams.list` was modified manually or via `make lock`, since reviewers need that detail for reproducibility.

## PeTTa & MORK Build Playbook
Run these commands inside the `petta-dev` container (`make up`) so SWI-Prolog and build-essential packages are present. Install the Rust toolchain via `rustup` (Rust 1.88+ per `upstreams/PathMap/Cargo.toml`) before attempting any of the builds.

1. **Bootstrap upstreams**
   - `make bootstrap` to populate `upstreams/PeTTa`, `upstreams/MORK`, and `upstreams/PathMap`.

2. **Build PathMap first (MORK depends on it)**
   - `cd upstreams/PathMap`
   - `rustup default stable && rustup component add clippy rustfmt` (keeps local tooling consistent with the repos’ `rust-version`)
   - `cargo build --release -p pathmap --features "jemalloc zipper_tracking arena_compact"` to produce `target/release/libpathmap.rlib`.
   - Optional sanity check: `cargo test --release pathmap`.
   - When iterating locally, point MORK at the clone by editing `[workspace.dependencies.pathmap]` in `upstreams/MORK/Cargo.toml` to uncomment `path = "../PathMap"` and comment out the `git` fields.

3. **Build the MORK server**
   - `cd upstreams/MORK`
   - `cargo build --release --bin mork-server` (pulls `pathmap` with the features above).
   - Start the daemon with `./target/release/mork-server` and smoke-test via `python python/client.py` from another shell as documented in `upstreams/MORK/README.md`.

4. **Build PeTTa (wraps SWI-Prolog with the MORK FFI)**
   - `cd upstreams/PeTTa`
   - `./build.sh` compiles `mork_ffi` (`cargo build -p mork_ffi --release`) and links `mork.c` against SWI-Prolog via `pkg-config`.
  - `./run.sh examples/tests.metta` runs PeTTa with `LD_PRELOAD=./mork_ffi/target/release/libmork_ffi.so` so the compiled kernel is available.
- `./test.sh` exercises the shipped `.metta` examples in parallel; `python -m pytest python/tests` checks the thin Python wrapper.

## Shared Tooling & Config Mirrors
- Keep the heavyweight Rust toolchain in your actual home (`~/.cargo`, `~/.rustup`) so rustup/cargo stay standard. Run `./scripts/link_toolchains.sh` to drop symlinks from the workspace back to those directories and to create the inverse link for SWI-Prolog packs.
- House VS Code settings and other workspace configs directly under `~/vscode_petta_mork/.vscode/` so the editor can edit them and so they can be tracked in git.
- SWI-Prolog packs can live in-repo for easier editing: the script above guarantees `~/.config/swi-prolog/pack` points at `~/vscode_petta_mork/.config/swi-prolog/pack`, which works for both the host and the `petta-dev` container thanks to the bind mount.
