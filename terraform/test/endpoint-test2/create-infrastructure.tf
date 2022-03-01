data "aws_availability_zones" "available" {}

// nlb-test: endpoint service
module "aws-vpc" {
  source = "../../modules/vpc"

  aws_cluster_name         = var.aws_cluster_name
  aws_vpc_cidr_block       = var.aws_vpc_cidr_block
  aws_avail_zones          = data.aws_availability_zones.available.names
  aws_cidr_subnets_public  = var.aws_cidr_subnets_public
  aws_cidr_subnets_private = var.aws_cidr_subnets_private
  default_tags             = var.default_tags
}

resource "aws_instance" "private-ec2" {
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
  instance_id         =  aws_instance.private-ec2.*.id 
  
}



// endpoint-test: endpoint
module "ep-test-vpc" {
  source = "../../modules/vpc"

  aws_cluster_name         = "ep-test"
  aws_vpc_cidr_block       = "20.0.0.0/16"
  aws_avail_zones          = data.aws_availability_zones.available.names
  aws_cidr_subnets_public  = ["20.0.1.0/24"]
  aws_cidr_subnets_private = ["20.0.2.0/24"]
  default_tags             = {}
}

resource "aws_instance" "ep-test-bastion" {
  ami                         = data.aws_ami.distro.id
  instance_type               = var.aws_bastion_size
  count                       = 1
  associate_public_ip_address = true
  subnet_id                   = element(module.ep-test-vpc.aws_subnet_ids_public, count.index)
  vpc_security_group_ids      = module.ep-test-vpc.aws_security_group
  key_name                    = var.AWS_SSH_KEY_NAME
  tags = merge(var.default_tags, tomap({
    Name    = "ep-test-bastion-${count.index}"
  }))
}


resource "aws_instance" "ep-test-private" {
  ami                         = data.aws_ami.distro.id
  instance_type               = var.aws_bastion_size
  associate_public_ip_address = false
  count                       = 1
  subnet_id                   = element(module.ep-test-vpc.aws_subnet_ids_private, count.index)
  vpc_security_group_ids      = module.ep-test-vpc.aws_security_group
  key_name                    = var.AWS_SSH_KEY_NAME
  tags = merge(var.default_tags, tomap({
    Name    = "ep-test-private-ec2-${count.index}"
  }))
}

// vpc endpoint 
// create vpc endpoint service + vpc endpoint

resource "aws_vpc_endpoint_service" "nlb-endpoint-service" {
  acceptance_required        = false
  network_load_balancer_arns = [module.aws-elb.aws_lb_arn]
}


resource "aws_vpc_endpoint" "ep-test-vpc-endpoint" {
  vpc_id            = module.ep-test-vpc.aws_vpc_id
  service_name      = aws_vpc_endpoint_service.nlb-endpoint-service.service_name
  vpc_endpoint_type = aws_vpc_endpoint_service.nlb-endpoint-service.service_type
  security_group_ids = module.ep-test-vpc.aws_security_group
  subnet_ids          = module.ep-test-vpc.aws_subnet_ids_private
  private_dns_enabled = false
}
