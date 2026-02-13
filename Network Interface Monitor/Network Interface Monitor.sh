#!/bin/bash
# network_monitor.sh - Monitor network traffic

INTERFACE="eth0"

echo "Monitoring $INTERFACE (Press Ctrl+C to stop)"

RX_BYTES_OLD=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX_BYTES_OLD=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

while true; do
    sleep 1
    RX_BYTES_NEW=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    TX_BYTES_NEW=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
    
    RX_RATE=$(( ($RX_BYTES_NEW - $RX_BYTES_OLD) / 1024 ))
    TX_RATE=$(( ($TX_BYTES_NEW - $TX_BYTES_OLD) / 1024 ))
    
    echo "RX: ${RX_RATE} KB/s | TX: ${TX_RATE} KB/s"
    
    RX_BYTES_OLD=$RX_BYTES_NEW
    TX_BYTES_OLD=$TX_BYTES_NEW
done
