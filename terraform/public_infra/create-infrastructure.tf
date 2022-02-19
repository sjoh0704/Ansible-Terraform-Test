data "aws_availability_zones" "available" {}


module "aws-vpc" {
  source = "../modules/vpc"

  aws_cluster_name         = var.aws_cluster_name
  aws_vpc_cidr_block       = var.aws_vpc_cidr_block
  aws_avail_zones          = data.aws_availability_zones.available.names
  aws_cidr_subnets_public  = var.aws_cidr_subnets_public
  default_tags             = var.default_tags
}

resource "aws_instance" "public-ec2-server" {
  ami                         = data.aws_ami.distro.id
  instance_type               = var.aws_ec2_size
  count                       = var.aws_ec2_num
  associate_public_ip_address = true
  subnet_id                   = element(module.aws-vpc.aws_subnet_ids_public, count.index)

  vpc_security_group_ids = module.aws-vpc.aws_security_group

  key_name = var.AWS_SSH_KEY_NAME

  tags = merge(var.default_tags, tomap({
    Name    = "${var.aws_cluster_name}-public-ec2-${count.index}"
  }))
}