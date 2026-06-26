variable "environment" {
  description = "Deployment environment label"
  type        = string
  default     = "practice"
}

terraform {
  backend "s3" {
    bucket       = "legend-tf-state-2026"
    key          = "dev/terraform.tfstate"
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
  region = var.aws_region
}

module "network" {
  source         = "../../modules/network"
  project_name   = var.project_name
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets
  ingress_rules  = var.ingress_rules
}

module "compute" {
  source            = "../../modules/compute"
  subnet_id         = module.network.subnet_ids["us-east-1a"]
  security_group_id = module.network.security_group_id
  instance_type     = var.instance_type
  project_name      = var.project_name
  environment       = var.environment
}
