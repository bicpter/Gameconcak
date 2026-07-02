#!/bin/bash
set -e

############################################
# GAMECONCAK Bootstrap
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

TOKEN_FILE="$PROJECT_DIR/secrets/cluster_token.txt"
TOKEN_EXAMPLE="$PROJECT_DIR/secrets/cluster_token.txt.example"

echo "===================================="
echo " GAMECONCAK Bootstrap"
echo "===================================="

############################################
# Check Cluster Token
############################################

if [ ! -f "$TOKEN_FILE" ]; then

    echo
    echo "ERROR: Missing cluster token!"
    echo
    echo "Please run:"
    echo
    echo "cp \"$TOKEN_EXAMPLE\" \"$TOKEN_FILE\""
    echo
    echo "Then edit:"
    echo
    echo "nano \"$TOKEN_FILE\""
    echo
    echo "Paste your Klei Cluster Token and run bootstrap again."
    exit 1

fi

############################################
# Install Host
############################################

echo
echo "[1/6] Installing host dependencies..."
"$PROJECT_DIR/scripts/install.sh"

############################################
# Build Docker Image
############################################

echo
echo "[2/6] Building Docker image..."
"$PROJECT_DIR/scripts/build.sh"

############################################
# Update DST
############################################

echo
echo "[3/6] Updating DST Dedicated Server..."
"$PROJECT_DIR/scripts/update.sh"

############################################
# Install Mods
############################################

echo
echo "[4/6] Installing Mods..."
"$PROJECT_DIR/scripts/install-mods.sh"

############################################
# Start Server
############################################

echo
echo "[5/6] Starting Server..."
"$PROJECT_DIR/scripts/start.sh"

############################################
# Health Check
############################################

echo
echo "[6/6] Running Health Check..."

if "$PROJECT_DIR/scripts/check.sh"; then

    echo
    echo "===================================="
    echo " Bootstrap Completed Successfully!"
    echo "===================================="
    echo

    "$PROJECT_DIR/scripts/status.sh"

else

    echo
    echo "===================================="
    echo " Bootstrap Failed!"
    echo "===================================="
    echo
    echo "Check server logs with:"
    echo
    echo "./scripts/logs.sh"
    exit 1

fi