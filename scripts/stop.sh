#!/bin/bash
set -e

############################################
# GAMECONCAK Stop Server
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/.env"

echo "===================================="
echo " Stopping GAMECONCAK"
echo "===================================="

docker compose \
    --env-file "$PROJECT_DIR/.env" \
    -f "$PROJECT_DIR/docker/docker-compose.yml" \
    down

echo
echo "===================================="
echo " Server Stopped"
echo "===================================="