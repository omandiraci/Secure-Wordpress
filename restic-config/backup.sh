#!/bin/bash

# Restic Backup Script
set -e

echo "Starting backup process..."

# Initialize repository if it doesn't exist
if ! restic snapshots >/dev/null 2>&1; then
    echo "Initializing restic repository..."
    restic init
fi

# Backup WordPress files
echo "Backing up WordPress files..."
restic backup /wordpress --tag wordpress

# Backup MySQL database
echo "Backing up MySQL database..."
restic backup /mysql --tag mysql

# Cleanup old backups (keep last 7 days)
echo "Cleaning up old backups..."
restic forget --keep-daily 15 --prune

echo "Backup completed successfully!"
