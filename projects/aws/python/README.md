# Python AWS Automation — Cloud Engineering Portfolio

Scripts written during Week 2 of a 90-day cloud engineering training programme.

## Scripts

### basics.py
Python fundamentals practice — variables, f-strings, lists, dictionaries,
loops, and functions. Includes a reusable threshold checker modelled after
real monitoring logic.

### aws_info.py
boto3 script that queries three AWS services in a single run:
- Lists all S3 buckets with creation dates
- Describes all EC2 instances (running and stopped)
- Reads CloudWatch CPU metrics for the last 60 minutes

### health_check.py
Production-style EC2 health check automation tool.
- Queries instance state, status checks, and CPU utilisation
- Applies configurable WARNING and CRITICAL thresholds
- Writes timestamped log entries to ~/cloud-practice/logs/health_check.log
- Scheduled via cron to run every hour automatically

## Environment
- Amazon Linux 2023 on EC2 t2.micro
- Python 3.9 / boto3 1.42.97
- Permissions via IAM instance role (no hardcoded credentials)
