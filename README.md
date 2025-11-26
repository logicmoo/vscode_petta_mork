# vscode_petta_mork – Unified Development Workspace

## 1. Install Docker

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker
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

## 8. Lock repo versions

```bash
make lock
```

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
