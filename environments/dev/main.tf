# ---------------------------------------------------------------------------
# environments/dev
#
# Root module: wires modules/vpc, modules/security-groups, modules/iam and
# modules/ec2 together into a single dev environment.
# ---------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  az_count             = var.az_count
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  tags                 = local.common_tags
}

module "security_groups" {
  source = "../../modules/security-groups"

  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  allowed_ssh_cidr        = var.allowed_ssh_cidr
  allow_public_http_https = var.allow_public_http_https
  database_port           = var.database_port
  tags                    = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  environment               = var.environment
  ecr_repository_arns       = var.ecr_repository_arns
  cloudwatch_log_group_arns = var.cloudwatch_log_group_arns
  tags                      = local.common_tags
}

module "ec2" {
  source = "../../modules/ec2"

  environment               = var.environment
  instance_type             = var.instance_type
  subnet_id                 = module.vpc.public_subnet_ids[0]
  security_group_ids        = [module.security_groups.app_security_group_id]
  key_name                  = var.key_name
  associate_public_ip       = true
  iam_instance_profile_name = module.iam.instance_profile_name
  root_volume_size          = var.root_volume_size
  tags                      = local.common_tags
}
