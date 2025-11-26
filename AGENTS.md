# AGENT BRIEFING – `vscode_petta_mork` Dev Environment

## 0. Who you are

You are a coding agent (Codex) helping to set up and maintain a **multi-repo, multi-language dev workspace** called `vscode_petta_mork`.

Your main jobs:

- Keep the **Docker dev environment** consistent and reproducible.
- Make sure **host and container share the same workspace path**.
- Manage **upstream GitHub clones** via `config/upstreams.list`.
- Keep everything friendly to **local editors** on the host and interpreted runtimes inside Docker.
- Maintain a **workspace-local Python virtual environment** (`.venv`) and auto-activate it in containers.
- Avoid git submodules; use **direct clones** instead.

---

## 1. High-level goals

1. **Single shared workspace** at:

   - Host: `/home/<username>/vscode_petta_mork`
   - Container: `/home/<username>/vscode_petta_mork`

   These paths must always match; the workspace is bind-mounted 1:1.

2. **Local editing, container runtime**

   - Source code lives on the host (and in this repo structure).
   - Container only provides tools (Python, Prolog, etc.).
   - Changes made by the host editor are instantly visible inside the container.

3. **Per-workspace Python virtualenv**

   - Virtualenv directory: `~/`vscode_petta_mork`/.venv`
   - It is **shared** between host and container.
   - Container shells should **auto-activate** `.venv` if it exists.

4. **Upstream GitHub repos are checked out directly**

   - No git submodules.
   - No nested git gymnastics.
   - Just plain `git clone` and sync via scripts using `config/upstreams.list`.

5. **Workspace operations are scriptable**

   - Use `scripts/bootstrap_repos.sh` to sync upstreams.
   - Use `scripts/lock_repos.sh` to pin upstreams to specific SHAs.
   - Use `Makefile` / `Taskfile.yml` as convenience frontends.

---

## 2. Workspace layout (contract)

The workspace is expected to look like this (and Codex should preserve/extend this layout):

```text
vscode_petta_mork/
│
├── .venv/                         # Python virtual environment (shared, not committed)
│
├── upstreams/                     # All external GitHub repos cloned directly here
│   ├── PeTTa/
│   ├── metta-examples/
│   ├── MettaWamJam/
│   ├── MORK/
│   ├── PathMap/
│   └── metta-wam/
│
├── local/                         # Local "glue" and sandbox code
│   ├── src/
│   ├── tests/
│   └── notebooks/
│
├── scripts/                       # Utility scripts for workspace management
│   ├── bootstrap_repos.sh         # Clones/updates all upstream repos based on config
│   └── lock_repos.sh              # Pins upstreams.list commit column to current HEADs
│
├── config/
│   └── upstreams.list             # Source of truth for upstream repos
│
├── docker/
│   └── Dockerfile                 # Dev container Dockerfile
│
├── .devcontainer/
│   └── devcontainer.json          # VSCode devcontainer wiring to docker-compose
│
├── .github/
│   └── workflows/
│       └── ci.yml                 # GitHub Actions CI pipeline
│
├── docker-compose.yml             # Dev service: petta-dev
├── Makefile                       # make build/up/bootstrap/lock
├── Taskfile.yml                   # task build/up/bootstrap/lock
└── AGENTS.md                      # This file
```

Codex should assume this structure and extend it in a compatible way.

---

## 3. Docker expectations

### 3.1 Paths and user identity

- Workspace mount:

  ```text
  Host:      /home/$USER/vscode_petta_mork
  Container: /home/$USER/vscode_petta_mork
  ```

- Container should run as a non-root user that matches the host’s `UID` and `GID`, so that file ownership stays clean.

### 3.2 Dockerfile requirements

The Dockerfile lives at `docker/Dockerfile` and must:

- Use a Linux base image (currently `ubuntu:22.04`).
- Install:

  - `git`
  - `python3`, `python3-pip`, `python3-venv`
  - `swi-prolog`
  - `build-essential`
  - basic tools (`bash`, `vim`, etc.)

- Accept build args:

  ```dockerfile
  ARG USERNAME
  ARG UID
  ARG GID
  ```

- Create a user with those settings and set:

  ```dockerfile
  USER $USERNAME
  ENV WORKSPACE=/home/$USERNAME/vscode_petta_mork
  WORKDIR $WORKSPACE
  ```

