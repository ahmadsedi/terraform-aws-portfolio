locals {
  bucket_name = "${var.project_name}-${var.environment}-tfstate"
}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "tf_state" {
  bucket = local.bucket_name

  tags = merge(var.tags, {
    Name = local.bucket_name
  })
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "tf_lock" {
  name         = "${var.project_name}-${var.environment}-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags
}