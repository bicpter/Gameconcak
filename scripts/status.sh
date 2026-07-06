#!/bin/bash
set -e

############################################
# GAMECONCAK Status
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "===================================="
echo " GAMECONCAK Status"
echo "===================================="

docker compose \
    --env-file "$PROJECT_DIR/.env" \
    -f "$PROJECT_DIR/docker/docker-compose.yml" \
    ps