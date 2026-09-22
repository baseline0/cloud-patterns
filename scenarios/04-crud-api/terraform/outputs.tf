output "api_endpoint" {
  value       = aws_apigatewayv2_stage.stage.invoke_url
  description = "API Gateway endpoint"
}

output "table_name" {
  value       = aws_dynamodb_table.todos.name
  description = "DynamoDB table name"
}

output "function_name" {
  value       = aws_lambda_function.crud_api.function_name
  description = "Lambda function name"
}

output "test_commands" {
  value = {
    "list_todos"     = "curl ${aws_apigatewayv2_stage.stage.invoke_url}/todos"
    "create_todo"    = "curl -X POST ${aws_apigatewayv2_stage.stage.invoke_url}/todos -H 'Content-Type: application/json' -d '{\"title\":\"My Task\"}'"
    "get_todo"       = "curl ${aws_apigatewayv2_stage.stage.invoke_url}/todos/todo-123"
    "update_todo"    = "curl -X PUT ${aws_apigatewayv2_stage.stage.invoke_url}/todos/todo-123 -H 'Content-Type: application/json' -d '{\"completed\":true}'"
    "delete_todo"    = "curl -X DELETE ${aws_apigatewayv2_stage.stage.invoke_url}/todos/todo-123"
  }
  description = "CRUD test commands"
}
