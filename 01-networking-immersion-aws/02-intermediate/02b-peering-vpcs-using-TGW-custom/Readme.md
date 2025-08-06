***File differences ***
02-peering-vpcs-using-TGW-default/three-vpcs-TGW-1.yaml uses the default TGW table created, when you don't create a custom TGW rtb. The Transit Gateway automatically associates newly attached VPCs to the default route table and propagates routes from the VPCs into the Transit Gateway Route Table. This makes it very easy for VPCs to have connectivity to other VPCs. 

Whereas 03-peering-vpcs-using-TGW-custom/01-three-vpcs-TGW.yaml we do all the connections ourself by creating a custom TGW Route Table, adding association, popagation, and routes to the private subnets including the TGW Subnets

02-actual-lab-solution.yaml is the actual solution from AWS  which works as my custom configuration in 03-peering-vpcs-using-TGW-custom/01-three-vpcs-TGW.yaml but most likely a better solution. Below is the way the VPC A  is shared with B/C. This creates interconnectivity: A => B, A => C, B => A, C => A, and no connectivity betwen B and C. See TGW configuration to achieve this:

***Default RTB                                TransitGatewayRouteTableSharedServices***
==========================                    ===============================
VPC B attachment                              VPC A attachment

VPC C attachment
==========================                    ===============================


***Created Propagations***
======================================================================
VPC B attachment propagated to TransitGatewayRouteTableSharedServices

VPC C attachment propagated to TransitGatewayRouteTableSharedServices

VPC A attachment propagated to Default RTB 

======================================================================

Every other thing is just about the same with my custom solution in 01-three-vpcs-TGW.yaml