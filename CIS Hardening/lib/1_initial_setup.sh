#!/usr/bin/env bash

log "Starting Initial System Setup..."

detect_distribution() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
    else
        error "Cannot detect operating system."
        exit 1
    fi

    DISTRO_ID="$ID"
    DISTRO_VERSION="$VERSION_ID"

    log "Detected distribution: $DISTRO_ID $DISTRO_VERSION"

    case "$DISTRO_ID" in
        ubuntu)
            if [[ "$DISTRO_VERSION" != "22.04" ]]; then
                warn "Script designed for Ubuntu 22.04. Proceed with caution."
            fi
            PKG_MANAGER="apt"
            ;;
        rhel|centos|rocky|almalinux)
            PKG_MANAGER="dnf"
            ;;
        *)
            error "Unsupported distribution: $DISTRO_ID"
            exit 1
            ;;
    esac
}

update_system() {
    log "Updating system packages..."

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        apt-get update -y
        DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        dnf upgrade -y
    fi
}

install_security_packages() {
    log "Installing core security packages..."

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        apt-get install -y \
            unattended-upgrades \
            chrony \
            rsyslog \
            aide \
            auditd
    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        dnf install -y \
            chrony \
            rsyslog \
            aide \
            audit
    fi
}

enable_core_services() {
    log "Enabling core security services..."

    systemctl enable chrony --now
    systemctl enable rsyslog --now
    systemctl enable auditd --now 2>/dev/null || true
}

configure_auto_updates() {
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        log "Configuring automatic security updates..."

        cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

        dpkg-reconfigure -f noninteractive unattended-upgrades
    fi
}

secure_file_permissions() {
    log "Securing critical system file permissions..."

    chown root:root /etc/passwd
    chmod 644 /etc/passwd

    chown root:shadow /etc/shadow 2>/dev/null || true
    chmod 640 /etc/shadow

    chown root:root /etc/group
    chmod 644 /etc/group

    chown root:shadow /etc/gshadow 2>/dev/null || true
    chmod 640 /etc/gshadow
}

validate_time_sync() {
    log "Validating time synchronization..."

    if ! systemctl is-active --quiet chrony; then
        warn "Chrony is not running."
    else
        log "Chrony service is active."
    fi
}

remove_insecure_services() {
    log "Checking for insecure legacy services..."

    for svc in telnet rsh-server ypserv tftp; do
        if dpkg -l 2>/dev/null | grep -q "$svc"; then
            warn "Removing insecure service: $svc"
            apt-get purge -y "$svc"
        fi
    done
}

detect_distribution
update_system
install_security_packages
enable_core_services
configure_auto_updates
secure_file_permissions
validate_time_sync
remove_insecure_services

log "Initial System Setup completed successfully."
