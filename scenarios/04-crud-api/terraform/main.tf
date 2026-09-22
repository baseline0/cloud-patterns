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
  region = var.aws_region
  skip_credentials_validation = true
  skip_requesting_account_id  = true

  endpoints {
    dynamodb    = var.use_localstack ? "http://localhost:4566" : null
    lambda      = var.use_localstack ? "http://localhost:4566" : null
    apigateway  = var.use_localstack ? "http://localhost:4566" : null
    iam         = var.use_localstack ? "http://localhost:4566" : null
    logs        = var.use_localstack ? "http://localhost:4566" : null
  }
}

# DynamoDB Table for todos
resource "aws_dynamodb_table" "todos" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "N"
  }

  global_secondary_index {
    name            = "created_at-index"
    hash_key        = "created_at"
    projection_type = "ALL"
  }

  tags = {
    Name = var.table_name
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy: Lambda → DynamoDB
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "${var.function_name}-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Scan",
        "dynamodb:Query"
      ]
      Resource = aws_dynamodb_table.todos.arn
    }]
  })
}

# IAM Policy: Lambda → CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "crud_api" {
  filename         = "${path.module}/../lambda/function.zip"
  function_name    = var.function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "handler.lambda_handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory

  source_code_hash = filebase64sha256("${path.module}/../lambda/function.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.todos.name
    }
  }

  tags = {
    Name = var.function_name
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_logs]
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.crud_api.function_name}"
  retention_in_days = var.log_retention_days
}

# API Gateway
resource "aws_apigatewayv2_api" "crud_api" {
  name          = "${var.function_name}-api"
  protocol_type = "HTTP"
}

# API Gateway Integration
resource "aws_apigatewayv2_integration" "lambda" {
  api_id             = aws_apigatewayv2_api.crud_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.crud_api.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

# Routes
resource "aws_apigatewayv2_route" "get_todos" {
  api_id    = aws_apigatewayv2_api.crud_api.id
  route_key = "GET /todos"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "get_todo" {
  api_id    = aws_apigatewayv2_api.crud_api.id
  route_key = "GET /todos/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "create_todo" {
  api_id    = aws_apigatewayv2_api.crud_api.id
  route_key = "POST /todos"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "update_todo" {
  api_id    = aws_apigatewayv2_api.crud_api.id
  route_key = "PUT /todos/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "delete_todo" {
  api_id    = aws_apigatewayv2_api.crud_api.id
  route_key = "DELETE /todos/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# API Gateway Stage
resource "aws_apigatewayv2_stage" "stage" {
  api_id            = aws_apigatewayv2_api.crud_api.id
  name              = var.api_stage
  auto_deploy       = true
  protocol_type     = "HTTP"
  route_selection_expression = "$request.method $request.path"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId = "$context.requestId"
      method    = "$context.httpMethod"
      path      = "$context.resourcePath"
      status    = "$context.status"
      latency   = "$context.integration.latency"
    })
  }
}

# API Gateway Log Group
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${var.function_name}"
  retention_in_days = var.log_retention_days
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crud_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.crud_api.execution_arn}/*/*"
}
