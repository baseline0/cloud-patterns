output "api_endpoint" {
  value       = aws_apigatewayv2_stage.stage.invoke_url
  description = "API Gateway endpoint URL"
}

output "function_name" {
  value       = aws_lambda_function.api.function_name
  description = "Lambda function name"
}

output "function_arn" {
  value       = aws_lambda_function.api.arn
  description = "Lambda function ARN"
}

output "api_id" {
  value       = aws_apigatewayv2_api.api.id
  description = "API Gateway API ID"
}

output "lambda_log_group" {
  value       = aws_cloudwatch_log_group.lambda_logs.name
  description = "CloudWatch log group for Lambda"
}

output "api_log_group" {
  value       = aws_cloudwatch_log_group.api_logs.name
  description = "CloudWatch log group for API Gateway"
}

output "test_commands" {
  value = {
    "hello"       = "${aws_apigatewayv2_stage.stage.invoke_url}/hello"
    "hello_name"  = "${aws_apigatewayv2_stage.stage.invoke_url}/hello/World"
    "health"      = "${aws_apigatewayv2_stage.stage.invoke_url}/health"
    "not_found"   = "${aws_apigatewayv2_stage.stage.invoke_url}/nonexistent"
  }
  description = "Test endpoints"
}

output "quick_test" {
  value       = "curl ${aws_apigatewayv2_stage.stage.invoke_url}/hello"
  description = "Quick test command"
}
