output "bucket_name" {
  value       = aws_s3_bucket.website.id
  description = "Name of the S3 bucket"
}

output "bucket_arn" {
  value       = aws_s3_bucket.website.arn
  description = "ARN of the S3 bucket"
}

output "website_endpoint" {
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
  description = "Website endpoint URL (for local/non-DNS access)"
}

output "bucket_regional_domain_name" {
  value       = aws_s3_bucket.website.bucket_regional_domain_name
  description = "Regional domain name of the bucket"
}

output "access_instructions" {
  value = var.use_localstack ? "http://localhost:4566/${var.bucket_name}/index.html" : "https://${aws_s3_bucket.website.bucket_regional_domain_name}/index.html"
  description = "How to access the website"
}
