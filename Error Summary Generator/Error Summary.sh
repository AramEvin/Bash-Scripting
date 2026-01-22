#!/bin/bash

LOG_DIR="/var/log"
REPORT_FILE="/var/log/error_summary_$(date +%F).txt"

if [ ! -d "$LOG_DIR" ]; then
    echo "Log directory not found: $LOG_DIR"
    exit 1
fi

if [ ! -f "$REPORT_FILE" ]; then
    touch "$REPORT_FILE"
fi

echo "Daily Error Summary - $(date)" > "$REPORT_FILE"
echo "--------------------------------" >> "$REPORT_FILE"

find "$LOG_DIR" -type f -name "*.log" | while read LOG_FILE
do
    if [ -f "$LOG_FILE" ]; then
        grep -i "error" "$LOG_FILE" | awk -v file="$LOG_FILE" '{print file " | " $NF}'
    fi
done \
| sort \
| uniq -c \
| sort -nr >> "$REPORT_FILE"

echo "Error summary generated: $REPORT_FILE"
