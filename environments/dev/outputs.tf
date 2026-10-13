output "vpc_id" {
  description = "ID of the dev VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the dev public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the dev private subnets."
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "IDs of the dev NAT Gateway(s)."
  value       = module.vpc.nat_gateway_ids
}

output "app_security_group_id" {
  description = "ID of the app/web tier security group."
  value       = module.security_groups.app_security_group_id
}

output "db_security_group_id" {
  description = "ID of the database tier security group."
  value       = module.security_groups.db_security_group_id
}

output "ec2_role_arn" {
  description = "ARN of the IAM role attached to the app instance."
  value       = module.iam.role_arn
}

output "ec2_instance_profile_name" {
  description = "Name of the IAM instance profile attached to the app instance."
  value       = module.iam.instance_profile_name
}

output "app_instance_id" {
  description = "ID of the app EC2 instance."
  value       = module.ec2.instance_id
}

output "app_instance_public_ip" {
  description = "Public IP address of the app EC2 instance."
  value       = module.ec2.public_ip
}

output "app_instance_private_ip" {
  description = "Private IP address of the app EC2 instance."
  value       = module.ec2.private_ip
}
