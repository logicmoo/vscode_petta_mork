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

APT_SUPPORTED=0
SUDO_CMD=""

if command -v apt-get >/dev/null 2>&1; then
  if [ "$EUID" -eq 0 ]; then
    APT_SUPPORTED=1
  elif command -v sudo >/dev/null 2>&1; then
    if sudo -n true >/dev/null 2>&1; then
      APT_SUPPORTED=1
      SUDO_CMD="sudo"
    else
      echo "sudo is available but cannot run non-interactively (perhaps due to container restrictions)."
      echo "Run the following commands manually in another shell with sufficient privileges:"
      echo "  sudo apt-get update"
      printf "  sudo apt-get install -y"; printf " %s" "${APT_PACKAGES[@]}"; echo
    fi
  else
    echo "apt-get detected but sudo is unavailable; install packages manually or rerun this script as root."
  fi

  if [ "$APT_SUPPORTED" -eq 1 ]; then
    echo "Detected apt-get; installing required packages."
    ${SUDO_CMD:+$SUDO_CMD }apt-get update
    ${SUDO_CMD:+$SUDO_CMD }apt-get install -y "${APT_PACKAGES[@]}"
  fi
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
