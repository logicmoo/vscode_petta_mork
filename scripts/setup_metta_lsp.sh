#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && cd .. && pwd)"
METTA_DIR="${METTA_DIR:-$REPO_ROOT/upstreams/metta-wam}"
PORT="${PORT:-40222}"
INSTALL_VSIX="${INSTALL_VSIX:-false}"
START_SERVER="${START_SERVER:-false}"

if ! command -v node >/dev/null 2>&1; then
  echo "node is not installed; please install node (e.g., via nvm)" >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is not installed alongside node; please install npm" >&2
  exit 1
fi

if ! command -v npx >/dev/null 2>&1; then
  echo "npx is not available; update your npm to a recent version" >&2
  exit 1
fi

VSIX_DIR="$METTA_DIR/libraries/lsp_server_metta/vscode"
cd "$VSIX_DIR"

npm install

npx vsce package

VSIX_PATH="$(ls -1 metta-lsp-*.vsix | tail -n1)"
echo "Built extension: $VSIX_PATH"

if [ "$INSTALL_VSIX" = "true" ]; then
  if ! command -v code >/dev/null 2>&1; then
    echo "VS Code CLI `code` not found; run \`code --install-extension $VSIX_PATH\` manually." >&2
  else
    code --install-extension "$VSIX_PATH"
    echo "Installed $VSIX_PATH into VS Code."
  fi
else
  echo "Set INSTALL_VSIX=true to auto-install the generated .vsix into VS Code."
fi

if [ "$START_SERVER" = "true" ]; then
  if ! command -v swipl >/dev/null 2>&1; then
    echo "SWI-Prolog not available; install it before starting the LSP server." >&2
    exit 1
  fi
  METTA_ENV="
METTALOG_DIR=$METTA_DIR
SWIPL_PACK_PATH=$METTA_DIR/libraries"

  echo "Starting lsp_server_metta on port $PORT (PID will be printed) ..."
  env METTALOG_DIR="$METTA_DIR" SWIPL_PACK_PATH="$METTA_DIR/libraries" \
    swipl -l "$METTA_DIR/libraries/lsp_server_metta/prolog/lsp_server_metta.pl" \
      -g lsp_server_metta:main -t halt -- port "$PORT" &
  SERVER_PID=$!
  echo "LSP server PID: $SERVER_PID (use kill $SERVER_PID to stop it)"
  echo "Configure your editor to connect to localhost:$PORT or let the extension spawn its own server."
else
  echo "Set START_SERVER=true (plus optional PORT) if you want this script to launch the lsp_server."
fi
