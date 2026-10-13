variable "environment" {
  description = "Environment name (e.g. dev, staging, prod). Used for resource naming/tagging."
  type        = string
}

variable "ecr_repository_arns" {
  description = "List of ECR repository ARNs the EC2 role is allowed to pull images from. Leave empty to allow pulling from any repository in the account (still read-only) via a wildcard resource - prefer scoping this down in real environments."
  type        = list(string)
  default     = []
}

variable "cloudwatch_log_group_arns" {
  description = "List of CloudWatch Logs log group ARNs the EC2 role is allowed to write to. Leave empty to allow writing to any log group under this account's standard log group naming (still scoped to logs:PutLogEvents/CreateLogStream, not full CloudWatch access)."
  type        = list(string)
  default     = []
}

variable "additional_managed_policy_arns" {
  description = "Extra AWS managed (or customer managed) policy ARNs to attach to the role, on top of the least-privilege ECR pull + CloudWatch Logs write policy this module always creates. Use sparingly - prefer extending the inline policy instead where possible."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional resource tags to merge into every resource created by this module."
  type        = map(string)
  default     = {}
}
