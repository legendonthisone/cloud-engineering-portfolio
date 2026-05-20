#!/bin/bash

# s3-backup.sh
# Purpose: Back up important files from EC2 to S3
# Portfolio Script 2 — Day 9

# ─────────────────────────────────────────
# CONFIGURATION — edit these values
# ─────────────────────────────────────────

BUCKET="legend-ec2-backups-2026"
BACKUP_DIR="/home/ec2-user/cloud-practice"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP_NAME="backup_${TIMESTAMP}"
LOG_FILE="/home/ec2-user/cloud-practice/backup.log"

# ─────────────────────────────────────────
# FUNCTIONS
# ─────────────────────────────────────────

log_info() {
    echo "[INFO]  $(date '+%H:%M:%S') — $1" | tee -a $LOG_FILE
}

log_warn() {
    echo "[WARN]  $(date '+%H:%M:%S') — $1" | tee -a $LOG_FILE
}

log_error() {
    echo "[ERROR] $(date '+%H:%M:%S') — $1" | tee -a $LOG_FILE
}

check_aws_connection() {
    log_info "Checking AWS connection..."
    if aws sts get-caller-identity > /dev/null 2>&1; then
        log_info "AWS connection OK"
    else
        log_error "Cannot connect to AWS — aborting backup"
        exit 1
    fi
}

run_backup() {
    log_info "Starting backup: $BACKUP_NAME"
    log_info "Source: $BACKUP_DIR"
    log_info "Destination: s3://$BUCKET/$BACKUP_NAME/"

    aws s3 cp $BACKUP_DIR s3://$BUCKET/$BACKUP_NAME/ \
        --recursive \
        --exclude "*.log"

    if [ $? -eq 0 ]; then
        log_info "Backup completed successfully"
    else
        log_error "Backup failed"
        exit 1
    fi
}

verify_backup() {
    log_info "Verifying backup in S3..."
    FILE_COUNT=$(aws s3 ls s3://$BUCKET/$BACKUP_NAME/ --recursive | wc -l)

    if [ $FILE_COUNT -gt 0 ]; then
        log_info "Verified: $FILE_COUNT file(s) uploaded to S3"
    else
        log_warn "Backup folder exists but appears empty"
    fi
}

print_summary() {
    echo ""
    echo "=========================================="
    echo " BACKUP SUMMARY"
    echo " Backup name: $BACKUP_NAME"
    echo " Bucket: s3://$BUCKET"
    echo " Log: $LOG_FILE"
    echo "=========================================="
}

# ─────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────

check_aws_connection
run_backup
verify_backup
print_summary
