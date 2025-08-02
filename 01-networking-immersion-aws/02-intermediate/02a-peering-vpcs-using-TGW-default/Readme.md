***File differences ***
02-peering-vpcs-using-TGW-default/three-vpcs-TGW-1.yaml uses the default TGW table created, when you don't create a custom TGW rtb. The Transit Gateway automatically associates newly attached VPCs to the default route table and propagates routes from the VPCs into the Transit Gateway Route Table. This makes it very easy for VPCs to have connectivity to other VPCs. 

Whereas 03-peering-vpcs-using-TGW-custom/three-vpcs-TGW-2.yaml we do all the connections ourself by creating a custom TGW Route Table, adding association, popagation, and routes to the private subnets including the TGW Subnets

Every other thing is just about the same

<!-- VPC Fundamentals -->
Amazon Virtual Private Cloud (Amazon VPC) lets you provision a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define. You have complete control over your virtual networking environment, including selection of your own IP address range, creation of subnets, and configuration of route tables and network gateways. You can use both IPv4 and IPv6 in your VPC for secure and easy access to resources and applications.

In this lab, you will learn how to set up a VPC with public and private subnets, connect it to the internet and establish private connections to AWS services.

***Lab Prerequisite***
- Please complete the pre-requisites section in /networking-immersion-ws/Readme.md before continuing this lab.

- In this workshop, we only created one NAT Gateway in AZ1. It is best practice to create a NAT Gateway in each AZ for each subnet that is utilized.

***Additions to templates***
- I have added 2 subnest to VPC A with corresponding Route table and subnet association

- Also added code for a Transit Gateway, attachment to VPC A, B, and C using the two private TGW subnets(one in u-east-1 and the other in us-east-2) for each VPC. 

- And 

  1. TGW RTB, Association and Propagations (Best solution)✔️. OR the below (may no be best practice)

  2. Also, I have added the Routes to TGW in each VPC Private Route Tables(like we did in the previous lab with VPC peering) with provides interconnectivity between all three VPC's. Remove the route for any VPC you don't want to have interconnectivity (a better solution is in the 02-intermediate/02-peering-vpcs-using-TGW/three-vpcs-TGW-2.yaml which uses TGW route tables). To make it similar  to the VPC peering lab you can comment out the codes for 'AddTGWPrivateRouteBC' and 'AddTGWPrivateRouteCB'

***Meet Prerequisite? Continue...***

This stack will create 3 VPCs each with two public subnets and two private subnets, a Transit Gateway to provide private connectivity between the VPCs, as well as EC2 instances in the VPCs.
Wait for the stack to be created before proceeding. This can take 3-5 minutes. Verify that the status in CloudFormation Console show as CREATE_COMPLETE, indicating successful creation of the stack.

- Deploy the CloudFormation template in 02-intermediate/02-peering-vpcs-using-TGW/three-vpcs-TGW-1.yaml to create 3 VPCs

- Enter the Stack name 'NetworkingWorkshopMultiVPC'. Update the Parameter 'ParticipantIPAddress'. Leave the other parameter defaults unchanged if you are running in us-east-1 and click Next. If you are running in another region, update the availability zones.


***Testing Connections***

- Connections from VPC A --> VPC B and VPC A --> VPC C
  From private server EC2 Instance, in VPC A, running the below should return a successful ping:

    ping 10.1.1.100 -c 5 
    ping 10.2.1.100 -c 5

- Connections from VPC B --> VPC C and VPC B --> VPC A
  From private server EC2 Instance, in VPC B, running the below should return a successful ping:

    ping 10.2.1.100 -c 5
    ping 10.0.1.100 -c 5 

- Connections from VPC C --> VPC B and VPC C --> VPC A
  From private server EC2 Instance, in VPC B, running the below should return a successful ping:

    ping 10.1.1.100 -c 5
    ping 10.0.1.100 -c 5 

- Now continue to the testing section of lab pdf page 2 about TGW Route Tables