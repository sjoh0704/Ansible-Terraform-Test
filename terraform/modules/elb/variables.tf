variable "aws_cluster_name" {
  description = "Name of Cluster"
}

variable "aws_vpc_id" {
  description = "AWS VPC ID"
}

variable "aws_elb_port" {
  description = "listener Port for AWS ELB"
}

variable "aws_tg_port" {
  description = "target group Port for AWS ELB"
}

variable "aws_avail_zones" {
  description = "Availability Zones Used"
  type        = list(string)
}

variable "default_tags" {
  description = "Tags for all resources"
  type        = map(string)
}

variable "aws_elb_internal" {
  description   = "AWS ELB Scheme Internet-facing/Internal"
  type          = bool
  default	= true
}

variable "aws_elb_subnets" {
  description   = "List of subnets to be attached to ELB API"
  type          = list(string)
}

variable "instance_id" {
  type          = list(string)
}