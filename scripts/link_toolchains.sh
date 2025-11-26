#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="${WORKSPACE:-$HOME/vscode_petta_mork}"

log() {
    printf '%s\n' "$*"
}

link_repo_view() {
    # Ensure $WORKSPACE/$1 points at $HOME/$1 (actual data kept in home)
    local rel="$1"
    local home_path="$HOME/$rel"
    local workspace_link="$WORKSPACE/$rel"

    mkdir -p "$home_path"
    if [[ -L "$workspace_link" || -e "$workspace_link" ]]; then
        if [[ -L "$workspace_link" ]]; then
            local current
            current="$(readlink "$workspace_link" || true)"
            if [[ "$current" == "$home_path" ]]; then
                log "✓ $workspace_link already links to $home_path"
                return
            fi
        fi
        rm -rf "$workspace_link"
    fi
    ln -s "$home_path" "$workspace_link"
    log "→ Linked $workspace_link -> $home_path"
}

link_home_to_workspace() {
    # Ensure $HOME/$1 points at $WORKSPACE/$2 (data owned by repo)
    local home_rel="$1"
    local workspace_rel="$2"
    local home_link="$HOME/$home_rel"
    local workspace_target="$WORKSPACE/$workspace_rel"

    mkdir -p "$workspace_target"
    mkdir -p "$(dirname "$home_link")"
    if [[ -L "$home_link" || -e "$home_link" ]]; then
        if [[ -L "$home_link" ]]; then
            local current
            current="$(readlink "$home_link" || true)"
            if [[ "$current" == "$workspace_target" ]]; then
                log "✓ $home_link already links to $workspace_target"
                return
            fi
        fi
        rm -rf "$home_link"
    fi
    ln -s "$workspace_target" "$home_link"
    log "→ Linked $home_link -> $workspace_target"
}

ensure_rustup() {
    local needs=0
    [[ ! -d "$HOME/.cargo" ]] && needs=1
    [[ ! -f "$HOME/.cargo/env" ]] && needs=1
    [[ -L "$HOME/.cargo/env" ]] && needs=1
    [[ ! -d "$HOME/.rustup" ]] && needs=1
    if [[ $needs -eq 1 ]]; then
        log "Repairing rustup toolchain in $HOME (this may take a moment)..."
        curl https://sh.rustup.rs -sSf | sh -s -- -y >/dev/null
    fi
}

ensure_rustup

link_repo_view ".cargo"
link_repo_view ".rustup"

link_home_to_workspace ".config/swi-prolog/pack" ".config/swi-prolog/pack"
