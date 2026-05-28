variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name — used in resource naming and tags"
  type        = string
  default     = "learning"
}

variable "app_data_bucket_name" {
  description = "Name of the app data S3 bucket"
  type        = string
  default     = "legend-terraform-app-data-2026"
}

variable "app_logs_bucket_name" {
  description = "Name of the app logs S3 bucket"
  type        = string
  default     = "legend-terraform-app-logs-2026"
}
