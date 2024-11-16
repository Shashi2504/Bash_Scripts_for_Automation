#!/bin/bash

SOURCE_DIR = "/home/user/important_data"
BACKUP_DIR = "/mnt/backup"

TIMESTAMP = $(date +"%Y%m%d_%H%M%S")

BACKUP_FILE = "backup_$TIMESTAMP.tar.gz"

echo "Starting backup of $SOURCE_DIR to $BACKUP_DIR/$BACKUP_FILE"

tar -czf "$BACKUP_DIR/$BACKUP_FILE" "$SOURCE_DIR"

if [$? -eq 0]; then
	echo "BackUp Completed Successfully"
else
	echo "BackUp failed"
fi
