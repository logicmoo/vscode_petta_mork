# vscode_petta_mork – Unified Development Workspace

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

## 2. Setup Workspace

```bash
unzip vscode_petta_mork_full_template.zip
mv vscode_petta_mork ~/vscode_petta_mork
cd ~/vscode_petta_mork
```

## 3. Build Dev Container

```bash
make build
```

## 4. Sync Upstream Repos

```bash
make bootstrap
```

## 5. Link Shared Toolchains & Config

Create the host/container symlinks for the Rust toolchain caches and SWI-Prolog packs so editors and the devcontainer see the same paths:

```bash
./scripts/link_toolchains.sh
```

This script links `~/vscode_petta_mork/.cargo` → `~/.cargo`, `~/vscode_petta_mork/.rustup` → `~/.rustup`, and `~/.config/swi-prolog/pack` → `~/vscode_petta_mork/.config/swi-prolog/pack`.

## 6. Create Python venv

```bash
docker compose run --rm petta-dev bash -lc 'cd ~/vscode_petta_mork && python3 -m venv .venv'
```

## 7. Enter Dev Shell

```bash
make up
```

## 8. VS Code

Open folder: `~/vscode_petta_mork`, then **Reopen in Container**.

## 9. Lock repo versions

```bash
make lock
```

## 10. Local-only workflow (no Docker)

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
