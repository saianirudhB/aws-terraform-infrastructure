output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP address of the instance (empty string if associate_public_ip = false or none was assigned)."
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Private IP address of the instance."
  value       = aws_instance.this.private_ip
}

output "ami_id" {
  description = "ID of the AMI used to launch the instance (resolved latest Amazon Linux 2023)."
  value       = data.aws_ami.amazon_linux_2023.id
}
