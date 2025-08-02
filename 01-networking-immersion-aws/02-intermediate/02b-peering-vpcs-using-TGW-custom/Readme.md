***File differences ***
02-peering-vpcs-using-TGW-default/three-vpcs-TGW-1.yaml uses the default TGW table created, when you don't create a custom TGW rtb. The Transit Gateway automatically associates newly attached VPCs to the default route table and propagates routes from the VPCs into the Transit Gateway Route Table. This makes it very easy for VPCs to have connectivity to other VPCs. 

Whereas 03-peering-vpcs-using-TGW-custom/three-vpcs-TGW-2.yaml we do all the connections ourself by creating a custom TGW Route Table, adding association, popagation, and routes to the private subnets including the TGW Subnets

Every other thing is just about the same