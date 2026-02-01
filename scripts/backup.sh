#!/bin/bash
set -e

# ==============================================================================
# Nextcloud Backup Script
# Strategy: 
# 1. Hot database dump to disk
# 2. Restic snapshot of Data, Config, and DB Dump to external storage
# ==============================================================================

# -- Configuration --
PROJECT_ROOT="/opt/nextcloud"
BACKUP_DIR="${PROJECT_ROOT}/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Container Names (Must match docker-compose.yml)
DB_CONTAINER="nextcloud_db"

# -- Pre-flight Checks --
if ! command -v docker &> /dev/null; then echo "Error: docker is not installed"; exit 1; fi
if ! command -v restic &> /dev/null; then echo "Error: restic is not installed"; exit 1; fi

mkdir -p "$BACKUP_DIR"

echo "[${TIMESTAMP}] Starting Backup..."

# 1. Database Dump
# We stream pg_dump from the container to the host filesystem
echo "--> Dumping Database..."
docker exec "$DB_CONTAINER" pg_dump -U nextcloud nextcloud > "${BACKUP_DIR}/db_${TIMESTAMP}.sql"
echo "    Database dump complete: ${BACKUP_DIR}/db_${TIMESTAMP}.sql"

# 2. Restic Backup
# Assumes RESTIC_REPOSITORY and RESTIC_PASSWORD are set in the environment or .env
if [ -z "$RESTIC_REPOSITORY" ]; then
    echo "!! RESTIC_REPOSITORY is not set. Skipping offsite upload."
    echo "!! Local DB dump is preserved."
else
    echo "--> Running Restic Snapshot..."
    # Back up the entire project folder (Data + Config + DB Dumps)
    # Exclude the backups folder itself from recursion if it's inside the root (circular)
    # Ideally backup_dir is outside, but here we handle it.
    
    restic backup "$PROJECT_ROOT" \
        --exclude "${PROJECT_ROOT}/caddy/data" \
        --tag "nextcloud-cron"
        
    echo "--> Pruning Old Snapshots..."
    restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
fi

echo "[${TIMESTAMP}] Backup Success."
