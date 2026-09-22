terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  # For local testing with LocalStack/Floci
  skip_credentials_validation = true
  skip_requesting_account_id  = true

  endpoints {
    s3      = var.use_localstack ? "http://localhost:4566" : null
    sns     = var.use_localstack ? "http://localhost:4566" : null
    lambda  = var.use_localstack ? "http://localhost:4566" : null
    logs    = var.use_localstack ? "http://localhost:4566" : null
    iam     = var.use_localstack ? "http://localhost:4566" : null
  }
}

# S3 Bucket for uploads
resource "aws_s3_bucket" "uploads" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

# SNS Topic for file upload notifications
resource "aws_sns_topic" "notifications" {
  name = var.topic_name

  tags = {
    Name = var.topic_name
  }
}

# S3 Bucket Notification (triggers SNS on file upload)
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.uploads.id

  topic {
    topic_arn     = aws_sns_topic.notifications.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "uploads/"
  }

  depends_on = [aws_sns_topic_policy.allow_s3]
}

# SNS Topic Policy (allow S3 to publish)
resource "aws_sns_topic_policy" "allow_s3" {
  arn = aws_sns_topic.notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.notifications.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "000000000000"
          }
        }
      }
    ]
  })
}

# IAM Role for Lambda execution
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda to write logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "processor" {
  filename         = "${path.module}/../lambda/lambda.zip"
  function_name    = var.function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "handler.lambda_handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory

  source_code_hash = filebase64sha256("${path.module}/../lambda/lambda.zip")

  tags = {
    Name = var.function_name
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_logs]
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.processor.function_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.function_name}-logs"
  }
}

# SNS Subscription (Lambda subscribes to topic)
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.processor.arn
}

# Lambda Permission (allow SNS to invoke)
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.notifications.arn
}
