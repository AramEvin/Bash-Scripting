#!/bin/bash

SERVICES=("nginx" "ssh" "docker") #Add your Services
LOG_FILE="/var/log/service_status.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

log() {
    echo "[$DATE] $1" >> "$LOG_FILE"
}

check_service() {
    SERVICE="$1"

    systemctl is-active --quiet "$SERVICE"
    STATUS=$?

    if [ $STATUS -eq 0 ]; then
        log "Service $SERVICE is RUNNING"
    else
        log "Service $SERVICE is NOT RUNNING"
    fi
}

for service in "${SERVICES[@]}"
do
    check_service "$service"
done
