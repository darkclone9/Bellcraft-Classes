#!/usr/bin/env bash
# Cloud Agent install step for Bellcraft-Classes.
#
# This repo ships Paper/Spigot plugin configuration (YAML + Skript), not
# compiled source, so "install" (1) validates every YAML config and (2)
# bootstraps a local Paper test server with the freely available plugins the
# repo's Skript code targets. Both steps are idempotent.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# The config validator needs PyYAML (present on the default image; guard anyway).
python3 -c 'import yaml' 2>/dev/null \
  || pip install --quiet --user pyyaml 2>/dev/null \
  || pip install --quiet pyyaml 2>/dev/null \
  || true

echo "== Validating YAML configs =="
# Non-fatal: report breakage in build/setup logs but still bring the env up so
# a work-in-progress config never blocks the environment.
python3 "$REPO_ROOT/.cursor/validate_configs.py" \
  || echo "[install] Config validation reported errors above (non-fatal)."

echo "== Bootstrapping local Paper test server =="
bash "$REPO_ROOT/.cursor/setup-server.sh"

echo "== Install complete =="