- Append to the user’s `.bashrc`:

  - `cd ~/vscode_petta_mork` on shell start (if it exists).
  - Auto-activate `.venv` if `~/vscode_petta_mork/.venv` exists:

    ```bash
    cd ~/vscode_petta_mork 2>/dev/null || true
    if [ -d "$HOME/vscode_petta_mork/.venv" ]; then
      . "$HOME/vscode_petta_mork/.venv/bin/activate"
    fi
    ```

- Use:

  ```dockerfile
  CMD ["/bin/bash"]
  ```

### 3.3 docker-compose expectations

The `docker-compose.yml` at workspace root must:

- Define a service `petta-dev` that:

  - Builds from `docker/Dockerfile`.
  - Supplies the `USERNAME`, `UID`, and `GID` build args from environment:

    ```yaml
    args:
      USERNAME: "${USER}"
      UID: "${UID}"
      GID: "${GID}"
    ```

  - Ensures the bind mount:

    ```yaml
    volumes:
      - /home/${USER}/vscode_petta_mork:/home/${USER}/vscode_petta_mork
    ```

  - Sets:

    ```yaml
    working_dir: /home/${USER}/vscode_petta_mork
    tty: true
    ```

The main purpose of `petta-dev` is **interactive development shells**.

---

## 4. VSCode devcontainer expectations

The `.devcontainer/devcontainer.json` file must:

- Reference `../docker-compose.yml`.
- Use `service: "petta-dev"`.
- Set the `workspaceFolder` to `/home/${localEnv:USER}/vscode_petta_mork`.
- Optionally install helpful extensions:

  - `ms-python.python`
  - `ms-python.vscode-pylance`
  - `ms-azuretools.vscode-docker`

- Run a `postCreateCommand` that ensures `.venv` exists:

  ```bash
  cd ~/vscode_petta_mork && if [ ! -d .venv ]; then python3 -m venv .venv; fi
  ```

Codex may evolve this config but must preserve compatibility with the described Docker setup.

---

## 5. Upstream repository management

### 5.1 Where upstreams live

All external GitHub repos are cloned into:

```text
vscode_petta_mork/upstreams/<name>/
```

For this workspace, the initial upstreams and their default branches are:

- `upstreams/PeTTa/`  
  - URL: `https://github.com/patham9/PeTTa.git`  
  - Branch: `main`

- `upstreams/metta-examples/`  
  - URL: `https://github.com/trueagi-io/metta-examples.git`  
  - Branch: `main`

- `upstreams/MettaWamJam/`  
  - URL: `https://github.com/jazzbox35/MettaWamJam.git`  
  - Branch: `main`

- `upstreams/MORK/`  
  - URL: `https://github.com/trueagi-io/MORK.git`  
  - Branch: `server`

- `upstreams/PathMap/`  
  - URL: `https://github.com/Adam-Vandervorst/PathMap.git`  
  - Branch: `master`

- `upstreams/metta-wam/`  
  - URL: `https://github.com/trueagi-io/metta-wam.git`  
  - Branch: `vnamed`

Each directory is a **normal Git repo** with its own `.git` directory.

### 5.2 Config file format: `config/upstreams.list`

This file is the **source of truth** for upstream repos.  

Format: one repo per line:

```text
name   url   branch   commit
```

- Separator: whitespace (spaces or tabs).
- Lines starting with `#` or empty lines are ignored.
- `commit` column semantics:

  - `AUTO` or empty → **Normal branch tracking**  
    - Perform `git pull --ff-only origin <branch>`.  
    - Attempt to fast-forward; keeps local work if compatible.

  - `TIP` or `LATEST` → **Force to remote tip**  
    - Perform `git fetch origin <branch>` and `git reset --hard origin/<branch>`.  
    - Discards local commits; ensures exact sync with branch tip.

  - Any other value (SHA, tag, etc.) → **Pin to that exact ref**  
    - `git checkout <commit>` after ensuring it's fetched.

Example:

```text
# name             url                                                 branch      commit
PeTTa              https://github.com/patham9/PeTTa.git                main        TIP
metta-examples     https://github.com/trueagi-io/metta-examples.git    main        AUTO
MettaWamJam        https://github.com/jazzbox35/MettaWamJam.git        main        AUTO
MORK               https://github.com/trueagi-io/MORK.git              server      LATEST
PathMap            https://github.com/Adam-Vandervorst/PathMap.git     master      AUTO
metta-wam          https://github.com/trueagi-io/metta-wam.git         vnamed      AUTO
```

