#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/.env"

BACKUP_FILE="$1"
DATA_DIR="$PROJECT_DIR/data"

echo "===================================="
echo " GAMECONCAK Restore"
echo "===================================="

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: ./scripts/restore.sh backups/dst-backup-xxxx.tar.gz"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "Stopping server..."
cd "$PROJECT_DIR/docker"
docker compose down || true

echo "Restoring backup..."
mkdir -p "$DATA_DIR"

tar -xzf "$BACKUP_FILE" -C "$DATA_DIR"

echo "Restore completed."
echo "Start server with:"
echo "./scripts/start.sh"