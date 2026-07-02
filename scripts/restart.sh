#!/bin/bash
set -e

############################################
# GAMECONCAK Restart Server
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "===================================="
echo " Restarting GAMECONCAK"
echo "===================================="

"$PROJECT_DIR/scripts/stop.sh"
"$PROJECT_DIR/scripts/start.sh"

echo
echo "===================================="
echo " Restart Completed"
echo "===================================="