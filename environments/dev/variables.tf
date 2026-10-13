variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment name. Used as a prefix/tag on every resource in this root module."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name, used in the common tag set applied to every resource."
  type        = string
  default     = "aws-terraform-infrastructure"
}

variable "owner" {
  description = "Owner tag applied to every resource (e.g. a team name or email)."
  type        = string
  default     = "platform-team"
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the dev VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to spread subnets across."
  type        = number
  default     = 2
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per AZ."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets, one per AZ."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "enable_nat_gateway" {
  description = "Whether to provision NAT Gateway(s) for private subnet egress. This is the single biggest recurring cost in this project - see the README's cost note."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one shared NAT Gateway instead of one per AZ. Recommended for dev to control cost."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Security
# ---------------------------------------------------------------------------

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the app instance. Set this to your office/VPN CIDR, not 0.0.0.0/0."
  type        = string
}

variable "allow_public_http_https" {
  description = "Whether to open 80/443 on the app security group to the public internet (demo-only, since there is no ALB in this project). Set false and wire up alb_security_group_id in a real deployment."
  type        = bool
  default     = true
}

variable "database_port" {
  description = "Port the database tier listens on."
  type        = number
  default     = 5432
}

# ---------------------------------------------------------------------------
# Compute
# ---------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type for the app instance."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH access. Set to null to launch without one (use SSM Session Manager instead)."
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Root EBS volume size (GiB) for the app instance."
  type        = number
  default     = 20
}

# ---------------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------------

variable "ecr_repository_arns" {
  description = "ECR repository ARNs the app instance role may pull images from. Empty list = any repository in the account (read-only)."
  type        = list(string)
  default     = []
}

variable "cloudwatch_log_group_arns" {
  description = "CloudWatch Logs log group ARNs the app instance role may write to. Empty list = any log group in the account (write-only)."
  type        = list(string)
  default     = []
}
