#!/usr/bin/env bash

log "Starting Service Minimization (CIS Section 2)..."

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
else
    error "Cannot detect OS."
    exit 1
fi

DISTRO="$ID"

LEGACY_SERVICES=(
    telnet
    telnet.socket
    rsh-server
    rlogin
    rexec
    ypserv
    tftp
    tftp.socket
    xinetd
    avahi-daemon
    cups
    slapd
    nfs-server
)

service_exists() {
    systemctl list-unit-files | grep -q "^$1"
}

disable_service() {
    local svc="$1"

    if service_exists "$svc"; then
        log "Disabling service: $svc"
        systemctl stop "$svc" 2>/dev/null || true
        systemctl disable "$svc" 2>/dev/null || true

        if [[ "$MASK_UNUSED_SERVICES" == "true" ]]; then
            systemctl mask "$svc" 2>/dev/null || true
            log "Masked service: $svc"
        fi
    else
        log "Service $svc not found. Skipping."
    fi
}

remove_legacy_packages() {
    if [[ "$DISTRO" == "ubuntu" && "$REMOVE_LEGACY_SERVICES" == "true" ]]; then
        log "Removing legacy packages..."
        apt-get purge -y telnet rsh-server ypserv tftp xinetd 2>/dev/null || true
    fi
}

if systemctl list-units | grep -q cloud-init; then
    log "Cloud environment detected. Preserving cloud-init."
fi

for svc in "${LEGACY_SERVICES[@]}"; do
    disable_service "$svc"
done

remove_legacy_packages

log "Service Minimization completed."
