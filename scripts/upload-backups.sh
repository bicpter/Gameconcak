#!/bin/bash
set -e

############################################
# GAMECONCAK Upload Backups Script
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

source "$PROJECT_DIR/.env"

BACKUP_DIR="$PROJECT_DIR/backups"

RCLONE_REMOTE="gdrive"
DRIVE_DIR="GAMECONCAK Backups"

echo "===================================="
echo " GAMECONCAK Upload Backups"
echo "===================================="

if ! command -v rclone >/dev/null 2>&1; then
    echo "ERROR: rclone not installed."
    echo
    echo "Install with:"
    echo "curl https://rclone.org/install.sh | bash"
    exit 1
fi

if ! rclone listremotes | grep -qx "${RCLONE_REMOTE}:"; then
    echo "ERROR: rclone remote '${RCLONE_REMOTE}' not found."
    echo
    echo "Run first:"
    echo "rclone config"
    echo
    echo "Create a Google Drive remote named:"
    echo "$RCLONE_REMOTE"
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    echo "ERROR: Backup directory not found:"
    echo "$BACKUP_DIR"
    exit 1
fi

if ! ls "$BACKUP_DIR"/dst-backup-*.tar.gz >/dev/null 2>&1; then
    echo "ERROR: No backup files found."
    echo
    echo "Run first:"
    echo "./scripts/backup.sh"
    exit 1
fi

echo
echo "Creating Google Drive folder if missing..."

rclone mkdir "${RCLONE_REMOTE}:${DRIVE_DIR}"

echo
echo "Uploading backups..."

rclone copy "$BACKUP_DIR" "${RCLONE_REMOTE}:${DRIVE_DIR}" \
    --include "dst-backup-*.tar.gz" \
    --progress

echo
echo "===================================="
echo " Upload Completed"
echo "===================================="
echo
echo "Remote:"
echo "${RCLONE_REMOTE}:${DRIVE_DIR}"
echo
echo "Files on Google Drive:"
rclone ls "${RCLONE_REMOTE}:${DRIVE_DIR}"