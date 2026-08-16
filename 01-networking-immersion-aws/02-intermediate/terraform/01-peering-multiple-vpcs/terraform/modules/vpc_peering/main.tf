# Note that the vpc peering done in this module uses the private subnets of each VPC to establish the peering connection. 
# A better way is to use the tgw_subnets of each VPC to create a transit gateway and attach the VPCs to it. 
# This is done in the next exercise.

# This module creates peering between A<=>B, A<=>C, and B<=>A, and C<=>A. 
# it uses the count value of vpcs_to_pair_with to determine how many private peering connections to create per vpc
# Note that there is not peering between B<=>C and C<=>B. 

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# pairing vpcs
##Bcs vpc is birectional, vpc_b and vpc_c will also have vpc_a in their list of vpcs to pair with. 
##This is to ensure that the peering connection is established in both directions.
##So, the peering connection from vpc_a to vpc_b and vpc_c will automatically handle the reverse peering.
resource "aws_vpc_peering_connection" "peering" {
  count       = var.vpcs_to_pair_with != null && length(var.vpcs_to_pair_with) > 0 ? length(var.vpcs_to_pair_with) : 0
  peer_vpc_id = var.all_vpc_details[var.vpcs_to_pair_with[count.index]].vpc_id
  vpc_id      = var.all_vpc_details["vpc_a"].vpc_id
  auto_accept = false
  tags = {
    Side = "Requester"
    Name = "${var.vpc_name[0]}_private_subnet_peering_to_${var.vpcs_to_pair_with[count.index]}"
  }
}

# Accepter's side of the connection to auto accept the peering request.
resource "aws_vpc_peering_connection_accepter" "peer" {
  count                     = var.vpcs_to_pair_with != null && length(var.vpcs_to_pair_with) > 0 ? length(var.vpcs_to_pair_with) : 0
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
  auto_accept               = true

  tags = {
    Side = "Accepter"
    Name = "${var.vpc_name[0]}_peering_connection_to_${var.vpcs_to_pair_with[count.index]}"
  }
}

# add vpc_b cidr range to each private subnet route tables vpc_a to enable routing between the peered vpcs.
#1. A<=>B

# vpc_a_private_route_table-1 add cidr range for vpc_b and vpc_c  to 1st private subnet using the respective vpc peering connection ids.
resource "aws_route" "peering_vpc_a_private_subnet_1_without_tgw_1" {
  # count                     = var.vpcs_to_pair_with != null && length(var.vpcs_to_pair_with) > 0 ? length(var.vpcs_to_pair_with) : 0
  route_table_id            = var.all_vpc_details["vpc_a"].private_rtb[0]
  destination_cidr_block    = var.all_vpc_details["vpc_b"].vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id #1st peering id
}

resource "aws_route" "peering_vpc_a_private_subnet_1_without_tgw_2" {
  # count                     = var.vpcs_to_pair_with != null && length(var.vpcs_to_pair_with) > 0 ? length(var.vpcs_to_pair_with) : 0
  route_table_id            = var.all_vpc_details["vpc_a"].private_rtb[0]
  destination_cidr_block    = var.all_vpc_details["vpc_c"].vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[1].id #2nd peering id
}

# vpc_a_private_route_table-2
resource "aws_route" "peering_vpc_a_private_subnet_2_without_tgw_1" {
  # count                     = var.vpcs_to_pair_with != null && length(var.vpcs_to_pair_with) > 0 ? length(var.vpcs_to_pair_with) : 0
  route_table_id            = var.all_vpc_details["vpc_a"].private_rtb[1]
  destination_cidr_block    = var.all_vpc_details["vpc_b"].vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id #1st peering id
}

resource "aws_route" "peering_vpc_a_private_subnet_2_without_tgw_2" {
  # count                     = var.vpcs_to_pair_with != null && length(var.vpcs_to_pair_with) > 0 ? length(var.vpcs_to_pair_with) : 0
  route_table_id            = var.all_vpc_details["vpc_a"].private_rtb[1]
  destination_cidr_block    = var.all_vpc_details["vpc_c"].vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[1].id #2nd peering id
}

#B<=>A 
# vpc_b_private_route_table-1
resource "aws_route" "peering_vpc_b_private_subnet_1_without_tgw_1" {
  # count                     = var.vpcs_to_pair_with != null && length(var.vpcs_to_pair_with) > 0 ? length(var.vpcs_to_pair_with) : 0
  route_table_id            = var.all_vpc_details["vpc_b"].private_rtb[0]
  destination_cidr_block    = var.all_vpc_details["vpc_a"].vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id #1st peering id
}
resource "aws_route" "peering_vpc_b_private_subnet_1_without_tgw_2" {
  # count                     = var.vpcs_to_pair_with != null && length(var.vpcs_to_pair_with) > 0 ? length(var.vpcs_to_pair_with) : 0
  route_table_id            = var.all_vpc_details["vpc_b"].private_rtb[1]
  destination_cidr_block    = var.all_vpc_details["vpc_a"].vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id #1st peering id
}

#C<=>A.
## vpc_c_private_route_table-1
resource "aws_route" "peering_vpc_c_private_subnet_1_without_tgw_1" {
  route_table_id            = var.all_vpc_details["vpc_c"].private_rtb[0]
  destination_cidr_block    = var.all_vpc_details["vpc_a"].vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[1].id #2nd peering id
}

resource "aws_route" "peering_vpc_c_private_subnet_1_without_tgw_2" {
  route_table_id            = var.all_vpc_details["vpc_c"].private_rtb[1]
  destination_cidr_block    = var.all_vpc_details["vpc_a"].vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[1].id #2nd peering id
}

# YOU CAN ADD PEERING CONNECTIONS FOR B<=>C AND C<=>B. BY ADD ING THE BELOW CODE. 
#BUT IT IS NOT NEEDED AS THE PEERING CONNECTION IS ALREADY ESTABLISHED FROM VPC_A TO VPC_B AND VPC_C.
# FIRST YOU HAVE TO CREATE A NEW VPC PEERING CONNECTION ID FOR B<=>C AND C<=>B. THEN YOU HAVE TO ADD THE ROUTES FOR B<=>C AND C<=>B.
# BECAUSE THE EXISTING IDS ARE FOR A<=>B AND A<=>C. SO YOU HAVE TO CREATE NEW VPC PEERING CONNECTION ID FOR B<=>C AND C<=>B. 


