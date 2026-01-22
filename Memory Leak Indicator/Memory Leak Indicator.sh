#!/bin/bash

SNAPSHOT_DIR="/tmp/memory_snapshots"
THRESHOLD_KB=50000
DATE=$(date +%s)

mkdir -p "$SNAPSHOT_DIR"

if [ ! -d "$SNAPSHOT_DIR" ]; then
    mkdir "$SNAPSHOT_DIR"
fi

SNAPSHOT_FILE="$SNAPSHOT_DIR/mem_$DATE.txt"
PREV_SNAPSHOT=$(ls "$SNAPSHOT_DIR"/mem_*.txt 2>/dev/null | tail -n 1)

ps -eo pid,comm,rss --sort=rss > "$SNAPSHOT_FILE"

if [ -f "$PREV_SNAPSHOT" ]; then
    echo "Processes with possible memory leaks:"
    echo "PID | Process | RSS Increase (KB)"
    echo "--------------------------------"

    awk 'NR==FNR {rss[$1]=$3; name[$1]=$2; next}
         ($1 in rss) {
            diff=$3-rss[$1]
            if (diff > '"$THRESHOLD_KB"')
                print $1 " | " $2 " | +" diff
         }' "$PREV_SNAPSHOT" "$SNAPSHOT_FILE"
else
    echo "No previous snapshot found. Baseline created."
fi
