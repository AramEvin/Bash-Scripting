#!/bin/bash

REPORT_FILE="/var/log/filesystem_health_$(date +%F).txt"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

if [ ! -f "$REPORT_FILE" ]; then
    touch "$REPORT_FILE"
fi

echo "Filesystem Health Report - $DATE" > "$REPORT_FILE"
echo "---------------------------------" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Mounted Filesystems:" >> "$REPORT_FILE"
mount | awk '{print $1 " mounted on " $3}' >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "Read-Only Filesystems (CRITICAL):" >> "$REPORT_FILE"

mount | grep "(ro," > /tmp/ro_mounts.txt

if [ -s /tmp/ro_mounts.txt ]; then
    cat /tmp/ro_mounts.txt >> "$REPORT_FILE"
else
    echo "None detected" >> "$REPORT_FILE"
fi

rm -f /tmp/ro_mounts.txt

echo "" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "Report saved to $REPORT_FILE"
