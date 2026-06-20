variable "project_name" {
  description = "Name prefix for all network resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnets" {
  description = "Public subnets to create. Key = Availability Zone, value = CIDR block."
  type        = map(string)
}

variable "ingress_rules" {
  description = "Inbound rules for the web security group."
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}
