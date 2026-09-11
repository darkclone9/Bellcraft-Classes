#!/usr/bin/env bash
# Run the local Paper test server in the foreground (for a tmux/terminals slot).
# Console input is read from stdin, so commands can be sent to the running
# server (e.g. `plugins`, `sk list scripts`, `stop`).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER_DIR="$REPO_ROOT/server"

# Idempotent: ensures jars are present (cached after first run) and re-wires the
# repo's Skript scripts to the currently checked-out source before every boot.
bash "$REPO_ROOT/.cursor/setup-server.sh"

cd "$SERVER_DIR"
exec java -Xms1G -Xmx2G -XX:+UseG1GC -jar paper.jar nogui
