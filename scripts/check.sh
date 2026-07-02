#!/bin/bash
set -e

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

# Docker
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

# Required files
[ -f "$PROJECT_DIR/.env" ] && ok ".env exists" || fail ".env missing"
[ -f "$COMPOSE_FILE" ] && ok "docker-compose.yml exists" || fail "docker-compose.yml missing"
[ -f "$PROJECT_DIR/docker/Dockerfile" ] && ok "Dockerfile exists" || fail "Dockerfile missing"

# Config files
[ -f "$CONFIG_DIR/cluster.ini" ] && ok "cluster.ini exists" || fail "cluster.ini missing"
[ -f "$CONFIG_DIR/Master/server.ini" ] && ok "Master/server.ini exists" || fail "Master/server.ini missing"
[ -f "$CONFIG_DIR/Caves/server.ini" ] && ok "Caves/server.ini exists" || fail "Caves/server.ini missing"
[ -f "$CONFIG_DIR/Master/worldgenoverride.lua" ] && ok "Master/worldgenoverride.lua exists" || fail "Master/worldgenoverride.lua missing"
[ -f "$CONFIG_DIR/Caves/worldgenoverride.lua" ] && ok "Caves/worldgenoverride.lua exists" || fail "Caves/worldgenoverride.lua missing"

# Token
if [ -f "$TOKEN_FILE" ]; then
    if grep -q "PUT_YOUR" "$TOKEN_FILE"; then
        fail "cluster_token.txt still contains placeholder"
    else
        ok "cluster_token.txt exists"
    fi
else
    fail "cluster_token.txt missing"
fi

# DST server binary
if [ -f "$SERVER_DIR/bin64/dontstarve_dedicated_server_nullrenderer_x64" ]; then
    ok "DST server binary exists"
else
    warn "DST server not installed yet. Run ./scripts/update.sh"
fi

# Mods
if [ -f "$MODS_FILE" ]; then
    ok "mods.txt exists"

    while IFS= read -r LINE; do
        MOD_ID="$(echo "$LINE" | tr -d '[:space:]')"

        [[ -z "$MOD_ID" ]] && continue
        [[ "$MOD_ID" =~ ^# ]] && continue

        if [ -f "$SERVER_DIR/mods/workshop-$MOD_ID/modinfo.lua" ]; then
            ok "Mod workshop-$MOD_ID installed"
        else
            warn "Mod workshop-$MOD_ID not installed"
        fi
    done < "$MODS_FILE"
else
    warn "mods.txt missing"
fi

# Runtime cluster
if [ -d "$CLUSTER_RUNTIME_DIR" ]; then
    ok "Runtime cluster exists"
else
    warn "Runtime cluster not created yet"
fi

# Docker containers
if command -v docker >/dev/null 2>&1; then
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_MASTER}$"; then
        ok "$CONTAINER_MASTER running"
    else
        warn "$CONTAINER_MASTER not running"
    fi

    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_CAVES}$"; then
        ok "$CONTAINER_CAVES running"
    else
        warn "$CONTAINER_CAVES not running"
    fi
fi

echo
echo "===================================="
echo " Summary"
echo "===================================="
echo "OK:   $PASS"
echo "WARN: $WARN"
echo "FAIL: $FAIL"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi