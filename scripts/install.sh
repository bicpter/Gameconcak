#!/bin/bash
set -e

############################################
# GAMECONCAK Host Installer
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/.env"

echo "===================================="
echo " GAMECONCAK Host Installer"
echo "===================================="

############################################
# Update apt
############################################

echo "[1/4] Updating apt..."
sudo apt update

############################################
# Install dependencies
############################################

echo "[2/4] Installing dependencies..."
sudo apt install -y \
curl \
wget \
git \
unzip \
tar \
ca-certificates \
gnupg \
lsb-release

############################################
# Install Docker
############################################

echo "[3/4] Checking Docker..."

if command -v docker >/dev/null 2>&1; then
    echo "Docker already installed."
else
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker "$USER"
fi

############################################
# Create folders
############################################

echo "[4/4] Creating project folders..."

mkdir -p "$PROJECT_DIR/data/cluster"
mkdir -p "$PROJECT_DIR/data/server"
mkdir -p "$PROJECT_DIR/data/logs"

mkdir -p "$PROJECT_DIR/backups"
mkdir -p "$PROJECT_DIR/mods"
mkdir -p "$PROJECT_DIR/secrets"

find "$PROJECT_DIR/scripts" -type f -name "*.sh" -exec chmod +x {} \;
find "$PROJECT_DIR/docker" -type f -name "*.sh" -exec chmod +x {} \;

echo
echo "===================================="
echo " Installation Completed"
echo "===================================="

docker --version || true

echo
echo "Host installation finished."