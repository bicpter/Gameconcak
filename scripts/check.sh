#!/bin/bash
set -e

############################################
# GAMECONCAK Health Check
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/.env"

SERVER_DIR="$PROJECT_DIR/data/server"
CLUSTER_RUNTIME_DIR="$PROJECT_DIR/data/cluster/DoNotStarveTogether/$CLUSTER_NAME"
CONFIG_DIR="$PROJECT_DIR/config/cluster"
MODS_FILE="$PROJECT_DIR/mods/mods.txt"
TOKEN_FILE="$PROJECT_DIR/secrets/cluster_token.txt"
COMPOSE_FILE="$PROJECT_DIR/docker/docker-compose.yml"

PASS=0
WARN=0
FAIL=0

ok() {
    echo "[ OK ] $1"
    PASS=$((PASS + 1))
}

warn() {
    echo "[WARN] $1"
    WARN=$((WARN + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL + 1))
}

echo "===================================="
echo " GAMECONCAK Health Check"
echo "===================================="

############################################
# Docker
############################################

if command -v docker >/dev/null 2>&1; then
    ok "Docker installed"
else
    fail "Docker not installed"
fi

if docker compose version >/dev/null 2>&1; then
    ok "Docker Compose installed"
else
    fail "Docker Compose not found"
fi

############################################
# Project Files
############################################

[ -f "$PROJECT_DIR/.env" ] && ok ".env" || fail ".env missing"

[ -f "$COMPOSE_FILE" ] && ok "docker-compose.yml" || fail "docker-compose.yml missing"

[ -f "$PROJECT_DIR/docker/Dockerfile" ] && ok "Dockerfile" || fail "Dockerfile missing"

############################################
# Config
############################################

FILES=(
    "$CONFIG_DIR/cluster.ini"
    "$CONFIG_DIR/Master/server.ini"
    "$CONFIG_DIR/Master/worldgenoverride.lua"
    "$CONFIG_DIR/Master/modoverrides.lua"
    "$CONFIG_DIR/Caves/server.ini"
    "$CONFIG_DIR/Caves/worldgenoverride.lua"
    "$CONFIG_DIR/Caves/modoverrides.lua"
)

for FILE in "${FILES[@]}"
do
    if [ -f "$FILE" ]; then
        ok "$FILE"
    else
        fail "$FILE"
    fi
done

############################################
# Token
############################################

if [ ! -f "$TOKEN_FILE" ]; then

    fail "cluster_token.txt missing"

else

    TOKEN="$(tr -d '[:space:]' < "$TOKEN_FILE")"

    if [ -z "$TOKEN" ]; then

        fail "cluster_token.txt is empty"

    elif [[ "$TOKEN" == "PUT_YOUR_KLEI_CLUSTER_TOKEN_HERE" ]]; then

        fail "cluster_token.txt contains example value"

    else

        ok "cluster_token.txt"

    fi

fi

############################################
# DST Server
############################################

if [ -f "$SERVER_DIR/bin64/dontstarve_dedicated_server_nullrenderer_x64" ]; then
    ok "DST Dedicated Server"
else
    warn "DST Dedicated Server not installed"
fi

############################################
# Mods
############################################

if [ -f "$MODS_FILE" ]; then

    ok "mods.txt"

    while IFS= read -r LINE
    do

        MOD_ID="$(echo "$LINE" | tr -d '[:space:]')"

        [[ -z "$MOD_ID" ]] && continue
        [[ "$MOD_ID" =~ ^# ]] && continue

        ok "workshop-$MOD_ID"

    done < "$MODS_FILE"

else

    fail "mods.txt missing"

fi

############################################
# Runtime
############################################

if [ -d "$CLUSTER_RUNTIME_DIR" ]; then
    ok "Cluster Runtime"
else
    warn "Cluster Runtime not created"
fi

############################################
# Containers
############################################

if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_MASTER"; then
    ok "$CONTAINER_MASTER running"
else
    warn "$CONTAINER_MASTER stopped"
fi

if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_CAVES"; then
    ok "$CONTAINER_CAVES running"
else
    warn "$CONTAINER_CAVES stopped"
fi

############################################
# Summary
############################################

echo
echo "===================================="
echo " Summary"
echo "===================================="

echo "PASS : $PASS"
echo "WARN : $WARN"
echo "FAIL : $FAIL"

echo

if [ "$FAIL" -gt 0 ]; then
    echo "Health Check FAILED."
    exit 1
fi

echo "Health Check PASSED."