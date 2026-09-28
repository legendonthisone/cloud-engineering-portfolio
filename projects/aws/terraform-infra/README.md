# Terraform: Network and Compute Stack

A modular AWS network and web server, deployed per environment, with remote state in S3 and account-level resources kept in their own state.

## Layout

| Path | What it holds |
|---|---|
| `modules/network/` | VPC with DNS enabled, internet gateway, public subnets, public route table and associations, web security group |
| `modules/compute/` | EC2 web server on the latest Amazon Linux 2023 AMI, nginx installed through `user_data` |
| `environments/dev/`, `environments/prod/` | Each sets its own state key and calls both modules. The root passes the network outputs (subnet ID, security group ID) into compute |
| `environments/global/` | Account-level resources in a separate state: the GitHub Actions OIDC role and CloudOps Sentinel |

## What the modules do

- **Subnets from a map.** `public_subnets` maps an Availability Zone to a CIDR block, and `for_each` builds one subnet per entry. Two AZs by default (`10.1.1.0/24`, `10.1.2.0/24`), and adding a third is one line in a variable.
- **Security group rules from data.** Ingress rules come from a list variable through a `dynamic` block (HTTP and HTTPS by default), so rules change without touching the module.
- **No hard-coded AMI.** A data source looks up the newest Amazon Linux 2023 image at plan time.
- **Consistent tags.** Every resource carries `Project`, and the instance also carries `Env`.

## Remote state

- One S3 bucket, a separate key per environment (`dev/`, `prod/`, `global/`).
- Versioned, encrypted and blocked from public access.
- Native S3 locking with `use_lockfile = true`, so no DynamoDB lock table is needed.

**Why global has its own state:** a `terraform destroy` in dev or prod can never touch the IAM role that both environments, and the pipeline, depend on.

## The pipeline role (`environments/global/iam.tf`)

- **Trust:** only GitHub's OIDC provider, only this repository, and only tokens minted for AWS STS.
- **Permissions:** EC2 reads (`Describe*`) are open because `terraform plan` needs them. EC2 writes are listed one by one and region-locked to us-east-1, so leaked credentials cannot build or destroy anything in another region.

## Usage

```
cd environments/dev
terraform init      # configure the S3 backend
terraform plan      # preview
terraform apply     # build
terraform destroy   # tear down
```

Changes to dev go through the GitHub Actions pipeline: plan on every pull request, apply after merge behind a manual approval gate. The global state is applied directly.

## Concepts demonstrated

- Module composition with inputs and outputs
- `for_each` over a map and `dynamic` blocks
- Data source lookups instead of hard-coded IDs
- Per-environment state isolation with native locking
- A least-privilege CI role federated through OIDC
