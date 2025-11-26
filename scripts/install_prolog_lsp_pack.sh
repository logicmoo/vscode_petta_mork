#!/usr/bin/env bash
set -euo pipefail

PACK_NAME="lsp_server"
REPO_ROOT="$(cd "$(dirname "$0")" && cd .. && pwd)"
PACK_REPO="$REPO_ROOT/upstreams/$PACK_NAME"
PACK_ROOTS=(".config/swi-prolog/pack" ".local/share/swi-prolog/pack")

log() {
  printf '%s\n' "$*" >&2
}

ensure_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log "Missing required command: $cmd"
    exit 1
  fi
}

find_python() {
  if command -v python3 >/dev/null 2>&1; then
    printf 'python3\n'
  elif command -v python >/dev/null 2>&1; then
    printf 'python\n'
  else
    log "python3 (or python) is required to compute relative paths."
    exit 1
  fi
}

python_eval() {
  local expr="$1"
  shift
  "$PYTHON_BIN" - "$expr" "$@" <<'PY'
import os
import sys

def relpath(start, target):
    start_abs = os.path.abspath(start)
    target_abs = os.path.abspath(target)
    return os.path.relpath(target_abs, start_abs)

def canonical(path):
    return os.path.realpath(path)

expr = sys.argv[1]
args = sys.argv[2:]

if expr == "relpath":
    print(relpath(*args))
elif expr == "canonical":
    print(canonical(*args))
else:
    raise SystemExit(f"unknown expr: {expr}")
PY
}

relpath() {
  python_eval relpath "$@"
}

canonical_path() {
  python_eval canonical "$1"
}

link_pack_tree() {
  local relative_root="$1"

  local repo_pack_root="$REPO_ROOT/$relative_root"
  local host_pack_root="$HOME/$relative_root"
  local repo_link="$repo_pack_root/$PACK_NAME"
  local host_link="$host_pack_root/$PACK_NAME"

  mkdir -p "$repo_pack_root" "$host_pack_root"

  if [[ -e "$repo_link" || -L "$repo_link" ]]; then
    rm -rf "$repo_link"
  fi
  local relative_target
  relative_target="$(relpath "$repo_pack_root" "$PACK_REPO")"
  ln -s "$relative_target" "$repo_link"
  log "Linked repo pack: $repo_link -> $relative_target"

  local repo_root_real host_root_real
  repo_root_real="$(canonical_path "$repo_pack_root")"
  host_root_real="$(canonical_path "$host_pack_root")"

  if [[ "$host_root_real" == "$repo_root_real" ]]; then
    log "Host pack root $host_pack_root already mirrors repo path; skipping nested link."
    return
  fi

  if [[ -e "$host_link" || -L "$host_link" ]]; then
    rm -rf "$host_link"
  fi
  ln -s "$repo_link" "$host_link"
  log "Linked host pack: $host_link -> $repo_link"
}

ensure_command swipl
PYTHON_BIN="$(find_python)"

if [[ ! -d "$PACK_REPO/.git" ]]; then
  log "Missing upstream clone at $PACK_REPO"
  log "Run ./scripts/bootstrap_repos.sh after adding $PACK_NAME to config/upstreams.list"
  exit 1
fi

for pack_root in "${PACK_ROOTS[@]}"; do
  link_pack_tree "$pack_root"
done

log "Rebuilding SWI-Prolog pack $PACK_NAME ..."
swipl -q -g "pack_rebuild($PACK_NAME)" -t halt
log "Pack $PACK_NAME rebuilt successfully."
