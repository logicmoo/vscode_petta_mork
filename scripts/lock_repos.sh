#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="${WORKSPACE:-"$HOME/vscode_petta_mork"}"
UPSTREAM_DIR="$WORKSPACE/upstreams"
CONFIG_FILE="$WORKSPACE/config/upstreams.list"
TMP_FILE="$CONFIG_FILE.tmp"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: Config file not found: $CONFIG_FILE" >&2
  exit 1
fi

if [[ ! -d "$UPSTREAM_DIR" ]]; then
  echo "ERROR: Upstreams directory not found: $UPSTREAM_DIR" >&2
  exit 1
fi

echo "Locking repos based on current HEAD in: $UPSTREAM_DIR"
echo "Updating: $CONFIG_FILE"
echo

> "$TMP_FILE"

while read -r name url branch commit; do
  [[ -z "${name:-}" ]] && { echo >> "$TMP_FILE"; continue; }
  [[ "${name:0:1}" == "#" ]] && { echo "$name $url $branch $commit" >> "$TMP_FILE"; continue; }

  target="$UPSTREAM_DIR/$name"

  if [[ -d "$target/.git" ]]; then
    sha=$(git -C "$target" rev-parse HEAD)
    echo "Repo $name at $sha"
    printf "%-18s %-60s %-10s %s\n" "$name" "$url" "$branch" "$sha" >> "$TMP_FILE"
  else
    echo "WARNING: Repo directory missing for $name at $target; leaving line unchanged."
    printf "%s %s %s %s\n" "$name" "$url" "$branch" "${commit:-AUTO}" >> "$TMP_FILE"
  fi
done < "$CONFIG_FILE"

mv "$TMP_FILE" "$CONFIG_FILE"

echo
echo "Config updated with pinned SHAs."
