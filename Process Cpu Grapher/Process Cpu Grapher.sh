#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

PID="${1:-}"
INTERVAL="${2:-1}"

usage() {
    echo "Usage: $0 <PID> [interval_seconds]"
    exit 1
}

[[ -z "$PID" ]] && usage
[[ -d "/proc/$PID" ]] || { echo "Error: PID $PID not found."; exit 1; }

# Get number of CPU cores (for normalization)
CPU_CORES=$(nproc)

get_total_cpu() {
    awk '/^cpu / {for (i=2; i<=NF; i++) sum+=$i} END {print sum}' /proc/stat
}

get_process_cpu() {
    awk '{print $14 + $15}' "/proc/$PID/stat"
}

echo "Monitoring PID $PID (Ctrl+C to stop)"
echo "Interval: ${INTERVAL}s | CPU Cores: $CPU_CORES"
echo "---------------------------------------------"

prev_total=$(get_total_cpu)
prev_proc=$(get_process_cpu)

while true; do
    sleep "$INTERVAL"

    [[ -d "/proc/$PID" ]] || { echo "Process ended."; exit 0; }

    total=$(get_total_cpu)
    proc=$(get_process_cpu)

    delta_total=$((total - prev_total))
    delta_proc=$((proc - prev_proc))

    if [[ "$delta_total" -gt 0 ]]; then
        cpu_percent=$(awk "BEGIN {printf \"%.2f\", ($delta_proc/$delta_total)*100*$CPU_CORES}")
    else
        cpu_percent="0.00"
    fi

    printf "CPU Usage: %6s%% | " "$cpu_percent"

    bar_length=$(awk "BEGIN {printf \"%d\", $cpu_percent/2}")
    printf "%-${bar_length}s" "#" | tr ' ' '#'
    echo

    prev_total=$total
    prev_proc=$proc
done
