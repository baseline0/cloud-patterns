output "bucket_name" {
  value       = aws_s3_bucket.uploads.id
  description = "S3 bucket name"
}

output "topic_arn" {
  value       = aws_sns_topic.notifications.arn
  description = "SNS topic ARN"
}

output "function_arn" {
  value       = aws_lambda_function.processor.arn
  description = "Lambda function ARN"
}

output "log_group" {
  value       = aws_cloudwatch_log_group.lambda_logs.name
  description = "CloudWatch log group"
}

output "test_commands" {
  value = {
    "upload_test_file"  = "aws --endpoint-url=http://localhost:4566 s3 cp test.txt s3://${aws_s3_bucket.uploads.id}/uploads/test.txt"
    "upload_image_file" = "aws --endpoint-url=http://localhost:4566 s3 cp image.jpg s3://${aws_s3_bucket.uploads.id}/uploads/image.jpg"
    "view_logs"         = "aws --endpoint-url=http://localhost:4566 logs tail ${aws_cloudwatch_log_group.lambda_logs.name} --follow"
    "list_bucket"       = "aws --endpoint-url=http://localhost:4566 s3 ls s3://${aws_s3_bucket.uploads.id}/uploads/"
  }
  description = "Test commands"
}
