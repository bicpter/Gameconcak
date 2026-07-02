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

cd "$PROJECT_DIR/docker"

docker compose up -d

echo
echo "===================================="
echo " Server Started"
echo "===================================="

docker compose ps