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

docker compose \
    --env-file "$PROJECT_DIR/.env" \
    -f "$PROJECT_DIR/docker/docker-compose.yml" \
    up -d

echo
echo "===================================="
echo " Server Started"
echo "===================================="

docker compose \
    --env-file "$PROJECT_DIR/.env" \
    -f "$PROJECT_DIR/docker/docker-compose.yml" \
    ps