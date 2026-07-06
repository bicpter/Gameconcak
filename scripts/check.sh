#!/bin/bash
set -e

############################################
# GAMECONCAK Health Check
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/.env"

SERVER_DIR="$PROJECT_DIR/data/server"
CLUSTER_ROOT="$PROJECT_DIR/data/cluster/DoNotStarveTogether"
CLUSTER_RUNTIME_DIR="$CLUSTER_ROOT/$CLUSTER_NAME"
CONFIG_DIR="$PROJECT_DIR/config/cluster"
MODS_FILE="$PROJECT_DIR/mods/mods.txt"
TOKEN_FILE="$PROJECT_DIR/secrets/cluster_token.txt"
RUNTIME_TOKEN_FILE="$CLUSTER_RUNTIME_DIR/cluster_token.txt"
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
# Docker Image
############################################

if [ -n "${IMAGE_NAME:-}" ] && docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    ok "Docker image: $IMAGE_NAME"
else
    warn "Docker image missing. Run ./scripts/build.sh"
fi

############################################
# Docker Compose Config
############################################

if docker compose --env-file "$PROJECT_DIR/.env" -f "$COMPOSE_FILE" config >/dev/null 2>&1; then
    ok "Docker Compose config valid"
else
    fail "Docker Compose config invalid"
fi

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
        fail "$FILE missing"
    fi
done

############################################
# Cluster Config Values
############################################

if [ -f "$CONFIG_DIR/cluster.ini" ]; then
    if grep -q "^offline_cluster *= *false" "$CONFIG_DIR/cluster.ini"; then
        ok "offline_cluster=false"
    else
        fail "offline_cluster is not false"
    fi

    if grep -q "^lan_only_cluster *= *false" "$CONFIG_DIR/cluster.ini"; then
        ok "lan_only_cluster=false"
    else
        fail "lan_only_cluster is not false"
    fi

    if grep -q "^cluster_name *= *" "$CONFIG_DIR/cluster.ini"; then
        ok "cluster_name configured"
    else
        fail "cluster_name missing"
    fi
fi

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

        MOD_PATH="$SERVER_DIR/mods/workshop-$MOD_ID"

        if [ -f "$MOD_PATH/modinfo.lua" ]; then
            ok "workshop-$MOD_ID installed"
        else
            warn "workshop-$MOD_ID not installed locally"
        fi

    done < "$MODS_FILE"
else
    fail "mods.txt missing"
fi

############################################
# Runtime
############################################

if [ -d "$CLUSTER_RUNTIME_DIR" ]; then
    ok "Cluster Runtime: $CLUSTER_NAME"
else
    warn "Cluster Runtime not created"
fi

if [ -d "$CLUSTER_ROOT/Cluster_1" ]; then
    warn "Unexpected runtime cluster exists: Cluster_1"
fi

if [ -f "$RUNTIME_TOKEN_FILE" ]; then
    ok "Runtime cluster_token.txt"
else
    warn "Runtime cluster_token.txt not found yet"
fi

############################################
# Containers
############################################

MASTER_RUNNING=false

if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_MASTER"; then
    ok "$CONTAINER_MASTER running"
    MASTER_RUNNING=true
else
    warn "$CONTAINER_MASTER stopped"
fi

if [ -n "${CONTAINER_CAVES:-}" ]; then
    if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_CAVES"; then
        ok "$CONTAINER_CAVES running"
    else
        warn "$CONTAINER_CAVES stopped"
    fi
fi

############################################
# UDP Ports
############################################

if ss -lunp | grep -q ":10999 "; then
    ok "UDP 10999 listening"
else
    warn "UDP 10999 not listening"
fi

if ss -lunp | grep -q ":27016 "; then
    ok "UDP 27016 listening"
else
    warn "UDP 27016 not listening"
fi

############################################
# Master Logs
############################################

if [ "$MASTER_RUNNING" = true ]; then
    MASTER_LOG="$(docker logs --tail 300 "$CONTAINER_MASTER" 2>&1 || true)"

    if echo "$MASTER_LOG" | grep -q "Token retrieved"; then
        ok "Master token retrieved"
    else
        warn "Master token retrieval not found in logs"
    fi

    if echo "$MASTER_LOG" | grep -q "Server registered via geo DNS"; then
        ok "Master registered via geo DNS"
    else
        warn "Master registration not found in logs"
    fi

    if echo "$MASTER_LOG" | grep -q "Sim paused"; then
        ok "Master sim paused"
    else
        warn "Master sim paused not found"
    fi

    if echo "$MASTER_LOG" | grep -Eqi "E_INVALID_TOKEN|No auth token|Account Failed"; then
        fail "Master log has token/account error"
    else
        ok "No token/account error in Master log"
    fi

    if echo "$MASTER_LOG" | grep -Eqi "Error during game initialization|Failed mSimulation|Error loading main.lua"; then
        fail "Master log has game initialization error"
    else
        ok "No game initialization error in Master log"
    fi
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