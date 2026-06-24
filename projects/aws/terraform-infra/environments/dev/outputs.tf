output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "subnet_ids" {
  description = "IDs of the public subnets, keyed by Availability Zone"
  value       = module.network.subnet_ids
}

output "security_group_id" {
  description = "ID of the web security group"
  value       = module.network.security_group_id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.compute.instance_id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.compute.public_ip
}

output "website_url" {
  description = "URL to access the web server"
  value       = module.compute.website_url
}
