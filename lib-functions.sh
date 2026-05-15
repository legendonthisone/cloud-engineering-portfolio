#!/bin/bash

# lib-functions.sh
# Purpose: Shared functions for cloud engineering scripts
# Usage: source ~/cloud-practice/projects/aws/scripts/lib-functions.sh

log_info() {
    echo "[INFO]  $(date '+%H:%M:%S') — $1"
}

log_warn() {
    echo "[WARN]  $(date '+%H:%M:%S') — $1"
}

log_error() {
    echo "[ERROR] $(date '+%H:%M:%S') — $1"
}

is_service_running() {
    systemctl is-active --quiet $1
}
