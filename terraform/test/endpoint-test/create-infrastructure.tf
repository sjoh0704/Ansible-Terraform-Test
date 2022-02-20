data "aws_availability_zones" "available" {}


module "aws-vpc" {
  source = "../../modules/vpc"

  aws_cluster_name         = var.aws_cluster_name
  aws_vpc_cidr_block       = var.aws_vpc_cidr_block
  aws_avail_zones          = data.aws_availability_zones.available.names
  aws_cidr_subnets_public  = var.aws_cidr_subnets_public
  aws_cidr_subnets_private = var.aws_cidr_subnets_private
  default_tags             = var.default_tags
  use_nat_gateway          = var.use_nat_gateway
  
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.distro.id
  instance_type               = var.aws_bastion_size
  count                       = var.aws_bastion_num
  associate_public_ip_address = true
  subnet_id                   = element(module.aws-vpc.aws_subnet_ids_public, count.index)

  vpc_security_group_ids = module.aws-vpc.aws_security_group

  key_name = var.AWS_SSH_KEY_NAME

  tags = merge(var.default_tags, tomap({
    Name    = "${var.aws_cluster_name}-bastion-${count.index}"
  }))
}

resource "aws_instance" "private-ec2-server" {
  ami                         = data.aws_ami.distro.id
  instance_type               = var.aws_ec2_size
  count                       = var.aws_ec2_num
  associate_public_ip_address = false
  subnet_id                   = element(module.aws-vpc.aws_subnet_ids_private, count.index)

  vpc_security_group_ids = module.aws-vpc.aws_security_group

  key_name = var.AWS_SSH_KEY_NAME

  tags = merge(var.default_tags, tomap({
    Name    = "${var.aws_cluster_name}-private-ec2-${count.index}"
  }))
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.aws-vpc.aws_vpc_id
  service_name = "com.amazonaws.us-west-1.s3"

  tags = merge(var.default_tags, tomap({
    Name    = "${var.aws_cluster_name}-vpc-endpoint"
  }))
}

resource "aws_vpc_endpoint_route_table_association" "private_route_endpoint_association" {
  count = length(var.aws_cidr_subnets_private)
  route_table_id  = element(module.aws-vpc.aws_route_table_private, count.index)
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}