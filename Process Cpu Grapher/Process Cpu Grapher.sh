#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

PID="${1:-}"
INTERVAL="${2:-1}"
DURATION="${3:-60}"

[[ -z "$PID" ]] && { echo "Usage: $0 <PID> [interval] [duration]"; exit 1; }
[[ -d "/proc/$PID" ]] || { echo "PID $PID not found."; exit 1; }

OUTPUT_FILE="cpu_usage_${PID}_$(date +%s).csv"

echo "timestamp,cpu_percent" > "$OUTPUT_FILE"

get_total_cpu() {
    awk '/^cpu / {for (i=2; i<=NF; i++) sum+=$i} END {print sum}' /proc/stat
}

get_process_cpu() {
    awk '{print $14 + $15}' "/proc/$PID/stat"
}

echo "[INFO] Monitoring PID $PID for $DURATION seconds (interval: $INTERVAL s)"
echo "[INFO] Logging to $OUTPUT_FILE"

prev_total=$(get_total_cpu)
prev_proc=$(get_process_cpu)

for ((i=0; i<DURATION; i+=INTERVAL)); do
    sleep "$INTERVAL"

    [[ -d "/proc/$PID" ]] || { echo "[INFO] Process ended."; break; }

    total=$(get_total_cpu)
    proc=$(get_process_cpu)

    delta_total=$((total - prev_total))
    delta_proc=$((proc - prev_proc))

    if [[ "$delta_total" -gt 0 ]]; then
        cpu_percent=$(awk "BEGIN {printf \"%.2f\", ($delta_proc/$delta_total)*100}")
    else
        cpu_percent=0
    fi

    timestamp=$(date +"%H:%M:%S")
    echo "$timestamp,$cpu_percent" >> "$OUTPUT_FILE"

    printf "%s | %-6s%% " "$timestamp" "$cpu_percent"

    # ASCII bar graph
    bars=$(printf "%.0f" "$cpu_percent")
    printf "%*s\n" "$bars" | tr ' ' '#'

    prev_total=$total
    prev_proc=$proc
done

echo "[INFO] Monitoring complete."
echo "[INFO] CSV data saved to $OUTPUT_FILE"
