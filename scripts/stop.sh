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

cd "$PROJECT_DIR/docker"

docker compose down

echo
echo "===================================="
echo " Server Stopped"
echo "===================================="