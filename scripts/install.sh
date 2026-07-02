#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/.env"

echo "===================================="
echo " GAMECONCAK Host Installer"
echo "===================================="

echo "[1/4] Updating apt..."
sudo apt update

echo "[2/4] Installing host dependencies..."
sudo apt install -y \
curl \
wget \
git \
unzip \
tar \
ca-certificates \
gnupg \
lsb-release

echo "[3/4] Installing Docker if missing..."
if command -v docker >/dev/null 2>&1; then
    echo "Docker already installed."
else
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker "$USER"
fi

echo "[4/4] Creating project folders..."
mkdir -p "$PROJECT_DIR/data/cluster"
mkdir -p "$PROJECT_DIR/data/server"
mkdir -p "$PROJECT_DIR/data/logs"
mkdir -p "$PROJECT_DIR/backups"
mkdir -p "$PROJECT_DIR/secrets"
mkdir -p "$PROJECT_DIR/mods"

find "$PROJECT_DIR/scripts" -type f -name "*.sh" -exec chmod +x {} \;
find "$PROJECT_DIR/docker" -type f -name "*.sh" -exec chmod +x {} \;

echo
echo "Installation completed."
docker --version || true

echo
echo "If Docker was just installed, logout/login once before running Docker commands."