#!/usr/bin/env bash

log "Applying Logging & Log Hardening (CIS Section 4/8)..."

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
else
    error "Cannot detect OS."
    exit 1
fi

DISTRO="$ID"

install_rsyslog() {
    log "Ensuring rsyslog is installed..."
    if [[ "$DISTRO" == "ubuntu" ]]; then
        apt-get install -y rsyslog
    elif [[ "$DISTRO" =~ rhel|centos|rocky|almalinux ]]; then
        dnf install -y rsyslog
    fi
}

enable_rsyslog() {
    log "Enabling and starting rsyslog..."
    systemctl enable rsyslog --now
}

configure_persistent_logs() {
    log "Ensuring persistent logs..."

    RSYSLOG_CONF="/etc/rsyslog.conf"
    if ! grep -q "^\$ActionFileDefaultTemplate" "$RSYSLOG_CONF"; then
        echo '$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat' >> "$RSYSLOG_CONF"
    fi

    mkdir -p /var/log
    chmod 750 /var/log
    chown root:adm /var/log
}

configure_logrotate() {
    log "Configuring logrotate for system logs..."
    if [[ "$DISTRO" == "ubuntu" ]]; then
        apt-get install -y logrotate
    elif [[ "$DISTRO" =~ rhel|centos|rocky|almalinux ]]; then
        dnf install -y logrotate
    fi
}

secure_log_permissions() {
    log "Securing log file permissions..."
    find /var/log -type f -exec chmod 640 {} \;
    find /var/log -type f -exec chown root:adm {} \; 2>/dev/null || true
}

configure_remote_syslog() {
    REMOTE_SYSLOG=${REMOTE_SYSLOG:-""}  # Leave empty to skip
    if [[ -n "$REMOTE_SYSLOG" ]]; then
        log "Configuring remote syslog forwarding to $REMOTE_SYSLOG..."
        echo "*.* @$REMOTE_SYSLOG" >> /etc/rsyslog.d/50-remote.conf
        systemctl restart rsyslog
    fi
}

install_rsyslog
enable_rsyslog
configure_persistent_logs
configure_logrotate
secure_log_permissions
configure_remote_syslog

log "Logging hardening completed."
