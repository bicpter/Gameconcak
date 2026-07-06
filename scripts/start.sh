#!/bin/bash
set -e

############################################
# GAMECONCAK Start Server
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/.env"

echo "===================================="
echo " Starting GAMECONCAK"
echo "===================================="

if [ "${ENABLE_CAVES:-true}" = "true" ]; then
    docker compose \
        --env-file "$PROJECT_DIR/.env" \
        -f "$PROJECT_DIR/docker/docker-compose.yml" \
        up -d
else
    docker compose \
        --env-file "$PROJECT_DIR/.env" \
        -f "$PROJECT_DIR/docker/docker-compose.yml" \
        up -d dst-master
fi

echo
echo "===================================="
echo " Server Started"
echo "===================================="

docker compose \
    --env-file "$PROJECT_DIR/.env" \
    -f "$PROJECT_DIR/docker/docker-compose.yml" \
    ps