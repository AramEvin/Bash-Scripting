#!/usr/bin/env bash

log "Applying Cron & At restrictions..."

if [[ "$PKG_MANAGER" == "apt" ]]; then
    apt-get install -y cron at
elif [[ "$PKG_MANAGER" =~ rhel|centos|rocky|almalinux ]]; then
    dnf install -y cronie at
fi

systemctl enable cron --now 2>/dev/null || systemctl enable crond --now
systemctl enable atd --now

for file in /etc/cron.allow /etc/at.allow; do
    if [[ ! -f "$file" ]]; then
        touch "$file"
        chmod 600 "$file"
    fi
done

# Remove any deny files to enforce allow list
rm -f /etc/cron.deny /etc/at.deny

log "Cron & At restrictions applied."
