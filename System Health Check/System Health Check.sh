#!/bin/bash
# system_health.sh - Check system resources

echo "=== System Health Report ==="
echo "Date: $(date)"
echo ""
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'
echo ""
echo "Memory Usage:"
free -m | awk '/^Mem:/ {printf "%.2fGB / %.2fGB (%d%%)\n", $3/1024, $2/1024, $3*100/$2}'
echo ""
echo "Disk Usage:"
df -h | grep -E '^/dev/' | awk '{print $1 ": " $5 " (" $3 "/" $2 ")"}'
echo ""
echo "Load Average:"
uptime | awk -F'load average:' '{print $2}'
