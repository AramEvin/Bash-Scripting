#!/usr/bin/env bash

log "Applying Filesystem Hardening..."

disable_filesystem() {
    local fs="$1"

    if lsmod | grep -q "$fs"; then
        warn "$fs is loaded. Unloading..."
        modprobe -r "$fs"
    fi

    echo "install $fs /bin/true" > "/etc/modprobe.d/${fs}.conf"
    log "$fs disabled."
}



for fs in cramfs freevxfs jffs2 hfs hfsplus udf; do
    disable_filesystem "$fs"
done


if ! mount | grep -q "on /tmp "; then
    warn "/tmp is not a separate partition. Consider separate partition for full CIS compliance."
else
    mount -o remount,nodev,nosuid,noexec /tmp
    log "/tmp remounted with nodev,nosuid,noexec"
fi

log "Setting sticky bit on world-writable directories..."

find / -xdev -type d -perm -0002 ! -perm -1000 2>/dev/null | while read -r dir; do
    chmod +t "$dir"
    log "Sticky bit set on $dir"
done

log "Filesystem hardening completed."
