# Terraform — Real AWS Infrastructure Deployment

Deploys a complete, production-pattern AWS network and web server entirely
in code, with remote state stored in S3 using native locking.

## What This Builds

| Resource | Description |
|----------|-------------|
| VPC | Isolated network (10.1.0.0/16) |
| Internet Gateway | Public internet access for the VPC |
| Public Subnet | 10.1.1.0/24, auto-assigns public IPs |
| Route Table + Association | Routes 0.0.0.0/0 to the IGW |
| Security Group | Allows inbound HTTP (80) and HTTPS (443) |
| EC2 Instance | Amazon Linux 2023, t2.micro, runs nginx via user_data |

All seven resources are created in dependency order automatically — Terraform
reads resource references (e.g. vpc_id = aws_vpc.main.id) to build its
dependency graph.

## Remote State Backend

State is stored remotely in S3 rather than on local disk:

- Bucket: versioned, AES256-encrypted, public access blocked
- Locking: native S3 locking via use_lockfile = true (no DynamoDB required —
  that approach is deprecated as of Terraform 1.11+)
- Lock file: a .tflock object is created at the start of each operation and
  deleted automatically when it completes

## File Structure

| File | Purpose | Committed? |
|------|---------|-----------|
| main.tf | Provider, backend, all resources, AMI data source | Yes |
| variables.tf | Input variable declarations | Yes |
| outputs.tf | Output values (IPs, IDs, URL) | Yes |
| .terraform.lock.hcl | Provider version lock | Yes |
| terraform.tfstate | Current state — sensitive | Never (gitignored) |
| .terraform/ | Downloaded provider plugins | Never (gitignored) |

## Usage

    terraform init       # download providers, configure S3 backend
    terraform plan       # preview the 7 resources
    terraform apply      # build the infrastructure
    terraform destroy    # tear it all down

## Key Concepts Demonstrated

- Infrastructure as Code: a full network stack defined declaratively
- Implicit dependency resolution and parallel resource creation
- Dynamic AMI lookup via a data source instead of a hardcoded ID
- EC2 bootstrapping with user_data
- Remote state with native S3 locking — the current production-standard pattern
