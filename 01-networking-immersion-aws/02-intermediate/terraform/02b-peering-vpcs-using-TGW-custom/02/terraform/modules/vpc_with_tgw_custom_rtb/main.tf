# This module uses AWS Transit Gateway to connect your Amazon Virtual Private Clouds (VPCs) and on-premises networks through a central hub.
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
  # Note that this values was not added in the previous exercise
  # And it is what stops default association and route propagation to the default route table
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "vpc_abc_tgw"
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
# It essentially creates a custom tgw route table, creates tgw attachments for each vpc to each vpc private_tgw_subnet, associate each attachment to the tgw rtb, 
# adds routes/cidr of other vpc's to the each vpc private_tgw_subnet rtb for interconnectivity,
# and then propagates it -that is, packets reaching the tgw will know where to go to reach the other vpcs. 
# This is done for each vpc private_tgw_subnet rtb for interconnectivity.

# TGW rtb for vpc a, b, and c
resource "aws_ec2_transit_gateway_route_table" "vpc_abc_tgw_rtb" {
  transit_gateway_id = aws_ec2_transit_gateway.vpc_abc_tgw.id
  tags = {
    Name = "vpc_abc_tgw-rtb"
  }
}

# adding each vpc attachment for vpc a, b, and c to the tgw rtb
resource "aws_ec2_transit_gateway_route_table_association" "vpc_abc_tgw_rtb_association" {
  for_each                       = aws_ec2_transit_gateway_vpc_attachment.vpc_abc_tgw_attachment
  transit_gateway_attachment_id  = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc_abc_tgw_rtb.id
}

# adds vpc_b and vpc_c cidrs to vpc_a tgw rtb for interconnectivity
resource "aws_route" "vpc_a_tgw_rtb_route_to_vpc_bc" {
  for_each               = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[0] }
  route_table_id         = var.all_vpc_details[var.vpcs_to_pair_with[0]].private_tgw_rtb[0]
  destination_cidr_block = each.value.vpc_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_abc_tgw.id
}

# adds vpc_a and vpc_c cidrs to vpc_b tgw rtb for interconnectivity
# To add vpc_c cidrs to vpc_b private rtbs and create interconnectivity, use the commented loops/conditions instead
resource "aws_route" "vpc_b_tgw_rtb_route_to_vpc_ac" {
  # for_each               = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[1] }
  for_each               = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[1] && k != var.vpcs_to_pair_with[2] }
  route_table_id         = var.all_vpc_details[var.vpcs_to_pair_with[1]].private_tgw_rtb[0]
  destination_cidr_block = each.value.vpc_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_abc_tgw.id
}

# adds vpc_a and vpc_b cidrs to vpc_c tgw rtb for interconnectivity
# To add vpc_b cidrs to vpc_c private routes and create interconnectivity, use the commented loops/conditions instead
resource "aws_route" "vpc_c_tgw_rtb_route_to_vpc_ab" {
  # for_each               = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[2] }
  for_each               = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[1] && k != var.vpcs_to_pair_with[2] }
  route_table_id         = var.all_vpc_details[var.vpcs_to_pair_with[2]].private_tgw_rtb[0]
  destination_cidr_block = each.value.vpc_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_abc_tgw.id
}

# propagates the vpc attachments to the tgw rtb for vpc a, b, and c
resource "aws_ec2_transit_gateway_route_table_propagation" "vpc_abc_tgw_attachment_propagation" {
  for_each                       = aws_ec2_transit_gateway_vpc_attachment.vpc_abc_tgw_attachment
  transit_gateway_attachment_id  = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc_abc_tgw_rtb.id
}
### END OF NEW CODE ADDED TO CREATE A CUSTOM TGW ROUTE TABLE AND ADD ROUTES TO EACH VPC PRIVATE SUBNETS FOR INTERCONNECTIVITY ###


##### ALL CODE BELOW IS SAME AS PREVIOUS EXERCISE #####
# note that the routes must be added to each vpc's private route table of each vpc private subnet for intercconnectivity
# Otherwise, connectivity will fail if added only in one vpc private subnet and not the destination vpc subnet through the transit gateway. 
# The routes are added to the private route tables of each vpc, and the destination cidr block is set to the cidr block of the other vpcs. 
# The transit gateway id is set to the id of the transit gateway used for interconnectivity

## add routes to vpc_b and vpc_c cidrs to vpc_a private routes
resource "aws_route" "vpc_a_private_subnet_1_to_tgw" {
  for_each               = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[0] }
  route_table_id         = var.all_vpc_details[var.vpcs_to_pair_with[0]].private_rtb[0]
  destination_cidr_block = each.value.vpc_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_abc_tgw.id
}

resource "aws_route" "vpc_a_private_subnet_2_to_tgw" {
  for_each               = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[0] }
  route_table_id         = var.all_vpc_details[var.vpcs_to_pair_with[0]].private_rtb[1]
  destination_cidr_block = each.value.vpc_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_abc_tgw.id
}

## add routes to vpc_a cidrs to vpc_b private rtbs
# To add vpc_c cidrs to vpc_b private rtbs and create interconnectivity, use the commented loops/conditions instead
# The architecture requires no connectivity between vpc_b and vpc_c hence why the code is commented
resource "aws_route" "vpc_b_private_subnet_1_to_tgw" {
  # for_each               = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[1] }
  for_each               = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[1] && k != var.vpcs_to_pair_with[2] }
  route_table_id         = var.all_vpc_details[var.vpcs_to_pair_with[1]].private_rtb[0]
  destination_cidr_block = each.value.vpc_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_abc_tgw.id
}

resource "aws_route" "vpc_b_private_subnet_2_to_tgw" {
  # for_each               = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[1] }
  for_each               = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[1] && k != var.vpcs_to_pair_with[2] }
  route_table_id         = var.all_vpc_details[var.vpcs_to_pair_with[1]].private_rtb[1]
  destination_cidr_block = each.value.vpc_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_abc_tgw.id
}

## add routes to vpc_a to vpc_c private rtbs
# To add vpc_b cidrs to vpc_c private routes and create interconnectivity, use the commented loops/conditions instead
# The architecture requires no connectivity between vpc_b and vpc_c hence why the code is commented
resource "aws_route" "vpc_c_private_subnet_1_to_tgw" {
  # for_each               = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[2] }
  for_each               = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[1] && k != var.vpcs_to_pair_with[2] }
  route_table_id         = var.all_vpc_details[var.vpcs_to_pair_with[2]].private_rtb[0]
  destination_cidr_block = each.value.vpc_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_abc_tgw.id
}

resource "aws_route" "vpc_c_private_subnet_2_to_tgw" {
  # for_each               = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[2] }
  for_each               = { for k, v in var.all_vpc_details : k => v if k != var.vpcs_to_pair_with[1] && k != var.vpcs_to_pair_with[2] }
  route_table_id         = var.all_vpc_details[var.vpcs_to_pair_with[2]].private_rtb[1]
  destination_cidr_block = each.value.vpc_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.vpc_abc_tgw.id
}

