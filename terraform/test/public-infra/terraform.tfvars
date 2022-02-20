#Global Vars
aws_cluster_name = "my-test"

#VPC Vars
aws_vpc_cidr_block       = "10.0.0.0/16"
aws_cidr_subnets_public  = ["10.0.1.0/24", "10.0.2.0/24"]

#EC2 Source/Dest Check
aws_src_dest_check      = false

default_tags = {
}


#The number of EC2 and EC2 size
aws_ec2_size = "t3.micro"
aws_ec2_num = 2


inventory_file = "../../../ansible/inventory/hosts"
