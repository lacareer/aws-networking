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


You can go to the AWS console and examine the two rtbs to understand why vpc_a can reach vpc_b and vpc_c, each of vpc_b and vpc_c can reach vpc_a but vpc_b and vpc_c cannot reach each other

<!-- Here is my summary looking at the console and the 2 RTBs -->

# share_tgw route table tabs
1. Association: associated with only vpc_a tgw attachment that points to vpc_a id
2. Propagation: propagates to both vpc_b and vpc_c tgw attachments that points to their respective vpcs 
   Essentially, vpc_b and vpc_c saying we will like to talk to vpc_a and agreed to its request in default rtb item 2, making themselves discoverable by them
3. Routes: contains route to cidrs of vpc_b and vpc_c as 10.1.0.0/16 and 10.2.0.0/16 respectively (the above intention adds the route of those vpcs to the rtb)

# default tgw route table tabs
1. Association: associated with both vpc_b and vpc_c tgw attachments that points to their respective vpcs
2. Propagation: propagates to only both vpc_a tgw attachments that points to vpc_a id 
   Essentially, vpc_a had asked/requested to speak to speak to all vpc in this rtb by progating to it to be dicoverable and the response is item 2 of the shared_tgw rtb
3. Routes: contains route to only vpc_a cidr of 10.0.0.0/16