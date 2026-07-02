#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "===================================="
echo " GAMECONCAK Bootstrap"
echo "===================================="

echo "[1/5] Installing host dependencies..."
bash "$PROJECT_DIR/scripts/install.sh"

echo "[2/5] Updating DST server..."
"$PROJECT_DIR/scripts/update.sh"

echo "[3/5] Installing mods..."
"$PROJECT_DIR/scripts/install-mods.sh"

echo "[4/5] Running health check..."
"$PROJECT_DIR/scripts/check.sh"

echo "[5/5] Starting server..."
"$PROJECT_DIR/scripts/start.sh"

echo
echo "===================================="
echo " Bootstrap completed"
echo "===================================="

"$PROJECT_DIR/scripts/status.sh"