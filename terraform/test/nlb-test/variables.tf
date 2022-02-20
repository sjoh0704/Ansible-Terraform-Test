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
  default     = 1
}


# EC2 image
data "aws_ami" "distro" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL_HA-8.4.0_HVM-20210504-x86_64-2-Hourly2-GP2"]
  }

   owners =["309956199498"]
}


// AWS ELB Settings

variable "aws_elb_port" {
  description = "listener Port for AWS ELB"
}

variable "aws_tg_port" {
  description = "target group Port for AWS ELB"
}

variable "aws_elb_internal" {
  description   = "AWS ELB Scheme Internet-facing/Internal"
  type          = bool
  default	= true
}





