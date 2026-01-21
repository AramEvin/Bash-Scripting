#!/usr/bin/env bash

set -euo pipefail

REPORT_DIR="/var/log/security-audit"
REPORT_FILE="$REPORT_DIR/suid_sgid_audit_$(date +%F-%H:%M:%S).txt"

# Filesystems to exclude
EXCLUDES=(
  "/tmp"
  "/proc"
  "/sys"
  "/dev"
  "/run"
  "/snap"
  "/var/lib/docker"
)

if [ ! -d "$REPORT_DIR" ]; then
  mkdir -p "$REPORT_DIR" || {
    echo "ERROR: Unable to create report directory: $REPORT_DIR" >&2
    exit 1
  }
fi

echo "SUID / SGID Security Audit Report" > "$REPORT_FILE"
echo "Hostname: $(hostname)" >> "$REPORT_FILE"
echo "Date: $(date)" >> "$REPORT_FILE"
echo "===================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Build exclude arguments for find
EXCLUDE_ARGS=()
for path in "${EXCLUDES[@]}"; do
  EXCLUDE_ARGS+=( -path "$path" -prune -o )
done

echo "[+] Scanning for SUID files..." | tee -a "$REPORT_FILE"
find / "${EXCLUDE_ARGS[@]}" -type f -perm -4000 -print 2>/dev/null | tee -a "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "[+] Scanning for SGID files..." | tee -a "$REPORT_FILE"
find / "${EXCLUDE_ARGS[@]}" -type f -perm -2000 -print 2>/dev/null | tee -a "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "[+] Detailed permissions and ownership:" >> "$REPORT_FILE"

find / "${EXCLUDE_ARGS[@]}" -type f \( -perm -4000 -o -perm -2000 \) \
  -exec ls -l {} \; 2>/dev/null >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "Audit completed successfully." >> "$REPORT_FILE"
echo "Report saved to: $REPORT_FILE"

echo "[✔] Audit complete"
