#!/bin/bash
set -e

############################################
# GAMECONCAK Bootstrap
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

TOKEN_FILE="$PROJECT_DIR/secrets/cluster_token.txt"

echo "===================================="
echo " GAMECONCAK Bootstrap"
echo "===================================="

############################################
# Prepare Token
############################################

mkdir -p "$PROJECT_DIR/secrets"

if [ ! -f "$TOKEN_FILE" ]; then
    echo
    echo "Cluster token not found."
    echo "Paste your Klei Cluster Token below:"
    echo

    while true
    do
        read -r -p "Cluster Token: " TOKEN

        TOKEN="$(echo "$TOKEN" | tr -d '[:space:]')"

        if [ -n "$TOKEN" ]; then
            echo "$TOKEN" > "$TOKEN_FILE"
            chmod 600 "$TOKEN_FILE"
            echo
            echo "Token saved to secrets/cluster_token.txt"
            break
        fi

        echo "Token cannot be empty. Try again."
    done
else
    TOKEN="$(tr -d '[:space:]' < "$TOKEN_FILE")"

    if [ -z "$TOKEN" ] || [ "$TOKEN" = "PUT_YOUR_KLEI_CLUSTER_TOKEN_HERE" ]; then
        echo
        echo "Invalid or placeholder token found."
        echo "Paste your Klei Cluster Token below:"
        echo

        while true
        do
            read -r -p "Cluster Token: " TOKEN

            TOKEN="$(echo "$TOKEN" | tr -d '[:space:]')"

            if [ -n "$TOKEN" ] && [ "$TOKEN" != "PUT_YOUR_KLEI_CLUSTER_TOKEN_HERE" ]; then
                echo "$TOKEN" > "$TOKEN_FILE"
                chmod 600 "$TOKEN_FILE"
                echo
                echo "Token updated."
                break
            fi

            echo "Token cannot be empty or placeholder. Try again."
        done
    else
        echo "Cluster token found."
    fi
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