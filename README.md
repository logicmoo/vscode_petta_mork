# vscode_petta_mork – Unified Development Workspace

## 1. Install Docker

```bash
sudo apt update
sudo apt install -y docker.io
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
