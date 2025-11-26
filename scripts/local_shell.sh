#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

if [ -d ".venv" ]; then
  echo "Activating virtual environment at $REPO_ROOT/.venv"
  # shellcheck disable=SC1091
  . ".venv/bin/activate"
fi

echo "Entering host shell in $REPO_ROOT (Docker not available)"
exec "${SHELL:-bash}" -l
