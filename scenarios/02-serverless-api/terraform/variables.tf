variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "us-east-1"
}

variable "function_name" {
  type        = string
  description = "Name of the Lambda function"
  default     = "serverless-api-hello"
}

variable "lambda_runtime" {
  type        = string
  description = "Lambda runtime (python3.9, python3.11, etc.)"
  default     = "python3.11"
}

variable "lambda_timeout" {
  type        = number
  description = "Lambda function timeout in seconds"
  default     = 30
}

variable "lambda_memory" {
  type        = number
  description = "Lambda function memory in MB"
  default     = 128
}

variable "api_stage" {
  type        = string
  description = "API Gateway stage name (dev, staging, prod)"
  default     = "dev"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "dev"
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention in days"
  default     = 7
}

variable "use_localstack" {
  type        = bool
  description = "Use LocalStack endpoint for local testing"
  default     = true
}
