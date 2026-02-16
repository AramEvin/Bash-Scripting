#!/usr/bin/env bash

log "Applying Account & Password Hardening..."

apt-get install -y libpam-pwquality

log "Configuring password aging..."

sed -i "s/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   $PASS_MAX_DAYS/" /etc/login.defs
sed -i "s/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   $PASS_MIN_DAYS/" /etc/login.defs
sed -i "s/^PASS_WARN_AGE.*/PASS_WARN_AGE   $PASS_WARN_AGE/" /etc/login.defs

awk -F: '($3 >= 1000 && $1 != "nobody") {print $1}' /etc/passwd | while read -r user; do
    chage --maxdays "$PASS_MAX_DAYS" \
          --mindays "$PASS_MIN_DAYS" \
          --warndays "$PASS_WARN_AGE" "$user"
    log "Password aging set for $user"
done

log "Configuring password complexity..."

PWQUALITY_CONF="/etc/security/pwquality.conf"

sed -i 's/^# minlen =.*/minlen = 14/' "$PWQUALITY_CONF"
sed -i 's/^# dcredit =.*/dcredit = -1/' "$PWQUALITY_CONF"
sed -i 's/^# ucredit =.*/ucredit = -1/' "$PWQUALITY_CONF"
sed -i 's/^# ocredit =.*/ocredit = -1/' "$PWQUALITY_CONF"
sed -i 's/^# lcredit =.*/lcredit = -1/' "$PWQUALITY_CONF"

log "Configuring account lockout policy..."

AUTH_FILE="/etc/pam.d/common-auth"

if ! grep -q "pam_faillock.so" "$AUTH_FILE"; then
    sed -i '1i auth required pam_faillock.so preauth silent audit deny=5 unlock_time=900' "$AUTH_FILE"
    sed -i '1i auth [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900' "$AUTH_FILE"
fi

ACCOUNT_FILE="/etc/pam.d/common-account"

if ! grep -q "pam_faillock.so" "$ACCOUNT_FILE"; then
    echo "account required pam_faillock.so" >> "$ACCOUNT_FILE"
fi

log "Account & Password hardening completed."
