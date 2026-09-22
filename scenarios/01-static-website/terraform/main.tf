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

  # For local testing with LocalStack/Floci
  skip_credentials_validation = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = var.use_localstack ? "http://localhost:4566" : null
  }
}

# S3 bucket for static website
resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

# Block all public access by default (we'll selectively enable)
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy to allow public read access
resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PublicReadGetObject"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website]
}

# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }

  depends_on = [aws_s3_bucket_public_access_block.website]
}

# Upload index.html
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  source       = "${path.module}/../app/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/../app/index.html")

  tags = {
    Name = "index.html"
  }
}

# Upload style.css
resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.website.id
  key          = "style.css"
  source       = "${path.module}/../app/style.css"
  content_type = "text/css"
  etag         = filemd5("${path.module}/../app/style.css")

  tags = {
    Name = "style.css"
  }
}

# Upload 404.html for error handling
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.website.id
  key          = "404.html"
  source       = "${path.module}/../app/404.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/../app/404.html")

  tags = {
    Name = "404.html"
  }
}
