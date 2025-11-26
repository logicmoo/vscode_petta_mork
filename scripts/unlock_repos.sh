#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="${WORKSPACE:-$HOME/vscode_petta_mork}"
CONFIG_FILE="$WORKSPACE/config/upstreams.list"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Cannot find $CONFIG_FILE" >&2
    exit 1
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^# ]] || [[ -z "$line" ]]; then
        printf "%s\n" "$line" >>"$tmp"
        continue
    fi
    repo=$(echo "$line" | awk '{print $1}')
    url=$(echo "$line" | awk '{print $2}')
    branch=$(echo "$line" | awk '{print $3}')
    pin=$(echo "$line" | awk '{print $4}')

    case "$pin" in
        AUTO|TIP|LATEST|"")
            printf "%s\n" "$line" >>"$tmp"
            ;;
        *)
            printf "%s\t%s\t%s\tAUTO\n" "$repo" "$url" "$branch" >>"$tmp"
            ;;
    esac
done <"$CONFIG_FILE"

mv "$tmp" "$CONFIG_FILE"
echo "Unlocked $CONFIG_FILE (set all pins to AUTO)."
