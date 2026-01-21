#!/usr/bin/env bash

set -euo pipefail

THRESHOLD=80
LOG_FILE="/var/log/disk_usage_monitor.log"
DATE="$(date '+%Y-%m-%d %H:%M:%S')"
EXIT_CODE=0

if [ ! -f "$LOG_FILE" ]; then
  touch "$LOG_FILE" || {
    echo "[ERROR] Cannot create log file: $LOG_FILE" >&2
    exit 2
  }
fi

echo "[$DATE] Disk usage check started" >> "$LOG_FILE"

df -hP | awk 'NR>1 {print $5, $6}' | while read -r usage mount; do
  usage_percent=${usage%\%}

  if [ "$usage_percent" -ge "$THRESHOLD" ]; then
    echo "[$DATE] WARNING: $mount usage is at ${usage_percent}%" >> "$LOG_FILE"
    EXIT_CODE=1
  else
    echo "[$DATE] OK: $mount usage is at ${usage_percent}%" >> "$LOG_FILE"
  fi
done

echo "[$DATE] Disk usage check completed" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"

exit "$EXIT_CODE"
