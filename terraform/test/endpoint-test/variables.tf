variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key"
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Key"
}

variable "AWS_SSH_KEY_NAME" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "AWS_DEFAULT_REGION" {
  description = "AWS Region"
}

//General Cluster Settings

variable "aws_cluster_name" {
  description = "Name of AWS Cluster"
}

//AWS VPC Variables

variable "aws_vpc_cidr_block" {
  description = "CIDR Block for VPC"
}

variable "aws_cidr_subnets_public" {
  description = "CIDR Blocks for public subnets in Availability Zones"
  type        = list(string)
}

variable "aws_cidr_subnets_private" {
  description = "CIDR Blocks for private subnets in Availability Zones"
  type        = list(string)
}

variable "use_nat_gateway" {
  description = "check if use nat gateway"
  type        = bool
  default     = true  
}

/*
* EC2 Source/Dest Check
*
*/
variable "aws_src_dest_check" {
  description   = "Instance source/destination check of Kubernetes Cluster"
  type          = bool
  default	= true
}


variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
}

variable "aws_ec2_size" {
  type        = string
}

variable "aws_ec2_num" {
  type        = number
}

variable "aws_bastion_size" {
  type        = string
}

variable "aws_bastion_num" {
  type        = number
}


# EC2 image
data "aws_ami" "distro" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220207.1-x86_64-gp2"]
  }

   owners =["137112412989"]
}


