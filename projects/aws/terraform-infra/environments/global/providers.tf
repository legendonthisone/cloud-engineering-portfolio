# Backend and provider config for account-global resources.
# Mirrors environments/dev but with two deliberate differences:
#   1. key = "global/terraform.tfstate" — its own state reel, walled off
#      from dev and prod so a per-environment destroy can never touch the
#      IAM role that both environments depend on.
#   2. region is hard-coded here instead of var.aws_region — global has no
#      need for a configurable region, so one less moving part.

terraform {
  backend "s3" {
    bucket       = "legend-tf-state-2026"
    key          = "global/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
