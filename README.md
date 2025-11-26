# vscode_petta_mork – Unified Development Workspace

For recent changes and outstanding tasks, see [`CHANGELOG.md`](CHANGELOG.md).

## 1. Install Docker

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
# If docker-compose-plugin isn't in your apt sources, install the legacy CLI:
# sudo apt install -y docker.io docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
mkdir -p ~/.docker && chmod 700 ~/.docker
newgrp docker  # or sign out/in so group membership applies
docker run hello-world
```

## 2. Build Dev Container

```bash
make build
```

## 3. Sync Upstream Repos

```bash
make bootstrap
```

## 4. Link Shared Toolchains & Config

Create the host/container symlinks for the Rust toolchain caches and SWI-Prolog packs so editors and the devcontainer see the same paths:

```bash
./scripts/link_toolchains.sh
```

This script links `~/vscode_petta_mork/.cargo` → `~/.cargo`, `~/vscode_petta_mork/.rustup` → `~/.rustup`, and keeps both `~/.config/swi-prolog/pack` and `~/.local/share/swi-prolog/pack` mirrored into the repo so SWI pack installs show up under version control.

## 5. Create Python venv

```bash
docker compose run --rm petta-dev bash -lc 'cd ~/vscode_petta_mork && python3 -m venv .venv'
```

## 6. Enter Dev Shell

```bash
make up
```

## 7. VS Code

Open folder: `~/vscode_petta_mork`, then **Reopen in Container**.

## 8. (Maintainers) Lock repo versions

```bash
make lock
```

Only run this when you need to pin `config/upstreams.list` for a release. Day-to-day contributors should **skip this step** so upstream repos continue tracking their configured branches. When you need to refresh the locked SHAs, run:

```bash
make update
```

which syncs upstreams (via `bootstrap`) and immediately re-locks them. To reset the file back to AUTO and pick up latest commits again:

```bash
make unlock
```

This command simply rewrites the fourth column in `config/upstreams.list` to `AUTO`.

## 9. Local-only workflow (no Docker)

If Docker isn't available or you prefer to run tooling directly on the host:

1. Install SWI-Prolog, Python 3, build tools, and create `.venv` by running:

   ```bash
   ./scripts/make_local.sh
   ```

   (You may be prompted for sudo to install packages via `apt`.)

2. Enter a host shell with the virtualenv activated:

   ```bash
   make local-shell
   ```

This path mirrors the container environment closely enough to run `pytest`, `swipl`, or other local tools without Docker.

## Repository Layout
- [`AGENTS.md`](AGENTS.md): Operating guidance for CLI agents working in this repo (structure, style, testing, review expectations).
- [`README.md`](README.md): You are here; overall onboarding instructions for developers.
- [`CHANGELOG.md`](CHANGELOG.md): Human-readable history plus TODO items.
- [`Makefile`](Makefile) / [`Taskfile.yml`](Taskfile.yml): Automation entry points for building the dev container, syncing upstreams, etc.
- [`config/`](config): Contains `upstreams.list`, the source of truth for external repositories pulled into `upstreams/`.
- [`docker/`](docker): Dockerfile and scripts used to build the `petta-dev` container image.
- [`docker-compose.yml`](docker-compose.yml): Defines the `petta-dev` service used by `make up` (bind-mounts the repo, sets user IDs).
- [`scripts/`](scripts): Helper scripts (`bootstrap_repos.sh`, `lock_repos.sh`, `link_toolchains.sh`, `unlock_repos.sh`, etc.) that automate workspace tasks.
- [`upstreams/`](upstreams): Auto-populated clones of external repositories (PeTTa, MORK, PathMap, etc.) managed via `make bootstrap`. Each upstream maintains its own README; edit code there only when vendoring fixes.

## TODO / Next Steps
- Port `upstreams/PeTTa/mork_ffi` to the latest MORK `DefaultSpace` API so `./build.sh` succeeds end-to-end.
- Add smoke tests once repo-specific code exists (e.g., `docker compose run --rm petta-dev pytest local/tests`).
- Remove the obsolete `version` key from `docker-compose.yml` to silence compose warnings.
