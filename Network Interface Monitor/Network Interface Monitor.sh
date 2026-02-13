#!/bin/bash

# --- 1. Interface Selection ---
# Automatically list available interfaces so the user doesn't have to guess
echo "Available Interfaces:"
interfaces=$(ls /sys/class/net | grep -v "lo")
select INTERFACE in $interfaces "Exit"; do
    [[ $INTERFACE == "Exit" ]] && exit 0
    [[ -n $INTERFACE ]] && break
    echo "Invalid selection. Please try again."
done


read -p "Monitor for how many seconds? (Enter for infinite): " DURATION
[[ -z "$DURATION" ]] && DURATION=999999

echo -e "\nMonitoring $INTERFACE... (Press Ctrl+C to stop)"
echo "------------------------------------------------"


RX_OLD=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX_OLD=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
SECONDS_ELAPSED=0


while [ $SECONDS_ELAPSED -lt $DURATION ]; do
    sleep 1
    
    RX_NEW=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    TX_NEW=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

    RX_RATE=$(( ($RX_NEW - $RX_OLD) / 1024 ))
    TX_RATE=$(( ($TX_NEW - $TX_OLD) / 1024 ))

    
    printf "\r\033[K[%-2s/%-2s s]  📥 Download: %'8d KB/s  |  📤 Upload: %'8d KB/s" \
           "$((SECONDS_ELAPSED + 1))" "$DURATION" "$RX_RATE" "$TX_RATE"

    RX_OLD=$RX_NEW
    TX_OLD=$TX_NEW
    ((SECONDS_ELAPSED++))
done

echo -e "\n\nMonitoring complete."
