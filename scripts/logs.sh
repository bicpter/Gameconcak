#!/bin/bash
set -e

############################################
# GAMECONCAK Logs
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

docker compose \
    --env-file "$PROJECT_DIR/.env" \
    -f "$PROJECT_DIR/docker/docker-compose.yml" \
    logs -f