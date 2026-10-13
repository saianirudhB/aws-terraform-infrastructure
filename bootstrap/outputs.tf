output "state_bucket_name" {
  description = "Name of the S3 bucket created for Terraform remote state. Use this as `bucket` in environments/dev/backend.hcl."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "lock_table_name" {
  description = "Name of the DynamoDB table created for Terraform state locking. Use this as `dynamodb_table` in environments/dev/backend.hcl."
  value       = aws_dynamodb_table.terraform_locks.name
}
