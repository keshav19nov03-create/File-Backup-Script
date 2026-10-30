#!/bin/bash
# backup.sh - Automated file backup script
# Author: Keshav Kumar (UID: 26MCC20092)

SOURCE_DIR="$HOME/BackupProject/source_data"
BACKUP_DIR="$HOME/BackupProject/backups"
MIRROR_DIR="$HOME/BackupProject/mirror"
LOG_FILE="$HOME/BackupProject/logs/backup.log"
RETENTION_DAYS=7
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"
PARENT_DIR=$(dirname "$SOURCE_DIR")
FOLDER_NAME=$(basename "$SOURCE_DIR")

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

# Create required directories
mkdir -p "$BACKUP_DIR" "$MIRROR_DIR" "$(dirname "$LOG_FILE")"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    log "ERROR: Source directory $SOURCE_DIR not found."
    exit 1
fi

log "Backup started for $SOURCE_DIR"

# Step 1: Mirror copy using rsync (fallback to cp)
if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$SOURCE_DIR/" "$MIRROR_DIR/"
    log "rsync mirror completed."
else
    cp -a "$SOURCE_DIR/." "$MIRROR_DIR/"
    log "rsync not found; used cp for mirror copy."
fi

# Step 2: Compressed timestamped archive using tar & gzip
if tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$PARENT_DIR" "$FOLDER_NAME"; then
    SIZE=$(du -h "$BACKUP_DIR/$ARCHIVE_NAME" | cut -f1)
    log "SUCCESS: $ARCHIVE_NAME created ($SIZE)."
else
    log "ERROR: tar failed. Backup not created."
    exit 2
fi

# Step 3: Verify archive integrity
if tar -tzf "$BACKUP_DIR/$ARCHIVE_NAME" >/dev/null 2>&1; then
    log "Archive verification passed."
else
    log "ERROR: Archive verification failed."
    exit 3
fi

# Step 4: Delete old backups (retention policy)
find "$BACKUP_DIR" -name "backup_*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete
log "Old backups (older than $RETENTION_DAYS days) cleaned."

log "Backup finished."
