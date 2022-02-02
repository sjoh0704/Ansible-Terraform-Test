output "aws_vpc_id" {
  value = aws_vpc.vpc.id
}

# output "aws_subnet_ids_private" {
#   value = aws_subnet.cluster-vpc-subnets-private.*.id
# }

output "aws_subnet_ids_public" {
  value = aws_subnet.vpc-subnets-public.*.id
}

output "aws_security_group" {
  value = aws_security_group.security-group.*.id
}

output "default_tags" {
  value = var.default_tags
}

output "aws_route_table_private" {
  value = aws_route_table.public-route-table.*.id
}