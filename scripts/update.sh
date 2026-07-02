#!/bin/bash
set -e

############################################
# GAMECONCAK Update DST
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/.env"

SERVER_DIR="$PROJECT_DIR/data/server"

mkdir -p "$SERVER_DIR"

echo "===================================="
echo " Updating DST Dedicated Server"
echo "===================================="

if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "ERROR: Docker image not found."
    echo "Run: ./scripts/build.sh"
    exit 1
fi

docker run --rm \
    --entrypoint /steamcmd/steamcmd.sh \
    -v "$SERVER_DIR:/data/server" \
    "$IMAGE_NAME" \
    +force_install_dir /data/server \
    +login anonymous \
    +app_update 343050 validate \
    +quit

if [ ! -f "$SERVER_DIR/bin64/dontstarve_dedicated_server_nullrenderer_x64" ]; then
    echo "ERROR: DST installation failed."
    exit 1
fi

echo
echo "DST updated successfully."