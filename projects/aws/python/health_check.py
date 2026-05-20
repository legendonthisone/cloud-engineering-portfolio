#!/usr/bin/env python3
"""
Day 13 - EC2 Health Check Automation Tool
Cloud Engineering Portfolio - Legend
"""

import boto3
import warnings
from datetime import datetime, timezone

# Suppress the Python 3.9 deprecation warning
warnings.filterwarnings("ignore")

REGION        = "us-east-1"
INSTANCE_NAME = "My-Linux-Practice"
CPU_WARN      = 70
CPU_CRIT      = 90
LOG_FILE      = "/home/ec2-user/cloud-practice/logs/health_check.log"

# ── HELPERS ────────────────────────────────────────
def status_label(value, warn, crit):
    if value >= crit:
        return "CRITICAL"
    elif value >= warn:
        return "WARNING"
    else:
        return "OK"

def print_header(title):
    print("\n" + "─" * 50)
    print(f"  {title}")
    print("─" * 50)

# ── GET INSTANCE ───────────────────────────────────
def get_instance(ec2, name):
    response = ec2.describe_instances(
        Filters=[{"Name": "tag:Name", "Values": [name]}]
    )
    reservations = response.get("Reservations", [])
    if not reservations:
        print(f"ERROR: No instance found with name '{name}'")
        exit(1)
    return reservations[0]["Instances"][0]

# ── GET CPU ────────────────────────────────────────
def get_cpu(cw, instance_id):
    now   = datetime.now(timezone.utc)
    start = datetime(now.year, now.month, now.day, now.hour - 1, now.minute, tzinfo=timezone.utc)

    metrics = cw.get_metric_statistics(
        Namespace="AWS/EC2",
        MetricName="CPUUtilization",
        Dimensions=[{"Name": "InstanceId", "Value": instance_id}],
        StartTime=start,
        EndTime=now,
        Period=300,
        Statistics=["Average"]
    )

    datapoints = sorted(metrics["Datapoints"], key=lambda x: x["Timestamp"])
    if not datapoints:
        return None
    return round(datapoints[-1]["Average"], 2)

# ── GET INSTANCE STATUS CHECKS ─────────────────────
def get_status_checks(ec2, instance_id):
    response = ec2.describe_instance_status(InstanceIds=[instance_id])
    statuses = response.get("InstanceStatuses", [])
    if not statuses:
        return "no-data", "no-data"
    s = statuses[0]
    system   = s["SystemStatus"]["Status"]
    instance = s["InstanceStatus"]["Status"]
    return system, instance

# ── MAIN ───────────────────────────────────────────
def main():
    run_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    ec2 = boto3.client("ec2",        region_name=REGION)
    cw  = boto3.client("cloudwatch", region_name=REGION)

    print("=" * 50)
    print("  EC2 HEALTH CHECK REPORT")
    print(f"  Run time : {run_time}")
    print(f"  Instance : {INSTANCE_NAME}")
    print("=" * 50)

    # ── Instance Info ──
    print_header("Instance Info")
    instance    = get_instance(ec2, INSTANCE_NAME)
    instance_id = instance["InstanceId"]
    state       = instance["State"]["Name"]
    itype       = instance["InstanceType"]
    az          = instance["Placement"]["AvailabilityZone"]
    launched    = instance["LaunchTime"].strftime("%Y-%m-%d %H:%M")

    print(f"  ID       : {instance_id}")
    print(f"  Type     : {itype}")
    print(f"  State    : {state.upper()}")
    print(f"  AZ       : {az}")
    print(f"  Launched : {launched}")

    # ── Status Checks ──
    print_header("Status Checks")
    system_check, instance_check = get_status_checks(ec2, instance_id)
    print(f"  System check   : {system_check.upper()}")
    print(f"  Instance check : {instance_check.upper()}")

    # ── CPU ──
    print_header("CPU Utilization")
    cpu = get_cpu(cw, instance_id)
    if cpu is not None:
        label = status_label(cpu, CPU_WARN, CPU_CRIT)
        print(f"  Current : {cpu}%")
        print(f"  Status  : {label}")
        print(f"  Warn at : {CPU_WARN}%   Critical at : {CPU_CRIT}%")
    else:
        print("  No datapoints available yet.")

    # ── Summary ──
    print_header("Summary")
    checks = {
        "Instance state" : "OK" if state == "running" else "WARNING",
        "System check"   : "OK" if system_check   == "ok" else "WARNING",
        "Instance check" : "OK" if instance_check == "ok" else "WARNING",
        "CPU"            : status_label(cpu, CPU_WARN, CPU_CRIT) if cpu is not None else "NO DATA",
    }

    all_ok = all(v == "OK" for v in checks.values())

    for check, result in checks.items():
        indicator = "✓" if result == "OK" else "!"
        print(f"  [{indicator}] {check:<20} {result}")

    print()
    if all_ok:
        print("  ✓ All checks passed. Instance is healthy.")
    else:
        print("  ! One or more checks need attention.")

    print("\n" + "=" * 50)

    # ── Write to log file ──────────────────────────
    with open(LOG_FILE, "a") as log:
        log.write(f"\n{run_time} | State: {state.upper()} | "
                  f"CPU: {cpu}% | "
                  f"System: {system_check.upper()} | "
                  f"Instance: {instance_check.upper()} | "
                  f"Result: {'ALL OK' if all_ok else 'ATTENTION NEEDED'}\n")

if __name__ == "__main__":
    main()
