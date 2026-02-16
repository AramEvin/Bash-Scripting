#!/usr/bin/env bash

log "Applying SSH hardening..."

if [[ "$DISABLE_ROOT_LOGIN" == "true" ]]; then
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
fi

sed -i "s/^#*Port.*/Port $SSH_PORT/" /etc/ssh/sshd_config
sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 4/' /etc/ssh/sshd_config
sed -i 's/^#*IgnoreRhosts.*/IgnoreRhosts yes/' /etc/ssh/sshd_config

systemctl restart sshd

log "SSH hardening applied."
