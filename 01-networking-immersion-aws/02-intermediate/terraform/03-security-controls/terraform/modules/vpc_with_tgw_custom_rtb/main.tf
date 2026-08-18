# This module uses AWS Transit Gateway to connect your Amazon Virtual Private Clouds (VPCs) and on-premises networks through a central hub.
locals {
  aggregated_cidr = var.agregated_route
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_ec2_transit_gateway" "vpc_abc_tgw" {
  description       = "This is a transit gateway that connects VPCs A, B, and C"
  dns_support       = "enable"
  multicast_support = "enable"
  vpn_ecmp_support  = "enable"
  amazon_side_asn   = 64512
  # Note that this values was not added in the previous exercise
  # And it is what stops default association and route propagation to the default route table
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "vpc_abc_tgw"
  }
}

# creating a custom default tgw rtb for vpc a, b, and c
resource "aws_ec2_transit_gateway_route_table" "vpc_abc_default_tgw_rtb" {
  transit_gateway_id = aws_ec2_transit_gateway.vpc_abc_tgw.id
  tags = {
    Name = "vpc_abc_default_tgw-rtb"
  }
}

# creating another TGW rtb for vpc a, b, and c
resource "aws_ec2_transit_gateway_route_table" "shared_vpc_abc_tgw_rtb" {
  transit_gateway_id = aws_ec2_transit_gateway.vpc_abc_tgw.id
  tags = {
    Name = "shared_vpc_abc_tgw-rtb"
  }
}

# loops through all the vpcs and creates a tgw attachment for each vpc using the tgw_subnets of each vpc.
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_abc_tgw_attachment" {
  for_each           = var.all_vpc_details
  subnet_ids         = each.value.private_tgw_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.vpc_abc_tgw.id
  vpc_id             = each.value.vpc_id
}

### NEW CODE ADDED TO CREATE A CUSTOM TGW ROUTE TABLE AND ADD ROUTES TO EACH VPC PRIVATE SUBNETS FOR INTERCONNECTIVITY ###
# vpc_a tgw attachments is associated with the shared tgw rtb only
# vpc_b and vpc_c tgw attachments are associated with the custom default tgw rtb only. 
# This is to ensure that vpc_a can communicate with vpc_b and vpc_c, but vpc_b and vpc_c cannot communicate with each other.

# adding attachments to the tgw rtb for vpc_a, vpc_b, and vpc_c

# adding vpc_a tgw attachment to shared tgw rtb only becuase vpc_a is the only vpc that can communicate with vpc_b and vpc_c
resource "aws_ec2_transit_gateway_route_table_association" "vpc_abc_tgw_rtb_association" {
  for_each                       = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[1] && k != var.vpcs_to_pair_with[2] }
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_abc_tgw_attachment[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_vpc_abc_tgw_rtb.id
}

# adding vpc_b and vpc_c tgw attachments to custom default tgw rtb only
resource "aws_ec2_transit_gateway_route_table_association" "vpc_abc_default_tgw_rtb_association" {
  for_each                       = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[0] }
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_abc_tgw_attachment[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc_abc_default_tgw_rtb.id
}

##now adding propagation of routes to the tgw rtb for vpc_a, vpc_b, and vpc_c

# propagating vpc_a tgw attachment to default tgw rtb only for interconnectivity and discoverablity by vpc_b and vpc_c
resource "aws_ec2_transit_gateway_route_table_propagation" "vpc_a_tgw_rtb_propagation" {
  for_each                       = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[1] && k != var.vpcs_to_pair_with[2] }
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_abc_tgw_attachment[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc_abc_default_tgw_rtb.id
}

# now propagating vpc_b and vpc_c tgw attachments to shared tgw rtb only for interconnectivity and discoverablity by vpc_a
resource "aws_ec2_transit_gateway_route_table_propagation" "vpc_b_c_tgw_rtb_propagation" {
  for_each                       = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[0] }
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_abc_tgw_attachment[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared_vpc_abc_tgw_rtb.id
}

# uses aggregate route - a summary of routes to reduce number of routes we create
# 10.0.0.0/8 encompasses routes for VPC B and VPC C privates routes. 
# Read up about it.
# Alternatively, you could create a route for each VPC private subnets in VPC B and C

#adding aggregate route to vpc_a private rtbs for interconnectivity with vpc_b and vpc_c
resource "aws_route" "vpc_a_private_1_rtb_to_aggregated_route" {
  route_table_id         = var.all_vpc_details[var.vpcs_to_pair_with[0]].private_rtb[0]
  destination_cidr_block = local.aggregated_cidr[0]
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_abc_tgw.id

}
resource "aws_route" "vpc_a_private_2_rtb_to_aggregated_route" {
  route_table_id         = var.all_vpc_details[var.vpcs_to_pair_with[0]].private_rtb[1]
  destination_cidr_block = local.aggregated_cidr[0]
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_abc_tgw.id

}

# adding aggregate route to vpc_b private rtbs for interconnectivity with vpc_a and vpc_c
resource "aws_route" "vpc_b_private_1_rtb_to_aggregated_route" {
  route_table_id         = var.all_vpc_details[var.vpcs_to_pair_with[1]].private_rtb[0]
  destination_cidr_block = local.aggregated_cidr[0]
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_abc_tgw.id
}
resource "aws_route" "vpc_b_private_2_rtb_to_aggregated_route" {
  route_table_id         = var.all_vpc_details[var.vpcs_to_pair_with[1]].private_rtb[1]
  destination_cidr_block = local.aggregated_cidr[0]
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_abc_tgw.id
}

# adding aggregate route to vpc_c private rtbs for interconnectivity with vpc_a and vpc_b
resource "aws_route" "vpc_c_private_1_rtb_to_aggregated_route" {
  route_table_id         = var.all_vpc_details[var.vpcs_to_pair_with[2]].private_rtb[0]
  destination_cidr_block = local.aggregated_cidr[0]
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_abc_tgw.id
}
resource "aws_route" "vpc_c_private_2_rtb_to_aggregated_route" {
  route_table_id         = var.all_vpc_details[var.vpcs_to_pair_with[2]].private_rtb[1]
  destination_cidr_block = local.aggregated_cidr[0]
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_abc_tgw.id
}

