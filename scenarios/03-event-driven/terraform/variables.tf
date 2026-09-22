variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "bucket_name" {
  type        = string
  default     = "event-driven-uploads-bucket"
  description = "S3 bucket name for uploads"
}

variable "topic_name" {
  type        = string
  default     = "file-uploads-topic"
  description = "SNS topic name"
}

variable "function_name" {
  type        = string
  default     = "file-processor-function"
  description = "Lambda function name"
}

variable "lambda_runtime" {
  type        = string
  default     = "python3.11"
  description = "Lambda runtime"
}

variable "lambda_timeout" {
  type        = number
  default     = 10
  description = "Lambda timeout in seconds"
}

variable "lambda_memory" {
  type        = number
  default     = 128
  description = "Lambda memory in MB"
}

variable "log_retention_days" {
  type        = number
  default     = 7
  description = "CloudWatch log retention in days"
}

variable "use_localstack" {
  type        = bool
  default     = true
  description = "Use LocalStack endpoints"
}
