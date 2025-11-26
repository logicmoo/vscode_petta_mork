#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

APT_PACKAGES=(
  git
  python3
  python3-venv
  python3-pip
  swi-prolog
  build-essential
)

echo "Preparing local environment at $REPO_ROOT"

if command -v apt-get >/dev/null 2>&1; then
  echo "Detected apt-get; installing required packages (sudo privileges needed)."
  sudo apt-get update
  sudo apt-get install -y "${APT_PACKAGES[@]}"
else
  echo "apt-get not found. Please install the following packages manually before continuing:"
  printf '  - %s\n' "${APT_PACKAGES[@]}"
fi

if [ ! -d ".venv" ]; then
  echo "Creating Python virtualenv at .venv"
  python3 -m venv .venv
else
  echo "Python virtualenv already exists at .venv"
fi

echo
echo "Local environment prepared."
echo "Activate it via: source .venv/bin/activate"
echo "or run: ./scripts/local_shell.sh"
