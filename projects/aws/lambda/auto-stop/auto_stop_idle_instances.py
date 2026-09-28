import boto3
from datetime import datetime, timedelta, timezone

ec2 = boto3.client('ec2')
cloudwatch = boto3.client('cloudwatch')

# A server counts as "idle" if its average CPU over the last hour is below this %.
CPU_THRESHOLD = 5.0

def get_average_cpu(instance_id):
    # Ask CloudWatch for this server's CPU over the last hour.
    response = cloudwatch.get_metric_statistics(
        Namespace='AWS/EC2',
        MetricName='CPUUtilization',
        Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
        StartTime=datetime.now(timezone.utc) - timedelta(hours=1),
        EndTime=datetime.now(timezone.utc),
        Period=3600,            # one 60-minute bucket
        Statistics=['Average']
    )
    points = response['Datapoints']
    if not points:
        return None             # no data yet (e.g. a brand-new server)
    return points[0]['Average']

def lambda_handler(event, context):
    # 1. Find every running server.
    response = ec2.describe_instances(
        Filters=[{'Name': 'instance-state-name', 'Values': ['running']}]
    )

    stopped = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']

            # 2. Turn its tags into a simple lookup (name -> value).
            tags = {t['Key']: t['Value'] for t in instance.get('Tags', [])}

            # 3. Check how busy it has been.
            cpu = get_average_cpu(instance_id)
            print(f"{instance_id}: avg CPU = {cpu}, AutoStop = {tags.get('AutoStop')}")

            # 4. Stop it ONLY if it's idle AND tagged AutoStop=true.
            if cpu is not None and cpu < CPU_THRESHOLD and tags.get('AutoStop') == 'true':
                ec2.stop_instances(InstanceIds=[instance_id])
                stopped.append(instance_id)
                print(f"  -> stopping {instance_id} (idle and tagged AutoStop=true)")

    print(f"Stopped instances: {stopped}")
    return {'stopped_instances': stopped}
