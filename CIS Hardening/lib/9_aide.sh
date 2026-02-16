#!/usr/bin/env bash

log "Applying AIDE File Integrity Monitoring..."

# -------------------------
# Install AIDE
# -------------------------
apt-get install -y aide aide-common

# -------------------------
# Initialize AIDE Database
# -------------------------
log "Initializing AIDE database..."

aideinit

# Move new database into place
if [[ -f /var/lib/aide/aide.db.new ]]; then
    mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    chmod 600 /var/lib/aide/aide.db
    log "AIDE database initialized and secured."
else
    error "AIDE database initialization failed."
fi

# -------------------------
# Configure Daily Check
# -------------------------
log "Configuring daily AIDE check..."

cat > /etc/cron.daily/aide-check <<EOF
#!/usr/bin/env bash
/usr/bin/aide.wrapper --check
EOF

chmod 700 /etc/cron.daily/aide-check

log "AIDE daily integrity check configured."
