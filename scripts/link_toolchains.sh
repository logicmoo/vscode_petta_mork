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
    if [[ -e "$home_link" && ! -L "$home_link" ]]; then
        log "→ Moving existing $home_link contents into $workspace_target"
        mkdir -p "$workspace_target"
        if [[ -n "$(ls -A "$home_link" 2>/dev/null)" ]]; then
            cp -a "$home_link"/. "$workspace_target"/
        fi
        rm -rf "$home_link"
    elif [[ -L "$home_link" ]]; then
        local current
        current="$(readlink "$home_link" || true)"
        if [[ "$current" == "$workspace_target" ]]; then
            log "✓ $home_link already links to $workspace_target"
            return
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

sync_swipl_packs() {
    local home_rel="$1"
    local workspace_rel="$2"
    local repo_pack="$WORKSPACE/$workspace_rel"
    local host_pack="$HOME/$home_rel"

    mkdir -p "$repo_pack" "$host_pack"

    shopt -s dotglob nullglob
    for entry in "$host_pack"/*; do
        [[ -e "$entry" ]] || continue
        local name
        name="$(basename "$entry")"
        if [[ -L "$entry" ]]; then
            local target
            target="$(readlink -f "$entry" || true)"
            if [[ "$target" == "$repo_pack/$name" ]]; then
                continue
            fi
            rm -f "$entry"
            continue
        fi
        if [[ -e "$repo_pack/$name" ]]; then
            rm -rf "$repo_pack/$name"
        fi
        mv "$entry" "$repo_pack/$name"
        ln -s "$repo_pack/$name" "$host_pack/$name"
    done

    for entry in "$repo_pack"/*; do
        [[ -e "$entry" ]] || continue
        local name
        name="$(basename "$entry")"
        if [[ -L "$host_pack/$name" ]]; then
            local target
            target="$(readlink -f "$host_pack/$name" || true)"
            if [[ "$target" == "$repo_pack/$name" ]]; then
                continue
            fi
            rm -f "$host_pack/$name"
        elif [[ -e "$host_pack/$name" ]]; then
            rm -rf "$host_pack/$name"
        fi
        ln -s "$repo_pack/$name" "$host_pack/$name"
    done
    shopt -u dotglob nullglob
    log "→ Synced SWI-Prolog packs for $home_rel"
}

sync_swipl_packs ".config/swi-prolog/pack" ".config/swi-prolog/pack"
sync_swipl_packs ".local/share/swi-prolog/pack" ".local/share/swi-prolog/pack"
