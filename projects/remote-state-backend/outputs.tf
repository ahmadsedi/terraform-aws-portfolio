output "bucket_name" {
  value       = aws_s3_bucket.tf_state.bucket
  description = "Terraform state bucket name"
}

output "dynamodb_table" {
  value       = aws_dynamodb_table.tf_lock.name
  description = "DynamoDB table for state locking"
}