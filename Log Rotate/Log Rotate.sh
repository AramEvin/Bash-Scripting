#!/bin/bash

set -Eeuo pipefail

LOG_DIR="/var/log/log_rotate"
COMPRESS_DAYS=5
DELETE_DAYS=15

if [ ! -d "$LOG_DIR" ]; then
    echo "Log directory not found: $LOG_DIR"
    exit 1
fi

echo "Compressing logs older than $COMPRESS_DAYS days..."

find "$LOG_DIR" -type f -name "*.log" -mtime +$COMPRESS_DAYS | while read file
do
    echo "Compressing $file"
    gzip "$file"
done

echo "Deleting logs older than $DELETE_DAYS days..."

find "$LOG_DIR" -type f -name "*.gz" -mtime +$DELETE_DAYS | while read file
do
    echo "Deleting $file"
    rm "$file"
done

echo "Log rotation finished."
