#!/bin/bash

GREEN='\033[032m'
RED='\033[031m'
YELLOW='\033[033m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}==================================================${NC}"
echo -e "${BOLD}   SYSTEM HEALTH REPORT - $(hostname) ${NC}"
echo -e "   Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "${BOLD}==================================================${NC}"

cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
cpu_usage=$(echo "100 - $cpu_idle" | bc)
echo -ne "CPU Usage:      "
if (( $(echo "$cpu_usage > 80" | bc -l) )); then
    echo -e "${RED}${cpu_usage}% (High)${NC}"
else
    echo -e "${GREEN}${cpu_usage}% (Normal)${NC}"
fi
