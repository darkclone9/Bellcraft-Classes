#!/usr/bin/env bash
# Bootstrap a local Paper (Spigot-compatible) test server for Bellcraft-Classes.
#
# This repo ships plugin *configuration* (YAML + Skript). The premium RPG
# plugins (MMOCore, MMOItems, Nexo, CoreTools, ...) cannot be redistributed and
# are intentionally NOT downloaded here. This bootstraps a real Paper server
# with the FREELY available plugins the repo's Skript town-economy code targets
# (Skript, Vault, LuckPerms, PlaceholderAPI, skript-placeholders, Towny) and
# wires the repo's actual Skript scripts into it, so the scripts are loaded by
# the real Skript engine.
#
# Idempotent: re-running skips already-downloaded jars and refreshes wiring.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER_DIR="$REPO_ROOT/server"
PLUGINS_DIR="$SERVER_DIR/plugins"
CACHE_DIR="$SERVER_DIR/.cache"

PAPER_MC_VERSION="1.21.8"
SKRIPT_VERSION="2.16.2"
VAULT_VERSION="1.7.3"
PAPI_VERSION="2.12.3"
SKRIPT_PLACEHOLDERS_VERSION="1.7.1"
TOWNY_VERSION="0.103.2.0"

mkdir -p "$PLUGINS_DIR" "$CACHE_DIR"

log() { printf '\n[setup-server] %s\n' "$*"; }

# download <url> <dest> — cached, resumable, fails loudly on empty result.
download() {
  local url="$1" dest="$2"
  if [[ -s "$dest" ]]; then
    log "cached: $(basename "$dest")"
    return 0
  fi
  log "downloading $(basename "$dest")"
  curl -fSL --retry 4 --retry-delay 3 -o "$dest.tmp" "$url"
  if [[ ! -s "$dest.tmp" ]]; then
    echo "[setup-server] ERROR: empty download from $url" >&2
    exit 1
  fi
  mv "$dest.tmp" "$dest"
}

# ---- Paper server jar (resolve latest build for the pinned MC version) ----
PAPER_JAR="$SERVER_DIR/paper.jar"
if [[ ! -s "$PAPER_JAR" ]]; then
  log "resolving latest Paper build for $PAPER_MC_VERSION"
  read -r PAPER_URL PAPER_NAME < <(
    curl -fSL "https://fill.papermc.io/v3/projects/paper/versions/${PAPER_MC_VERSION}/builds/latest" \
      | python3 -c "import sys,json;d=json.load(sys.stdin);x=d['downloads']['server:default'];print(x['url'],x['name'])"
  )
  log "Paper build: $PAPER_NAME"
  download "$PAPER_URL" "$CACHE_DIR/$PAPER_NAME"
  cp "$CACHE_DIR/$PAPER_NAME" "$PAPER_JAR"
else
  log "cached: paper.jar"
fi

# ---- Free plugins ----
download "https://github.com/SkriptLang/Skript/releases/download/${SKRIPT_VERSION}/Skript-${SKRIPT_VERSION}.jar" \
  "$PLUGINS_DIR/Skript-${SKRIPT_VERSION}.jar"

download "https://github.com/MilkBowl/Vault/releases/download/${VAULT_VERSION}/Vault.jar" \
  "$PLUGINS_DIR/Vault-${VAULT_VERSION}.jar"

download "https://github.com/PlaceholderAPI/PlaceholderAPI/releases/download/${PAPI_VERSION}/PlaceholderAPI-${PAPI_VERSION}.jar" \
  "$PLUGINS_DIR/PlaceholderAPI-${PAPI_VERSION}.jar"

download "https://github.com/APickledWalrus/skript-placeholders/releases/download/${SKRIPT_PLACEHOLDERS_VERSION}/skript-placeholders-${SKRIPT_PLACEHOLDERS_VERSION}.jar" \
  "$PLUGINS_DIR/skript-placeholders-${SKRIPT_PLACEHOLDERS_VERSION}.jar"

# LuckPerms: resolve the current Bukkit build from the metadata service.
if ! ls "$PLUGINS_DIR"/LuckPerms-Bukkit-*.jar >/dev/null 2>&1; then
  LP_URL="$(curl -fSL https://metadata.luckperms.net/data/downloads \
    | python3 -c "import sys,json;print(json.load(sys.stdin)['downloads']['bukkit'])")"
  download "$LP_URL" "$PLUGINS_DIR/$(basename "$LP_URL")"
else
  log "cached: LuckPerms"
fi

# Towny ships as a zip that contains the plugin jar.
if ! ls "$PLUGINS_DIR"/Towny*.jar >/dev/null 2>&1; then
  TOWNY_ZIP="$CACHE_DIR/Towny.Advanced.${TOWNY_VERSION}.zip"
  download "https://github.com/TownyAdvanced/Towny/releases/download/${TOWNY_VERSION}/Towny.Advanced.${TOWNY_VERSION}.zip" \
    "$TOWNY_ZIP"
  TOWNY_JAR_IN_ZIP="$(unzip -Z1 "$TOWNY_ZIP" | grep -iE '^[^/]*Towny.*\.jar$' | head -1)"
  unzip -o -j "$TOWNY_ZIP" "$TOWNY_JAR_IN_ZIP" -d "$PLUGINS_DIR" >/dev/null
  log "extracted Towny jar: $TOWNY_JAR_IN_ZIP"
else
  log "cached: Towny"
fi

# ---- Server files ----
echo "eula=true" > "$SERVER_DIR/eula.txt"

if [[ ! -f "$SERVER_DIR/server.properties" ]]; then
  log "writing server.properties"
  cat > "$SERVER_DIR/server.properties" <<'PROPS'
# Bellcraft-Classes local test server (dev only)
online-mode=false
motd=Bellcraft-Classes dev test server
max-players=10
view-distance=5
simulation-distance=5
spawn-protection=0
enable-command-block=false
level-type=minecraft:normal
allow-nether=false
enable-rcon=false
sync-chunk-writes=false
PROPS
fi

# ---- Wire the repo's actual Skript scripts into the server ----
SKRIPT_SCRIPTS_DIR="$PLUGINS_DIR/Skript/scripts"
mkdir -p "$SKRIPT_SCRIPTS_DIR/bellcraft"
# Refresh the repo scripts each run so edits are picked up on the next reload.
rm -f "$SKRIPT_SCRIPTS_DIR/bellcraft/"*.sk
cp "$REPO_ROOT"/Skript/scripts/*.sk "$SKRIPT_SCRIPTS_DIR/bellcraft/"
log "wired $(ls -1 "$SKRIPT_SCRIPTS_DIR/bellcraft/"*.sk | wc -l) repo Skript scripts into the server"

log "server bootstrap complete: $SERVER_DIR"
