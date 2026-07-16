# CloudOps Sentinel

A self-monitoring, self-healing AWS environment, deployed with Terraform. Built as the flagship project of a 90-day cloud engineering programme.

The system watches an EC2 workload and cleans up idle waste automatically. The network, compute, self-healing loop, and delivery pipeline are defined in code, with account-level resources managed in their own isolated Terraform state.

This README documents the system as it actually stands, verified against live AWS state. Where a piece is still hand-built rather than code, it says so.

## What it does

CloudOps Sentinel runs two independent loops over one workload.

**Heal loop (proactive).** An EventBridge rule fires on an hourly schedule and invokes a Lambda that scans every instance in the account, then stops any instance that is both idle and tagged for auto-stop. This is the "clean up idle waste" path, and it is deployed entirely with Terraform. The stop permission is gated two independent ways: an IAM condition on the auto-stop tag, and a check in the function code. Even if the code had a bug, the permission would refuse to stop an untagged box. Two walls, not one.

**Alert loop (reactive).** A CloudWatch alarm watches CPU on the workload. When CPU crosses its threshold, the alarm publishes to an SNS topic, and an event-driven Lambda catches the message and logs the alarm payload. This is the "something is wrong, record it" path.

## Architecture

```
Heal path (proactive, fully code-first)
  EventBridge rule  -->  Healer Lambda  -->  stops idle, tagged instances
   (hourly)              (reads CPU, checks tag)

Alert path (reactive)
  CloudWatch alarm  -->  SNS topic  -->  Catcher Lambda
   (CPU > threshold)     (channel)       (logs the alarm)

Foundation: network module (VPC, subnets, SG), compute module (EC2),
OIDC-federated CI/CD with a manual approval gate, least-privilege IAM.
```

## The heal loop, in detail

The heal loop is the piece rebuilt code-first for this capstone, and it is worth reading closely because it demonstrates least-privilege design end to end.

The healer's IAM role permits exactly what the function needs, nothing more:

- `ec2:DescribeInstances`, unconditioned. The function must see every instance to decide which are idle, so this read is open. Conditioning a read would deny the lookup the function depends on.
- `cloudwatch:GetMetricStatistics`, unconditioned. The function reads each instance's average CPU to judge whether it is idle. This is a read, so it is open.
- `ec2:StopInstances`, gated by the condition that the instance carries the auto-stop tag set to true. This is the permission wall. The role physically cannot stop an untagged instance.
- CloudWatch Logs write, scoped to the account and region.

The function code adds the second wall: it only acts on instances whose auto-stop tag equals true and whose average CPU is below the idle threshold. An untagged instance returns no tag value, which is not equal to true, so it is skipped. Only instances explicitly tagged for auto-stop are eligible.

Reads open, mutations gated. The daily-driver workload is deliberately left untagged, which is what keeps the healer's hands off it.

## Infrastructure-as-code status

Verified against live AWS state. A component is marked Terraform only if it is tracked in Terraform state with a clean plan.

| Component | Status |
| --- | --- |
| Network module (VPC, subnets, SG) | Terraform |
| Compute module (EC2) | Terraform |
| OIDC role and gated CI/CD pipeline | Terraform |
| SNS topic | Terraform (imported) |
| Catcher Lambda execution role | Terraform (imported) |
| Healer role, function, EventBridge rule, target, invoke permission | Terraform (code-first) |
| Catcher Lambda function | Hand-built, pending rebuild |
| CloudWatch alarm | Hand-built, pending rebuild |

The heal loop is fully code-first: a single terraform apply in the account-level state stands up the role, function, schedule, target, and permission from nothing, no import. The alert loop is partly under code (topic and role imported) and partly still hand-built (function and alarm), which are the next rebuild targets.

## Honest boundaries

Two things stated plainly, because credential honesty is a project principle.

**Deployment scope.** "Deployed entirely with Terraform" applies to the heal loop and the foundation. The alert loop's function and alarm are still hand-built.

**CI/CD scope.** The pipeline provides Continuous Delivery with a manual approval gate for the dev and prod environments. Account-level resources, including both Sentinel loops, live in an isolated global state that is applied directly rather than through the pipeline. Bringing global under the same gated pipeline is a known follow-up.

## How to demo it

The heal loop can be demonstrated end to end:

1. Start an instance tagged for auto-stop and leave it idle.
2. The EventBridge rule invokes the healer on its hourly schedule (or invoke the function directly to see it immediately).
3. The healer reads the instance's CPU, confirms it is idle and tagged, and stops it, while leaving untagged instances running.
4. Confirm from the instance state and the healer's CloudWatch logs.

A clean terraform plan against the account-level state shows no drift: the code matches live reality exactly.

## Known follow-ups

- Rebuild the catcher function code-first and pin it to a provider-supported runtime.
- Rebuild the CloudWatch alarm as code.
- Bring the global (account-level) state under the gated CI/CD pipeline so account-level changes get the same plan-review-gate discipline as dev and prod.

## Repository

Source: github.com/legendonthisone/cloud-engineering-portfolio

- Terraform: projects/aws/terraform-infra (network and compute modules, environments/dev, environments/prod, environments/global)
- Lambda sources: projects/aws/lambda/sns-alarm-catcher and projects/aws/lambda/auto-stop

## Credentials

Delivery is Continuous Delivery with a manual approval gate, not automated deployment. Certification status: AWS SAA-C03 in progress, HashiCorp Terraform Associate planned. No certification is claimed that is not earned.
