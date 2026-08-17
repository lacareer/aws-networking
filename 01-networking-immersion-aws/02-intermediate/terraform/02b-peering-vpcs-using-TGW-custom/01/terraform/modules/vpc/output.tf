output "custom_vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_tags" {
  value = local.vpc_tags
}

output "custom_vpc_details" {
  value = {
    vpc_id                 = aws_vpc.vpc.id
    vpc_cidr_block         = aws_vpc.vpc.cidr_block
    public_subnets         = [for subnet in aws_subnet.public_subnets[*] : subnet.id]
    private_subnets        = [for subnet in aws_subnet.private_subnets[*] : subnet.id]
    private_rtb            = [for route_table in aws_route_table.private_route_table : route_table.id]
    private_tgw_rtb        = length(local.vpc_network_info.tgw_subnets) > 0 ? [for tgw_rtb in aws_route_table.tgw_route_table[*] : tgw_rtb.id] : []
    private_tgw_subnet_ids = length(local.vpc_network_info.tgw_subnets) > 0 ? [for subnet in aws_subnet.tgw_subnets[*] : subnet.id] : []
    vpc_tags               = local.vpc_tags
  }
}

output "custom_vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "custom_vpc_private_subnet_ids" {
  value = [for subnet in aws_subnet.private_subnets[*] : subnet.id] # bcs rersources was created with count and is same with below
}

output "custom_vpc_public_subnet_ids" {
  value = [for subnet in aws_subnet.public_subnets[*] : subnet.id] # bcs rersources was created with count and is same with below
  #   value = aws_subnet.public_subnets[*].id
}

output "custom_vpc_private_route_table_ids" {
  value = [for route_table in aws_route_table.private_route_table : route_table.id] # bcs rersources was created with count and is same with below
  #   value = aws_route_table.private_route_table[*].id
}

output "custom_vpc_public_route_table_ids" {
  value = aws_route_table.public_route_table.id # was not created with count so no need to use splat operator
}

output "custom_vpc_tgw_subnets" {
  value = length(local.vpc_network_info.tgw_subnets) > 0 ? [for subnet in aws_subnet.tgw_subnets[*] : subnet.id] : [] # bcs rersources was created with count and is same with below
  #   value = aws_subnet.tgw_subnets[*].id
}

output "custom_vpc_tgw_rtb" {
  value = length(local.vpc_network_info.tgw_subnets) > 0 ? [for route_table in aws_route_table.tgw_route_table[*] : route_table.id] : [] # bcs rersources was created with count and is same with below
  #   value = aws_route_table.tgw_route_table[*].id
}