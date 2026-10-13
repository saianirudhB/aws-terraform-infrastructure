variable "environment" {
  description = "Environment name (e.g. dev, staging, prod). Used for resource naming/tagging."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type, e.g. t3.micro."
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance into (typically a public subnet output from modules/vpc for this demo; use a private subnet in a real deployment and reach it via an ALB/bastion)."
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the instance's network interface, e.g. the app security group ID from modules/security-groups."
  type        = list(string)
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access. Set to null to launch without a key pair (recommended if you only access the instance via SSM Session Manager)."
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Whether to assign a public IP address to the instance. Only relevant when subnet_id is a public subnet."
  type        = bool
  default     = true
}

variable "iam_instance_profile_name" {
  description = "Name of an IAM instance profile to attach, e.g. the instance_profile_name output from modules/iam. This module deliberately does NOT create its own IAM role/policies - that responsibility belongs to modules/iam so role permissions stay centrally reviewable; pass its output through here."
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Size (in GiB) of the root EBS volume."
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "EBS volume type for the root volume."
  type        = string
  default     = "gp3"
}

variable "enable_detailed_monitoring" {
  description = "Whether to enable detailed (1-minute) CloudWatch monitoring. Adds a small per-instance cost."
  type        = bool
  default     = false
}

variable "user_data" {
  description = "Custom user_data script. Defaults to null, in which case the module's built-in user_data (Amazon Linux 2023 Docker install, see user_data.sh.tpl) is used. Pass your own to override it entirely."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional resource tags to merge into every resource created by this module."
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# NOTE on scaling to an Auto Scaling Group
#
# This module intentionally launches a single aws_instance to keep the
# portfolio example easy to read end to end. To extend it to an ASG instead:
#   1. Replace the aws_instance resource below with an aws_launch_template
#      using the same ami_id/instance_type/iam_instance_profile/user_data/
#      root volume settings.
#   2. Add an aws_autoscaling_group referencing that launch template, with
#      vpc_zone_identifier = a list of subnet_ids (plural) instead of the
#      single subnet_id variable here, plus min/max/desired_capacity
#      variables.
#   3. Drop the public_ip/private_ip outputs (an ASG's instances are not
#      known at plan time) in favor of exposing the ASG name/ARN, and front
#      the group with an ALB target group attachment.
# ---------------------------------------------------------------------------
