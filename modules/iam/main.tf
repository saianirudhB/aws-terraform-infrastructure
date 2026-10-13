# ---------------------------------------------------------------------------
# modules/iam
#
# Least-privilege IAM role + instance profile for EC2 instances that need:
#   - read-only ECR pull access (to run Docker images from a private ECR
#     repository)
#   - CloudWatch Logs write access (to ship application/system logs)
#
# No broad managed policies (e.g. AmazonEC2ContainerRegistryFullAccess or
# CloudWatchFullAccess) are attached - only the specific actions needed.
# ---------------------------------------------------------------------------

locals {
  module_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "iam"
    }
  )

  ecr_resources        = length(var.ecr_repository_arns) > 0 ? var.ecr_repository_arns : ["*"]
  cloudwatch_resources = length(var.cloudwatch_log_group_arns) > 0 ? var.cloudwatch_log_group_arns : ["*"]
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.environment}-ec2-role"
  description        = "Least-privilege role for EC2 instances: ECR pull + CloudWatch Logs write."
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(
    local.module_tags,
    { Name = "${var.environment}-ec2-role" }
  )
}

# ---------------------------------------------------------------------------
# ECR pull (read-only) policy
#
# ecr:GetAuthorizationToken must be called with resource "*" - it is an
# account-level token endpoint, not a per-repository action.
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "ecr_pull" {
  statement {
    sid       = "ECRAuthToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPullImages"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = local.ecr_resources
  }
}

resource "aws_iam_policy" "ecr_pull" {
  name        = "${var.environment}-ecr-pull"
  description = "Read-only ECR image pull access for the EC2 role."
  policy      = data.aws_iam_policy_document.ecr_pull.json

  tags = local.module_tags
}

resource "aws_iam_role_policy_attachment" "ecr_pull" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ecr_pull.arn
}

# ---------------------------------------------------------------------------
# CloudWatch Logs write policy
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "cloudwatch_logs_write" {
  statement {
    sid    = "CloudWatchLogsWrite"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = local.cloudwatch_resources
  }
}

resource "aws_iam_policy" "cloudwatch_logs_write" {
  name        = "${var.environment}-cloudwatch-logs-write"
  description = "Write-only CloudWatch Logs access for the EC2 role."
  policy      = data.aws_iam_policy_document.cloudwatch_logs_write.json

  tags = local.module_tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_write" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.cloudwatch_logs_write.arn
}

# ---------------------------------------------------------------------------
# Optional extra managed policies
# ---------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = toset(var.additional_managed_policy_arns)

  role       = aws_iam_role.ec2.name
  policy_arn = each.value
}

# ---------------------------------------------------------------------------
# Instance profile
# ---------------------------------------------------------------------------

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.environment}-ec2-instance-profile"
  role = aws_iam_role.ec2.name

  tags = merge(
    local.module_tags,
    { Name = "${var.environment}-ec2-instance-profile" }
  )
}
