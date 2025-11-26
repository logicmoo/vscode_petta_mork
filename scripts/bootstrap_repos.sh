#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="${WORKSPACE:-"$HOME/vscode_petta_mork"}"
UPSTREAM_DIR="$WORKSPACE/upstreams"
CONFIG_FILE="$WORKSPACE/config/upstreams.list"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: Config file not found: $CONFIG_FILE" >&2
  exit 1
fi

mkdir -p "$UPSTREAM_DIR"

echo "Using workspace:     $WORKSPACE"
echo "Upstreams directory: $UPSTREAM_DIR"
echo "Config file:         $CONFIG_FILE"
echo

while read -r name url branch commit; do
  [[ -z "${name:-}" ]] && continue
  [[ "${name:0:1}" == "#" ]] && continue

  target="$UPSTREAM_DIR/$name"

  echo "==> Processing $name"
  echo "    URL:    $url"
  echo "    Branch: $branch"
  echo "    Commit: ${commit:-AUTO}"
  echo "    Path:   $target"

  if [[ -d "$target/.git" ]]; then
    echo "    Repo exists, fetching updates..."
    git -C "$target" fetch --all --prune
  else
    echo "    Cloning fresh repo..."
    git clone "$url" "$target"
  fi

  if ! git -C "$target" rev-parse --verify "$branch" >/dev/null 2>&1; then
    echo "    Creating local branch $branch from origin/$branch"
    git -C "$target" checkout -B "$branch" "origin/$branch"
  else
    echo "    Checking out existing branch $branch"
    git -C "$target" checkout "$branch"
  fi

  mode="${commit:-AUTO}"

  case "$mode" in
    AUTO|-)
      echo "    Mode: AUTO (fast-forward to origin/$branch if possible)"
      git -C "$target" pull --ff-only origin "$branch" || {
        echo "    WARNING: fast-forward failed; leaving repo as-is."
      }
      ;;
    TIP|LATEST)
      echo "    Mode: TIP (force to latest origin/$branch)"
      git -C "$target" fetch origin "$branch"
      git -C "$target" checkout "$branch"
      git -C "$target" reset --hard "origin/$branch"
      ;;
    *)
      echo "    Mode: PIN ($mode)"
      git -C "$target" fetch origin "$branch" || true
      git -C "$target" fetch origin "$mode" || true
      git -C "$target" checkout "$mode"
      ;;
  esac

  echo
done < "$CONFIG_FILE"

echo "All upstream repos are now synced under: $UPSTREAM_DIR"
