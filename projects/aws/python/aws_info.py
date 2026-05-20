#!/usr/bin/env python3
"""
Day 12 - boto3 Basics
Query AWS directly from Python
Cloud Engineering Portfolio - Legend
"""

import boto3
from datetime import datetime, timezone

print("=" * 50)
print("  AWS Account Info — boto3 Script")
print("=" * 50)

# ── S3 BUCKETS ─────────────────────────────────────
print("\n── S3 Buckets ──")

s3 = boto3.client("s3")
response = s3.list_buckets()
buckets = response["Buckets"]

if buckets:
    for bucket in buckets:
        print(f"  {bucket['Name']}  (created: {bucket['CreationDate'].strftime('%Y-%m-%d')})")
else:
    print("  No buckets found.")

# ── EC2 INSTANCES ──────────────────────────────────
print("\n── EC2 Instances ──")

ec2 = boto3.client("ec2", region_name="us-east-1")
response = ec2.describe_instances()

for reservation in response["Reservations"]:
    for instance in reservation["Instances"]:
        # Get the Name tag
        name = "Unnamed"
        for tag in instance.get("Tags", []):
            if tag["Key"] == "Name":
                name = tag["Value"]

        instance_id   = instance["InstanceId"]
        instance_type = instance["InstanceType"]
        state         = instance["State"]["Name"]
        az            = instance["Placement"]["AvailabilityZone"]

        print(f"  Name:  {name}")
        print(f"  ID:    {instance_id}")
        print(f"  Type:  {instance_type}")
        print(f"  State: {state}")
        print(f"  AZ:    {az}")
        print()

# ── CLOUDWATCH CPU METRIC ──────────────────────────
print("── CloudWatch: CPU (last 60 min) ──")

# Get your instance ID first
response   = ec2.describe_instances(Filters=[{"Name": "tag:Name", "Values": ["My-Linux-Practice"]}])
instance_id = response["Reservations"][0]["Instances"][0]["InstanceId"]

cw = boto3.client("cloudwatch", region_name="us-east-1")

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

if datapoints:
    for point in datapoints[-3:]:   # show last 3 readings
        ts  = point["Timestamp"].strftime("%H:%M")
        cpu = round(point["Average"], 2)
        print(f"  {ts}  →  CPU: {cpu}%")
else:
    print("  No datapoints yet — instance may have just started.")

print("\n" + "=" * 50)
print("  Script complete.")
print("=" * 50)
