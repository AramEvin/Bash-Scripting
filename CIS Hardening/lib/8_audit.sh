#!/usr/bin/env bash

log "Applying Auditd Hardening..."

# -------------------------
# Ensure auditd installed
# -------------------------
apt-get install -y auditd audispd-plugins

systemctl enable auditd --now

RULES_FILE="/etc/audit/rules.d/cis.rules"

cat > "$RULES_FILE" <<EOF
# ----------------------------------------
# CIS Audit Rules
# ----------------------------------------

# Identity changes
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/gshadow -p wa -k identity

# Privilege Escalation
-w /etc/sudoers -p wa -k scope
-w /etc/sudoers.d/ -p wa -k scope

# Login / Logout Events
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/tallylog -p wa -k logins

# Time Changes
-a always,exit -F arch=b64 -S adjtimex,settimeofday -k time-change
-w /etc/localtime -p wa -k time-change

# Permission Modifications
-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -k perm_mod
-a always,exit -F arch=b64 -S chown,fchown,fchownat,lchown -k perm_mod

# Monitor privileged command execution
-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k privilege_escalation

# Make audit config immutable
-e 2
EOF

# Load rules
augenrules --load

systemctl restart auditd

log "Auditd hardening applied."
