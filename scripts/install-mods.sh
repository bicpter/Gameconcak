#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/.env"

MODS_FILE="$PROJECT_DIR/mods/mods.txt"
SERVER_MODS_DIR="$PROJECT_DIR/data/server/mods"
WORKSHOP_DIR="$HOME/.steam/SteamApps/workshop/content/$WORKSHOP_APP_ID"

MASTER_MODOVERRIDES="$PROJECT_DIR/config/cluster/Master/modoverrides.lua"
CAVES_MODOVERRIDES="$PROJECT_DIR/config/cluster/Caves/modoverrides.lua"

echo "===================================="
echo " GAMECONCAK Mod Installer"
echo "===================================="

if ! command -v steamcmd >/dev/null 2>&1; then
    echo "ERROR: steamcmd not found."
    echo "Run: ./scripts/install.sh"
    exit 1
fi

if [ ! -f "$MODS_FILE" ]; then
    echo "ERROR: Missing mods file: $MODS_FILE"
    exit 1
fi

mkdir -p "$SERVER_MODS_DIR"

MOD_IDS=()

while IFS= read -r LINE; do
    MOD_ID="$(echo "$LINE" | tr -d '[:space:]')"

    [[ -z "$MOD_ID" ]] && continue
    [[ "$MOD_ID" =~ ^# ]] && continue

    MOD_IDS+=("$MOD_ID")

    DEST="$SERVER_MODS_DIR/workshop-$MOD_ID"

    if [ -f "$DEST/modinfo.lua" ]; then
        echo "Skip workshop-$MOD_ID: already installed."
        continue
    fi

    echo "Downloading workshop-$MOD_ID..."

    steamcmd +login anonymous \
        +workshop_download_item "$WORKSHOP_APP_ID" "$MOD_ID" validate \
        +quit

    SRC="$WORKSHOP_DIR/$MOD_ID"

    if [ ! -f "$SRC/modinfo.lua" ]; then
        echo "ERROR: workshop-$MOD_ID missing modinfo.lua"
        exit 1
    fi

    mkdir -p "$DEST"
    cp -a "$SRC/." "$DEST/"

    echo "Installed workshop-$MOD_ID"

done < "$MODS_FILE"

echo "Generating modoverrides.lua..."

generate_modoverrides() {
    local OUTPUT_FILE="$1"

    mkdir -p "$(dirname "$OUTPUT_FILE")"

    {
        echo "return {"

        for MOD_ID in "${MOD_IDS[@]}"; do
            echo "    [\"workshop-$MOD_ID\"] = {"
            echo "        enabled = true,"
            echo "        configuration_options = {}"
            echo "    },"
            echo
        done

        echo "}"
    } > "$OUTPUT_FILE"
}

generate_modoverrides "$MASTER_MODOVERRIDES"
generate_modoverrides "$CAVES_MODOVERRIDES"

echo "Mods installation completed."
echo "Generated:"
echo "$MASTER_MODOVERRIDES"
echo "$CAVES_MODOVERRIDES"