variable "aws_region" {
  description = "AWS region to create the state bucket and lock table in. Should match the region used by environments/dev's backend.hcl."
  type        = string
  default     = "eu-west-2"
}

variable "state_bucket_name" {
  description = "Globally-unique name for the S3 bucket that will hold Terraform remote state. Must match the `bucket` value in environments/dev/backend.hcl."
  type        = string
  default     = "my-org-aws-terraform-infrastructure-state"
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking. Must match the `dynamodb_table` value in environments/dev/backend.hcl."
  type        = string
  default     = "my-org-terraform-locks"
}

variable "tags" {
  description = "Tags applied to the bootstrap resources."
  type        = map(string)
  default = {
    Project   = "aws-terraform-infrastructure"
    ManagedBy = "terraform"
    Purpose   = "terraform-remote-state-bootstrap"
  }
}
