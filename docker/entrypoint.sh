#!/bin/bash
set -e

echo "===================================="
echo " GAMECONCAK Docker Entrypoint"
echo "===================================="

: "${CLUSTER_NAME:=MyDediServer}"

SERVER_DIR="/data/server"
KLEI_ROOT="/root/.klei"
DST_ROOT="$KLEI_ROOT/DoNotStarveTogether"
DATA_DST_ROOT="/data/cluster/DoNotStarveTogether"
CLUSTER_DIR="$DATA_DST_ROOT/$CLUSTER_NAME"
CONFIG_DIR="/config/cluster"
SECRET_TOKEN="/secrets/cluster_token.txt"

echo "[1/5] Checking folders..."

mkdir -p "$SERVER_DIR"
mkdir -p "$DATA_DST_ROOT"
mkdir -p "/data/logs"
mkdir -p "$KLEI_ROOT"

rm -rf "$DST_ROOT"
ln -s "$DATA_DST_ROOT" "$DST_ROOT"

echo "[2/5] Checking DST server files..."

if [ ! -f "$SERVER_DIR/bin64/dontstarve_dedicated_server_nullrenderer_x64" ]; then
    echo "ERROR: DST server is not installed."
    echo "Run: ./scripts/update.sh"
    exit 1
fi

echo "[3/5] Syncing config..."

mkdir -p "$CLUSTER_DIR"
mkdir -p "$CLUSTER_DIR/Master"
mkdir -p "$CLUSTER_DIR/Caves"

cp -f "$CONFIG_DIR/cluster.ini" "$CLUSTER_DIR/cluster.ini"

cp -f "$CONFIG_DIR/Master/server.ini" "$CLUSTER_DIR/Master/server.ini"
cp -f "$CONFIG_DIR/Master/worldgenoverride.lua" "$CLUSTER_DIR/Master/worldgenoverride.lua"
cp -f "$CONFIG_DIR/Master/modoverrides.lua" "$CLUSTER_DIR/Master/modoverrides.lua"

cp -f "$CONFIG_DIR/Caves/server.ini" "$CLUSTER_DIR/Caves/server.ini"
cp -f "$CONFIG_DIR/Caves/worldgenoverride.lua" "$CLUSTER_DIR/Caves/worldgenoverride.lua"
cp -f "$CONFIG_DIR/Caves/modoverrides.lua" "$CLUSTER_DIR/Caves/modoverrides.lua"

echo "[4/5] Checking token..."

if [ ! -f "$SECRET_TOKEN" ]; then
    echo "ERROR: Missing cluster token."
    echo "Put token at: secrets/cluster_token.txt"
    exit 1
fi

cp -f "$SECRET_TOKEN" "$CLUSTER_DIR/cluster_token.txt"
chmod 600 "$CLUSTER_DIR/cluster_token.txt"

echo "[5/5] Starting server..."

cd "$SERVER_DIR/bin64"

exec "$@"