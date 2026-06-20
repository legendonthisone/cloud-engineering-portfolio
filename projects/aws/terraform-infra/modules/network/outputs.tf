output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "Map of public subnet IDs keyed by Availability Zone."
  value       = { for az, subnet in aws_subnet.public : az => subnet.id }
}

output "security_group_id" {
  description = "ID of the web security group."
  value       = aws_security_group.web.id
}
