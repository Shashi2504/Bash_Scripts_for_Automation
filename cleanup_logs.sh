#!/bin/bash

MAX_AGE=30	# Setting the max age of log files to 30 days


LOG_DIR="/var/log"	# Provided the path where the log files will be present

echo "Cleaning Up Log file older that  $MAX_AGE days in $LOG_DIR"


find "$LOG_DIR" -type f -name "*.log" -mtime +$MAX_AGE -delete	# This line finds and deletes the old log files

find "$LOG_DIR" -type f -name "*.log" -mtime +7 -exe gzip {} \;	# This line which gonna compress the log files older than 7 days

echo "Log CleanUp Completed"

