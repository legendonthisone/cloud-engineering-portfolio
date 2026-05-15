#!/bin/bash

# ec2-monitor.sh
# Purpose: Monitor EC2 instance and send metrics to CloudWatch
# Portfolio Script 3 — Day 10

# ─────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
REGION="us-east-1"
NAMESPACE="Custom/EC2Monitor"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# ─────────────────────────────────────────
# FUNCTIONS
# ─────────────────────────────────────────

log_info() {
    echo "[INFO]  $(date '+%H:%M:%S') — $1"
}

get_disk_percent() {
    df / | tail -1 | awk '{print $5}' | tr -d '%'
}

get_mem_percent_used() {
    free | grep Mem | awk '{printf "%.0f", ($3/$2)*100}'
}

get_cpu_load() {
    uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '
}

send_metric() {
    METRIC_NAME=$1
    METRIC_VALUE=$2
    METRIC_UNIT=$3

    aws cloudwatch put-metric-data \
        --namespace $NAMESPACE \
        --metric-name $METRIC_NAME \
        --value $METRIC_VALUE \
        --unit $METRIC_UNIT \
        --dimensions Name=InstanceId,Value=$INSTANCE_ID \
        --region $REGION

    if [ $? -eq 0 ]; then
        log_info "Sent $METRIC_NAME: $METRIC_VALUE $METRIC_UNIT"
    else
        log_info "Failed to send $METRIC_NAME"
    fi
}

print_summary() {
    echo ""
    echo "=========================================="
    echo " EC2 MONITOR REPORT"
    echo " Instance: $INSTANCE_ID"
    echo " Time: $TIMESTAMP"
    echo " Namespace: $NAMESPACE"
    echo "=========================================="
}

# ─────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────

log_info "Starting EC2 monitor..."
log_info "Instance ID: $INSTANCE_ID"

DISK=$(get_disk_percent)
MEM=$(get_mem_percent_used)
CPU=$(get_cpu_load)

log_info "Disk: ${DISK}%  Memory: ${MEM}%  CPU load: ${CPU}"

send_metric "DiskUsedPercent" $DISK "Percent"
send_metric "MemoryUsedPercent" $MEM "Percent"
send_metric "CPULoad" $CPU "None"

print_summary
