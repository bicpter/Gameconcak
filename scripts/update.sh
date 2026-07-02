#!/bin/bash
set -e

############################################
# GAMECONCAK Update DST
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/.env"

IMAGE_NAME="gameconcak-dst"

SERVER_DIR="$PROJECT_DIR/data/server"

mkdir -p "$SERVER_DIR"

echo "===================================="
echo " Updating DST Dedicated Server"
echo "===================================="

if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo
    echo "ERROR: Docker image not found."
    echo
    echo "Run:"
    echo
    echo "./scripts/build.sh"
    echo
    exit 1
fi

docker run --rm \
    -v "$SERVER_DIR:/data/server" \
    "$IMAGE_NAME" \
    steamcmd \
        +force_install_dir /data/server \
        +login anonymous \
        +app_update "$APP_ID" validate \
        +quit

if [ ! -f "$SERVER_DIR/bin64/dontstarve_dedicated_server_nullrenderer_x64" ]; then
    echo
    echo "ERROR: DST installation failed."
    exit 1
fi

echo
echo "DST updated successfully."