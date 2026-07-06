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
echo "Cleaning old backups (keep latest 5)..."

find "$BACKUP_DIR" \
    -maxdepth 1 \
    -type f \
    -name "dst-backup-*.tar.gz" \
    | sort -r \
    | tail -n +6 \
    | xargs -r rm -f

echo
echo "===================================="
echo " Backup Completed"
echo "===================================="
echo
echo "Backup file:"
echo "  $BACKUP_FILE"
echo
echo "Size:"
du -sh "$BACKUP_FILE"

echo
echo "Current backups:"
ls -lh "$BACKUP_DIR"/dst-backup-*.tar.gz