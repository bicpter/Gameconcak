#!/bin/bash
set -e

############################################
# GAMECONCAK Restore Script
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/.env"

BACKUP_FILE="$1"
DATA_DIR="$PROJECT_DIR/data"
CLUSTER_DIR="$DATA_DIR/cluster"

echo "===================================="
echo " GAMECONCAK Restore"
echo "===================================="

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage:"
    echo "./scripts/restore.sh backups/dst-backup-xxxx.tar.gz"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found:"
    echo "$BACKUP_FILE"
    exit 1
fi

echo
echo "WARNING: This will overwrite current cluster/world data."
echo "Backup file:"
echo "$BACKUP_FILE"
echo
echo "Press ENTER to continue or Ctrl+C to cancel."
read

echo
echo "Stopping server..."

cd "$PROJECT_DIR/docker"
docker compose down || true

echo
echo "Removing current cluster..."

rm -rf "$CLUSTER_DIR"
mkdir -p "$DATA_DIR"

echo
echo "Restoring backup..."

tar -xzf "$BACKUP_FILE" -C "$DATA_DIR"

if [ ! -d "$CLUSTER_DIR" ]; then
    echo "ERROR: Restore failed. Cluster directory not found after extraction."
    exit 1
fi

echo
echo "Starting server..."

cd "$PROJECT_DIR/docker"
docker compose up -d

echo
echo "===================================="
echo " Restore Completed"
echo "===================================="
echo
echo "Restored from:"
echo "$BACKUP_FILE"