#!/bin/bash
set -e

############################################
# GAMECONCAK Backup Script
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/.env"

CLUSTER_DIR="$PROJECT_DIR/data/cluster"
BACKUP_DIR="$PROJECT_DIR/backups"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/dst-backup-$TIMESTAMP.tar.gz"

echo "===================================="
echo " GAMECONCAK Backup"
echo "===================================="

mkdir -p "$BACKUP_DIR"

if [ ! -d "$CLUSTER_DIR" ]; then
    echo "ERROR: Cluster directory not found."
    exit 1
fi

echo "Creating backup..."

tar -czf "$BACKUP_FILE" -C "$PROJECT_DIR/data" cluster

echo
echo "Backup completed!"
echo
echo "$BACKUP_FILE"

ls -lh "$BACKUP_FILE"