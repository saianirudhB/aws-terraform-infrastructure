# ---------------------------------------------------------------------------
# modules/security-groups
#
# Two security groups:
#   - app   : the web/app tier. Inbound 80/443 (public, demo-only, or scoped
#             to an ALB security group) + inbound 22 from a restricted CIDR.
#   - db    : the database tier. Inbound on database_port ONLY from the app
#             security group - nothing else, no public ingress at all.
# ---------------------------------------------------------------------------

locals {
  module_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "security-groups"
    }
  )
}

# ---------------------------------------------------------------------------
# App / web tier security group
# ---------------------------------------------------------------------------

resource "aws_security_group" "app" {
  name        = "${var.environment}-app-sg"
  description = "App/web tier: inbound HTTP/HTTPS and restricted SSH, outbound unrestricted."
  vpc_id      = var.vpc_id

  tags = merge(
    local.module_tags,
    { Name = "${var.environment}-app-sg" }
  )
}

# NOTE (demo-only): opening 80/443 to 0.0.0.0/0 is only acceptable because
# there is no load balancer in front of this instance in this portfolio
# project. In a real deployment, set allow_public_http_https = false and
# pass alb_security_group_id so only the ALB can reach the instance.
resource "aws_vpc_security_group_ingress_rule" "app_http_public" {
  count = var.allow_public_http_https ? 1 : 0

  security_group_id = aws_security_group.app.id
  description       = "DEMO-ONLY: HTTP from anywhere (no ALB in front of this instance)."
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_https_public" {
  count = var.allow_public_http_https ? 1 : 0

  security_group_id = aws_security_group.app.id
  description       = "DEMO-ONLY: HTTPS from anywhere (no ALB in front of this instance)."
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_http_from_alb" {
  count = var.alb_security_group_id != null ? 1 : 0

  security_group_id            = aws_security_group.app.id
  description                  = "HTTP from the upstream ALB only."
  referenced_security_group_id = var.alb_security_group_id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_https_from_alb" {
  count = var.alb_security_group_id != null ? 1 : 0

  security_group_id            = aws_security_group.app.id
  description                  = "HTTPS from the upstream ALB only."
  referenced_security_group_id = var.alb_security_group_id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_ssh" {
  security_group_id = aws_security_group.app.id
  description       = "SSH restricted to allowed_ssh_cidr."
  cidr_ipv4         = var.allowed_ssh_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_all_outbound" {
  security_group_id = aws_security_group.app.id
  description       = "Allow all outbound traffic."
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---------------------------------------------------------------------------
# Database tier security group
# ---------------------------------------------------------------------------

resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Database tier: inbound only from the app tier security group, no public ingress."
  vpc_id      = var.vpc_id

  tags = merge(
    local.module_tags,
    { Name = "${var.environment}-db-sg" }
  )
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "Database port reachable only from the app tier security group."
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.database_port
  to_port                      = var.database_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "db_all_outbound" {
  security_group_id = aws_security_group.db.id
  description       = "Allow all outbound traffic (e.g. patching)."
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
