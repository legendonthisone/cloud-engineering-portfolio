#!/bin/bash

# health-check.sh
# Purpose: Server health check with functions
# Updated: Day 8 — restructured with functions

SERVER_NAME=$(hostname)
REPORT_DATE=$(date '+%Y-%m-%d %H:%M:%S')

# ─────────────────────────────────────────
# FUNCTIONS
# ─────────────────────────────────────────

print_header() {
    echo "=========================================="
    echo " SERVER HEALTH CHECK: $SERVER_NAME"
    echo " Run time: $REPORT_DATE"
    echo "=========================================="
    echo ""
}

check_disk() {
    echo "--- DISK USAGE ---"
    df -h /

    DISK_PERCENT=$(df / | tail -1 | awk '{print $5}' | tr -d '%')

    if [ $DISK_PERCENT -gt 80 ]; then
        echo "⚠ WARNING: Disk is ${DISK_PERCENT}% full — action needed"
    else
        echo "✅ Disk OK: ${DISK_PERCENT}% used"
    fi
    echo ""
}

check_memory() {
    echo "--- MEMORY USAGE ---"
    free -h

    MEM_FREE=$(free | grep Mem | awk '{print $4}')
    MEM_TOTAL=$(free | grep Mem | awk '{print $2}')
    MEM_PERCENT=$(( MEM_FREE * 100 / MEM_TOTAL ))

    if [ $MEM_PERCENT -lt 20 ]; then
        echo "⚠ WARNING: Only ${MEM_PERCENT}% memory free"
    else
        echo "✅ Memory OK: ${MEM_PERCENT}% free"
    fi
    echo ""
}

check_services() {
    echo "--- SERVICE STATUS ---"
    SERVICES="nginx crond sshd"

    for SERVICE in $SERVICES; do
        if systemctl is-active --quiet $SERVICE; then
            echo "✅ $SERVICE is running"
        else
            echo "⚠ $SERVICE is NOT running"
        fi
    done
    echo ""
}

check_cpu() {
    echo "--- CPU LOAD ---"
    uptime
    echo ""
}

print_footer() {
    echo "=========================================="
    echo " Health check complete."
    echo "=========================================="
}

# ─────────────────────────────────────────
# MAIN — this is where the script runs
# ─────────────────────────────────────────

print_header
check_disk
check_memory
check_services
check_cpu
print_footer
