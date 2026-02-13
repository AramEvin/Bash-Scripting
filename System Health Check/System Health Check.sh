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

echo -ne "Memory Usage:   "
free -m | awk -v g="${GREEN}" -v r="${RED}" -v n="${NC}" '/^Mem:/ {
    usage=$3*100/$2;
    color=(usage > 85 ? r : g);
    printf "%s%.2fGB / %.2fGB (%d%%)%s\n", color, $3/1024, $2/1024, usage, n
}'

echo -ne "Disk Usage (/): "
disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$disk_usage" -gt 90 ]; then
    echo -e "${RED}${disk_usage}% (Critical!)${NC}"
else
    echo -e "${GREEN}${disk_usage}% (Healthy)${NC}"
fi

load=$(uptime | awk -F'load average:' '{print $2}' | sed 's/,//g')
echo -e "Load Average:  ${YELLOW}${load}${NC}"

# 5. UPTIME
echo -ne "System Uptime:  "
uptime -p | sed 's/up //'

echo -e "${BOLD}==================================================${NC}"
