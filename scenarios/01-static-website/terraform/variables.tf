variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "Name of S3 bucket (must be globally unique)"
  default     = "my-website-bucket-12345"  # Change this to a unique name
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "dev"
}

variable "use_localstack" {
  type        = bool
  description = "Use LocalStack endpoint for local testing"
  default     = true
}
