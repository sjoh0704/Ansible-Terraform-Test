#Global Vars
aws_cluster_name = "endpoint-test"

#VPC Vars
aws_vpc_cidr_block       = "10.0.0.0/16"
aws_cidr_subnets_public  = ["10.0.1.0/24"]
aws_cidr_subnets_private = ["10.0.2.0/24"]
use_nat_gateway = false

#EC2 Source/Dest Check
aws_src_dest_check = false

default_tags = {
}

#The number of EC2 and EC2 size
aws_ec2_size = "t2.micro"
aws_ec2_num = 1

# The number of bastion and bastion size
aws_bastion_size = "t2.micro"
aws_bastion_num = 1
