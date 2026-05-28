terraform {
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

# Call the module for app data bucket — versioning ON
module "app_data_bucket" {
  source = "./modules/s3_bucket"

  bucket_name       = var.app_data_bucket_name
  environment       = var.environment
  purpose           = "app-data"
  enable_versioning = true
}

# Call the module for app logs bucket — versioning OFF
module "app_logs_bucket" {
  source = "./modules/s3_bucket"

  bucket_name       = var.app_logs_bucket_name
  environment       = var.environment
  purpose           = "logging"
  enable_versioning = false
}
