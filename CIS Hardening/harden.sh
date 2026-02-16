#!/bin/bash

set -Eeuo pipefail
IFS=$'\n\t'

readonly LOG_FILE="/var/log/cis-hardening.log"
readonly CONFIG_FILE="./config.conf"

# -------------------------
# Logging
# -------------------------
log() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

warn() {
    echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE" >&2
}

trap 'error "Script failed at line $LINENO"' ERR

# -------------------------
# Root Check
# -------------------------
if [[ "$EUID" -ne 0 ]]; then
    error "Run as root."
    exit 1
fi

# -------------------------
# Load Config
# -------------------------
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    error "Missing config.conf"
    exit 1
fi

# -------------------------
# OS Check
# -------------------------
if [[ ! -f /etc/os-release ]]; then
    error "Unsupported OS"
    exit 1
fi

source /etc/os-release
if [[ "$ID" != "ubuntu" ]]; then
    error "This script supports Ubuntu only."
    exit 1
fi

log "Starting CIS Hardening - Ubuntu $VERSION_ID"

# -------------------------
# Execute Modules
# -------------------------
for module in lib/*.sh; do
    log "Executing $module"
    source "$module"
done

log "CIS Hardening completed successfully."
