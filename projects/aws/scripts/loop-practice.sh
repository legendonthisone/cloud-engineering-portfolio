#!/bin/bash

# loop-practice.sh
# Purpose: Practice for loops and while loops

echo "--- FOR LOOP: counting ---"
for i in 1 2 3 4 5; do
    echo "Number: $i"
done


echo ""
echo "--- FOR LOOP: checking services ---"
SERVICES="nginx crond sshd"

for SERVICE in $SERVICES; do
    if systemctl is-active --quiet $SERVICES; then
        echo "✅  $SERVICE is running"
    else 
        echo "x $SERVICE is not running"
    fi
done


echo ""
echo "--- WHILE LOOP: countdown ---"
COUNT=5
while [ $COUNT -gt 0 ]; do
    echo "Countdown: $COUNT"
    COUNT=$(( COUNT - 1 ))
done
echo "Done."
