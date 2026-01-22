#!/bin/bash

LOG_FILE="/var/log/syslog" # you will install rsyslog
REPORT_FILE="/var/log/ssh_failed_report_$(date +%F).txt"
THRESHOLD=3

if [ ! -f "$LOG_FILE" ]; then
    echo "Log file not found: $LOG_FILE"
    exit 1
fi

if [ ! -f "$REPORT_FILE" ]; then
    touch "$REPORT_FILE"
fi

echo "Failed SSH Login Report - $(date)" > "$REPORT_FILE"
echo "---------------------------------" >> "$REPORT_FILE"
echo "Attempts | IP Address" >> "$REPORT_FILE"
echo "---------------------------------" >> "$REPORT_FILE"

grep "Failed password" "$LOG_FILE" \
| awk '{print $(NF-3)}' \
| sort \
| uniq -c \
| awk -v threshold="$THRESHOLD" '$1 >= threshold {print $1 "        | " $2}' \
>> "$REPORT_FILE"

echo "Report generated: $REPORT_FILE"
