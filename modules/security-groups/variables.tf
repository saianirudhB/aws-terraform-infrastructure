variable "environment" {
  description = "Environment name (e.g. dev, staging, prod). Used for resource naming/tagging."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC the security groups will be created in."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH (port 22) into the app/web tier. Scope this to a known office/VPN/bastion CIDR - never leave it as 0.0.0.0/0 outside of a throwaway demo."
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "allowed_ssh_cidr must be a valid CIDR block, e.g. 203.0.113.0/24."
  }
}

variable "allow_public_http_https" {
  description = "If true, open ports 80/443 on the app/web tier to 0.0.0.0/0. This is demo-only convenience so the instance is reachable without a load balancer; in a real deployment, scope this to an ALB's security group instead via alb_security_group_id and set this to false."
  type        = bool
  default     = true
}

variable "alb_security_group_id" {
  description = "Security group ID of an upstream ALB. When set, ports 80/443 are opened only to this security group instead of (or in addition to) the public internet. Leave null to skip this rule."
  type        = string
  default     = null
}

variable "app_port" {
  description = "Application port on the app/web tier that the database tier does NOT need to reach; kept here for documentation of the tier's own listening port if different from 80/443. Not used to open an inbound rule by default."
  type        = number
  default     = 8080
}

variable "database_port" {
  description = "Port the database tier listens on (default 5432 for PostgreSQL). Only the app/web security group is allowed to reach this port."
  type        = number
  default     = 5432
}

variable "tags" {
  description = "Additional resource tags to merge into every resource created by this module."
  type        = map(string)
  default     = {}
}
