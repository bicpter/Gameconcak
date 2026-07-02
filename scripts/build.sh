#!/bin/bash
set -e

############################################
# GAMECONCAK Docker Build
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/.env"

echo "===================================="
echo " Building Docker Image"
echo "===================================="

if [ -z "$IMAGE_NAME" ]; then
    echo "ERROR: IMAGE_NAME is not set in .env"
    exit 1
fi

docker build \
    -t "$IMAGE_NAME" \
    -f "$PROJECT_DIR/docker/Dockerfile" \
    "$PROJECT_DIR"

echo
echo "===================================="
echo " Docker Image Built Successfully"
echo "===================================="

echo
docker image ls "$IMAGE_NAME"