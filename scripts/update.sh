#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/.env"

APP_ID="${APP_ID:-343050}"
SERVER_DIR="$PROJECT_DIR/data/server"
IMAGE_NAME="gameconcak-dst"

echo "===================================="
echo " GAMECONCAK DST Update"
echo "===================================="

mkdir -p "$SERVER_DIR"

echo "[1/3] Building Docker image..."
docker build \
  -t "$IMAGE_NAME" \
  -f "$PROJECT_DIR/docker/Dockerfile" \
  "$PROJECT_DIR"

echo "[2/3] Updating DST server..."
docker run --rm \
  -v "$SERVER_DIR:/data/server" \
  "$IMAGE_NAME" \
  steamcmd \
    +force_install_dir /data/server \
    +login anonymous \
    +app_update "$APP_ID" validate \
    +quit

echo "[3/3] Checking binary..."
if [ ! -f "$SERVER_DIR/bin64/dontstarve_dedicated_server_nullrenderer_x64" ]; then
    echo "ERROR: DST binary not found."
    exit 1
fi

echo "DST Dedicated Server updated successfully."