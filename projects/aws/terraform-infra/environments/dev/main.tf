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
  source = "../../modules/network"

  project_name   = var.project_name
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets
  ingress_rules  = var.ingress_rules
}

# --- EC2 Instance ---
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = module.network.subnet_ids["us-east-1a"]
  vpc_security_group_ids = [module.network.security_group_id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Deployed by Terraform via a modular, multi-AZ pipeline -Legend</h1>" > /usr/share/nginx/html/index.html
  EOF

  tags = {
    Name    = "${var.project_name}-web-server"
    Project = var.project_name
  }
}
