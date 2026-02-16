#!/usr/bin/env bash

log "Applying Kernel Network Hardening..."

SYSCTL_FILE="/etc/sysctl.d/99-cis-hardening.conf"

cat > "$SYSCTL_FILE" <<EOF
# ----------------------------------------
# CIS Network Hardening
# ----------------------------------------

# IP Spoofing Protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Disable ICMP Redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# Disable Source Routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Log Suspicious Packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Enable TCP SYN Cookies
net.ipv4.tcp_syncookies = 1

# Ignore Broadcast ICMP
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Disable IPv6 Router Advertisements
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0
EOF

# Apply immediately
sysctl --system

log "Kernel network hardening applied."
