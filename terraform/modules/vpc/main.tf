resource "aws_vpc" "vpc" {
  cidr_block = var.aws_vpc_cidr_block

  #DNS Related Entries
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.default_tags, tomap({
    Name = "${var.aws_cluster_name}-vpc"
  }))
}

resource "aws_eip" "nat-eip" {
  count = var.use_nat_gateway ? length(var.aws_cidr_subnets_public):0 
  vpc   = true
}

resource "aws_internet_gateway" "vpc-internetgw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.default_tags, tomap({
    Name = "${var.aws_cluster_name}-igw"
  }))
}

resource "aws_subnet" "vpc-subnets-public" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.aws_cidr_subnets_public)
  availability_zone = element(var.aws_avail_zones, count.index % length(var.aws_avail_zones))
  cidr_block        = element(var.aws_cidr_subnets_public, count.index)

  tags = merge(var.default_tags, tomap({
    Name = "${var.aws_cluster_name}-${element(var.aws_avail_zones, count.index)}-public"
  }))
}

resource "aws_nat_gateway" "nat-gateway" {
  count         = var.use_nat_gateway ? length(var.aws_cidr_subnets_public):0
  allocation_id = element(aws_eip.nat-eip.*.id, count.index)
  subnet_id     = element(aws_subnet.vpc-subnets-public.*.id, count.index)
}

resource "aws_subnet" "vpc-subnets-private" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.aws_cidr_subnets_private)
  availability_zone = element(var.aws_avail_zones, count.index % length(var.aws_avail_zones))
  cidr_block        = element(var.aws_cidr_subnets_private, count.index)

  tags = merge(var.default_tags, tomap({
    Name = "${var.aws_cluster_name}-${element(var.aws_avail_zones, count.index)}-private"
  }))
}


resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc-internetgw.id
  }

  tags = merge(var.default_tags, tomap({
    Name = "${var.aws_cluster_name}-route-table-public"
  }))
}

resource "aws_route_table" "private-route-table" {
  count  = length(var.aws_cidr_subnets_private)
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.default_tags, tomap({
    Name = "${var.aws_cluster_name}-routetable-private-${count.index}"
  }))
}

resource "aws_route" "route_with_nat_gatway" {
  count  = var.use_nat_gateway ? length(var.aws_cidr_subnets_private):0 
  route_table_id =  element(aws_route_table.private-route-table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(aws_nat_gateway.nat-gateway.*.id, count.index) 
}


resource "aws_route_table_association" "public-rt-association" {
  count          = length(var.aws_cidr_subnets_public)
  subnet_id      = element(aws_subnet.vpc-subnets-public.*.id, count.index)
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "private-rt-association" {
  count          = length(var.aws_cidr_subnets_private)
  subnet_id      = element(aws_subnet.vpc-subnets-private.*.id, count.index)
  route_table_id = element(aws_route_table.private-route-table.*.id, count.index)
}

#Kubernetes Security Groups

resource "aws_security_group" "security-group" {
  name   = "${var.aws_cluster_name}-securitygroup"
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.default_tags, tomap({
    Name = "${var.aws_cluster_name}-securitygroup"
  }))
}

resource "aws_security_group_rule" "allow-all-ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = [var.aws_vpc_cidr_block]
  security_group_id = aws_security_group.security-group.id
}

resource "aws_security_group_rule" "allow-all-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security-group.id
}

resource "aws_security_group_rule" "allow-ssh-connections" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security-group.id
}

resource "aws_security_group_rule" "allow-http-connections" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security-group.id
}