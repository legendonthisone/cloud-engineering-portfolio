#!/usr/bin/env python3
"""

Day 11 - Python Basics
Cloud Engineering Portfolio - Legend
"""


# ── VARIABLES ──────────────────────────────────────────────
name = "Legend"
role = "Cloud Engineer"
experience_days = 11


# ── STRINGS ──────────────────────────────────────────────
greeting = f"Hello, I am {name} - training to be a {role}."
print(greeting)


#String methods
print(role.upper())           # CLOUD ENGINEER
print(role.replace("Cloud", "AWS"))  # AWS Engineer


# ── NUMBERS ────────────────────────────────────────────────
weeks_done = experience_days // 7
days_remaining = 90 - experience_days
print(f"Weeks complete: {weeks_done}, Days remaining: {days_remaining}")


# ── LISTS ──────────────────────────────────────────────────
aws_services = ["EC2", "S3", "IAM", "CloudWatch", "VPC"]


print(f"\nAWS services I know: {aws_services}")
print(f"First service: {aws_services[0]}")
print(f"Last service:  {aws_services[-1]}")


# Add to a list
aws_services.append("Lambda")
print(f"After append:  {aws_services}")


# Loop through a list
print("\nAll services:")
for service in aws_services:
    print(f"  - {service}")

# ── DICTIONARIES ───────────────────────────────────────────
ec2_instance = {
    "name": "My-Linux-Practice",
    "type": "t2.micro",
    "region": "us-east-1",
    "status": "running"
}


print(f"\nInstance name:  {ec2_instance['name']}")
print(f"Instance region: {ec2_instance['region']}")


# Loop through disctionary
print("\nInstance details:")
for key, value in ec2_instance.items():
    print(f"  {key}: {value}")


# ── FUNCTIONS ──────────────────────────────────────────────
def check_threshold(metric_name, current_value, threshold=80):
    """Returns a status string for a given metric."""
    if current_value >= threshold:
        return f"WARNING: {metric_name} is at {current_value}% (threshold: {threshold}%)"
    else:
        return f"OK: {metric_name} is at {current_value}%"


# Test the function
print("\n── Threshold Checks ──")
print(check_threshold("CPU", 45))
print(check_threshold("Memory", 85))
print(check_threshold("Disk", 92, threshold=90))




