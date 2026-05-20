# Cloud Engineering Portfolio — Bash Scripts

Automation scripts written during a 90-day cloud engineering programme.

## Scripts

### health-check.sh
Checks disk, memory, CPU load and service status on an EC2 instance.
Reports warnings when thresholds are exceeded.

### s3-backup.sh
Backs up EC2 files to S3 with timestamped folders.
Includes AWS connection check, logging, and verification.
Scheduled via cron to run daily at 2am.

### ec2-monitor.sh
Collects disk, memory and CPU metrics and pushes them to AWS CloudWatch
as custom metrics under the Custom/EC2Monitor namespace.

## Environment
- Amazon Linux 2023
- AWS EC2 t2.micro
- Region: us-east-1