Later, some `AUTO`/`TIP` entries may be replaced with explicit SHAs by `lock_repos.sh`.

### 5.3 `scripts/bootstrap_repos.sh`

This script must:

- Read `config/upstreams.list`.
- For each non-comment, non-empty line:

  - Create the repo directory under `upstreams/` if needed.
  - Clone the repo if missing, otherwise fetch updates.
  - Ensure the branch exists locally (tracking `origin/<branch>`).
  - Apply commit mode based on `commit` column:
    - `AUTO` → `git pull --ff-only origin <branch>`
    - `TIP` / `LATEST` → `git reset --hard origin/<branch>`
    - SHA/tag → `git checkout <that-ref>`

It must print clear diagnostic output for each repo (name, URL, branch, commit mode, and path).

### 5.4 `scripts/lock_repos.sh`

This script must:

- Walk the configuration `config/upstreams.list`.
- For each repo with a directory in `upstreams/<name>/.git`:
  - Get `git rev-parse HEAD`.
  - Rewrite the corresponding line in `upstreams.list` so the `commit` column is that SHA.
- Preserve comment and blank lines.
- Write changes atomically via a temporary file.

Mode semantics:

- It is intended for capturing a “known good” snapshot: it converts whatever commit mode was there (`AUTO`, `TIP`, `LATEST`, or old SHA) into a **fresh SHA** representing current HEAD.

---

## 6. GitHub Actions CI expectations

The workflow at `.github/workflows/ci.yml` must:

- Check out this repo.
- Create a workspace directory at `$HOME/vscode_petta_mork`.
- Copy the repo contents into that workspace.
- Set up a Python venv at `$HOME/vscode_petta_mork/.venv`.
- Optionally run `scripts/bootstrap_repos.sh` (non-fatal if some repos are private/unavailable).
- Provide a placeholder for real tests (pytest, SWI tests, etc.).

Codex may extend CI to run actual tests in `local/` or across upstreams once they are defined.

---

## 7. Python `.venv` behavior

- Virtualenv is always at:

  ```text
  ~/vscode_petta_mork/.venv
  ```

- It must **not** be created silently by scripts other than explicit bootstrap steps or the devcontainer postCreate hook.
- Once `.venv` exists, container shells should auto-activate it through `.bashrc`.
- Development tooling (linters, test runners, etc.) should assume that the active Python environment is this `.venv`.

---

## 8. Convenience tooling

### 8.1 Makefile

The `Makefile` at workspace root provides:

- `build` → `docker compose build`
- `up` / `shell` → run `petta-dev` interactively
- `bootstrap` → run `scripts/bootstrap_repos.sh`
- `lock` → run `scripts/lock_repos.sh`

Codex can add more targets but must keep these working.

### 8.2 Taskfile.yml

The `Taskfile.yml` mirrors the Makefile targets for `go-task` users:

- `build`
- `up`
- `shell`
- `bootstrap`
- `lock`

Same semantics as Makefile.

---

## 9. Things Codex should NOT do

- **Do not** introduce git submodules.
- **Do not** place upstream repos outside `upstreams/`.
- **Do not** rely on or modify global system paths outside `/home/$USER/vscode_petta_mork` in a way that breaks portability.
- **Do not** remove or repurpose `config/upstreams.list`, `scripts/bootstrap_repos.sh`, or `scripts/lock_repos.sh` without updating this contract.
- **Do not** assume root access inside the dev container at runtime; everything should work as the non-root user.

---

## 10. Typical usage patterns (for reference)

From the host:

```bash
# 1. Install this workspace at ~/vscode_petta_mork
unzip vscode_petta_mork_full_template.zip
mv vscode_petta_mork ~/vscode_petta_mork
cd ~/vscode_petta_mork

# 2. Build dev container image
make build
# or: docker compose build

# 3. Sync upstream repos according to config
make bootstrap
# or: ./scripts/bootstrap_repos.sh

# 4. Create and activate Python venv (first time via container or directly)
docker compose run --rm petta-dev bash -lc \
  'cd ~/vscode_petta_mork && python3 -m venv .venv && . .venv/bin/activate && pip install -U pip'

# 5. Start dev shell (venv auto-activates if present)
make up
# or: docker compose run --rm petta-dev
```

Codex should keep these workflows working and evolve scripts/configs to support them cleanly.
