# scripts/

Helper scripts invoked by the Makefile/Taskfile:

- [`bootstrap_repos.sh`](bootstrap_repos.sh) clones or updates every entry in `config/upstreams.list` into `../upstreams/`.
- [`lock_repos.sh`](lock_repos.sh) rewrites the pin column in `config/upstreams.list` to the currently checked-out SHAs (maintainers only).
- [`unlock_repos.sh`](unlock_repos.sh) resets the pin column to `AUTO`.
- [`link_toolchains.sh`](link_toolchains.sh) creates symlinks so the repo-visible `.cargo`, `.rustup`, and both SWI pack directories (`~/.config` and `~/.local/share`) mirror the host copies.
- Any new automation (e.g., test runners, lint wrappers) should be added here and wired into `Makefile`/`Taskfile.yml`.

Scripts are written for POSIX bash (`#!/usr/bin/env bash` + `set -euo pipefail`). Keep them idempotent so they can be re-run safely during onboarding.
