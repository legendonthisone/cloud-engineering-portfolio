variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "legend-tf"
}

variable "public_subnets" {
  description = "Public subnets to create. Key = Availability Zone, value = CIDR block."
  type        = map(string)
  default = {
    "us-east-1a" = "10.1.1.0/24"
    "us-east-1b" = "10.1.2.0/24"
  }
}
