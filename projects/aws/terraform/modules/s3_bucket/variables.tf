variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
}

variable "purpose" {
  description = "Purpose of the bucket for tagging"
  type        = string
}

variable "enable_versioning" {
  description = "Whether to enable versioning on the bucket"
  type        = bool
  default     = false
}
