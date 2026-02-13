#!/bin/bash
Find files larger than specified size

SIZE=${1:-100M}
DIRECTORY=${2:-.}

echo "Finding files larger than $SIZE in $DIRECTORY..."

find "$DIRECTORY" -type f -size +$SIZE -exec ls -lh {} \; | awk '{print $9 ": " $5}'
