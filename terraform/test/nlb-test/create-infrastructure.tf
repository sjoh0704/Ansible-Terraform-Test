data "aws_availability_zones" "available" {}


module "aws-vpc" {
  source = "../../modules/vpc"

  aws_cluster_name         = var.aws_cluster_name
  aws_vpc_cidr_block       = var.aws_vpc_cidr_block
  aws_avail_zones          = data.aws_availability_zones.available.names
  aws_cidr_subnets_public  = var.aws_cidr_subnets_public
  aws_cidr_subnets_private = var.aws_cidr_subnets_private
  default_tags             = var.default_tags
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.distro.id
  instance_type               = var.aws_bastion_size
  count                       = var.aws_bastion_num
  associate_public_ip_address = true
  subnet_id                   = element(module.aws-vpc.aws_subnet_ids_public, count.index)
  vpc_security_group_ids      = module.aws-vpc.aws_security_group
  key_name                    = var.AWS_SSH_KEY_NAME
  user_data                   = <<EOF
#! /bin/bash
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
sudo yum install -y httpd
echo $INSTANCE_ID | sudo tee /var/www/html/index.html
sudo service httpd start
EOF
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
  vpc_security_group_ids      = module.aws-vpc.aws_security_group
  key_name                    = var.AWS_SSH_KEY_NAME
  user_data                   = <<EOF
#! /bin/bash
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
sudo yum install -y httpd
echo $INSTANCE_ID | sudo tee /var/www/html/index.html
sudo service httpd start
EOF

  tags = merge(var.default_tags, tomap({
    Name    = "${var.aws_cluster_name}-private-ec2-${count.index}"
  }))
}

module "aws-elb" {
  source = "../../modules/elb"

  aws_cluster_name     = var.aws_cluster_name
  aws_vpc_id           = module.aws-vpc.aws_vpc_id
  aws_avail_zones      = data.aws_availability_zones.available.names
  aws_elb_subnets      = var.aws_elb_internal ? module.aws-vpc.aws_subnet_ids_private : module.aws-vpc.aws_subnet_ids_public
  aws_elb_internal     = var.aws_elb_internal
  aws_elb_port         = var.aws_elb_port
  aws_tg_port          = var.aws_tg_port 
  default_tags         = var.default_tags
  instance_id         =  var.aws_elb_internal ? aws_instance.private-ec2-server.*.id: aws_instance.bastion.*.id 
  
}

