variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "function_name" {
  type    = string
  default = "crud-api-function"
}

variable "table_name" {
  type    = string
  default = "todos"
}

variable "lambda_runtime" {
  type    = string
  default = "python3.11"
}

variable "lambda_timeout" {
  type    = number
  default = 10
}

variable "lambda_memory" {
  type    = number
  default = 128
}

variable "api_stage" {
  type    = string
  default = "dev"
}

variable "log_retention_days" {
  type    = number
  default = 7
}

variable "use_localstack" {
  type    = bool
  default = true
}
