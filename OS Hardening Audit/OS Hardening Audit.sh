#!/bin/bash

REPORT_FILE="/var/log/os_hardening_audit_$(date +%F).txt"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

if [ ! -f "$REPORT_FILE" ]; then
    touch "$REPORT_FILE"
fi

echo "OS Hardening Audit Report - $DATE" > "$REPORT_FILE"
echo "---------------------------------" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Kernel Parameter Checks:" >> "$REPORT_FILE"

check_sysctl() {
    PARAM="$1"
    EXPECTED="$2"

    CURRENT=$(sysctl -n "$PARAM" 2>/dev/null)

    if [ "$CURRENT" = "$EXPECTED" ]; then
        echo "[OK]    $PARAM = $CURRENT" >> "$REPORT_FILE"
    else
        echo "[WARN]  $PARAM = $CURRENT (expected $EXPECTED)" >> "$REPORT_FILE"
    fi
}

check_sysctl net.ipv4.ip_forward 0
check_sysctl net.ipv4.conf.all.accept_redirects 0
check_sysctl net.ipv4.conf.all.send_redirects 0
check_sysctl net.ipv4.conf.all.accept_source_route 0
check_sysctl kernel.randomize_va_space 2

echo "" >> "$REPORT_FILE"
echo "Critical File Permissions:" >> "$REPORT_FILE"

check_perm() {
    FILE="$1"
    EXPECTED="$2"

    if [ -e "$FILE" ]; then
        ACTUAL=$(stat -c "%a" "$FILE")

        if [ "$ACTUAL" = "$EXPECTED" ]; then
            echo "[OK]    $FILE permissions = $ACTUAL" >> "$REPORT_FILE"
        else
            echo "[WARN]  $FILE permissions = $ACTUAL (expected $EXPECTED)" >> "$REPORT_FILE"
        fi
    else
        echo "[INFO]  $FILE not found" >> "$REPORT_FILE"
    fi
}

check_perm /etc/passwd 644
check_perm /etc/shadow 600
check_perm /etc/group 644
check_perm /etc/gshadow 600
echo "" >> "$REPORT_FILE"
echo "Audit completed." >> "$REPORT_FILE"
echo "Report saved to $REPORT_FILE"
