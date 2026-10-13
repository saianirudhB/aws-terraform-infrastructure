variable "environment" {
  description = "Environment name (e.g. dev, staging, prod). Used as a prefix/tag for all resources created by this module."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to spread public/private subnets across. Must be <= the number of AZs available in the chosen region and <= the number of CIDR blocks supplied in public_subnet_cidrs/private_subnet_cidrs."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 1 && var.az_count <= 6
    error_message = "az_count must be between 1 and 6."
  }
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets, one per AZ. Must have at least az_count entries."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets, one per AZ. Must have at least az_count entries."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "enable_nat_gateway" {
  description = "Whether to provision NAT Gateway(s) so private subnets can reach the internet outbound (e.g. for package/docker pulls). NAT Gateways are the single biggest line item in this project's AWS bill - disable for a cheaper, egress-less private tier."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "If true, provision exactly one NAT Gateway (in the first public subnet) shared by all private subnets, instead of one NAT Gateway per AZ. Cheaper, but removes AZ-level fault isolation for outbound traffic. Recommended for dev/demo environments."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional resource tags to merge into every resource created by this module (on top of the module's own Name/Environment tags)."
  type        = map(string)
  default     = {}
}
