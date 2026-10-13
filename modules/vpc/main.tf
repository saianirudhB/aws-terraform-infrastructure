# ---------------------------------------------------------------------------
# modules/vpc
#
# Provisions a VPC with:
#   - one public subnet per AZ, routed to an Internet Gateway
#   - one private subnet per AZ, routed to a NAT Gateway (or no egress if
#     enable_nat_gateway = false)
#   - either one shared NAT Gateway (single_nat_gateway = true, default) or
#     one NAT Gateway per AZ for full fault isolation
# ---------------------------------------------------------------------------

locals {
  module_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "vpc"
    }
  )

  az_count          = var.az_count
  azs               = slice(data.aws_availability_zones.available.names, 0, local.az_count)
  nat_gateway_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : local.az_count) : 0
}

data "aws_availability_zones" "available" {
  state = "available"
}

# ---------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.module_tags,
    { Name = "${var.environment}-vpc" }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.module_tags,
    { Name = "${var.environment}-igw" }
  )
}

# ---------------------------------------------------------------------------
# Public subnets
# ---------------------------------------------------------------------------

resource "aws_subnet" "public" {
  count = local.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.module_tags,
    {
      Name = "${var.environment}-public-${local.azs[count.index]}"
      Tier = "public"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.module_tags,
    { Name = "${var.environment}-public-rt" }
  )
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = local.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------------------------
# Private subnets
# ---------------------------------------------------------------------------

resource "aws_subnet" "private" {
  count = local.az_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    local.module_tags,
    {
      Name = "${var.environment}-private-${local.azs[count.index]}"
      Tier = "private"
    }
  )
}

# ---------------------------------------------------------------------------
# NAT Gateway(s) - outbound internet access for private subnets
# ---------------------------------------------------------------------------

resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  domain = "vpc"

  tags = merge(
    local.module_tags,
    { Name = "${var.environment}-nat-eip-${count.index}" }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    local.module_tags,
    { Name = "${var.environment}-nat-${count.index}" }
  )

  depends_on = [aws_internet_gateway.this]
}

# One private route table per AZ so each can point at its own (or the
# shared) NAT Gateway independently.
resource "aws_route_table" "private" {
  count = local.az_count

  vpc_id = aws_vpc.this.id

  tags = merge(
    local.module_tags,
    { Name = "${var.environment}-private-rt-${local.azs[count.index]}" }
  )
}

resource "aws_route" "private_nat_access" {
  count = var.enable_nat_gateway ? local.az_count : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index].id
}

resource "aws_route_table_association" "private" {
  count = local.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
