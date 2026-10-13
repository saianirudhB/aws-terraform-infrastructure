# ---------------------------------------------------------------------------
# modules/ec2
#
# Launches a single EC2 instance (see the ASG extension note in
# variables.tf) on the latest Amazon Linux 2023 AMI, with Docker installed
# via user_data and an optional IAM instance profile attached.
# ---------------------------------------------------------------------------

locals {
  module_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "ec2"
    }
  )

  user_data = var.user_data != null ? var.user_data : file("${path.module}/templates/user_data.sh.tpl")
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip
  iam_instance_profile        = var.iam_instance_profile_name
  monitoring                  = var.enable_detailed_monitoring
  user_data                   = local.user_data

  # Changing user_data alone (e.g. a new Docker install step) shouldn't be
  # masked by Terraform treating it as drift-only; forces a clean replace.
  user_data_replace_on_change = true

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = true
    delete_on_termination = true

    tags = merge(
      local.module_tags,
      { Name = "${var.environment}-app-root-volume" }
    )
  }

  metadata_options {
    http_tokens   = "required" # enforce IMDSv2
    http_endpoint = "enabled"
  }

  tags = merge(
    local.module_tags,
    { Name = "${var.environment}-app-instance" }
  )
}
