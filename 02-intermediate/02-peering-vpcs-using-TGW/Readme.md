<!-- VPC Fundamentals -->
Amazon Virtual Private Cloud (Amazon VPC) lets you provision a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define. You have complete control over your virtual networking environment, including selection of your own IP address range, creation of subnets, and configuration of route tables and network gateways. You can use both IPv4 and IPv6 in your VPC for secure and easy access to resources and applications.

In this lab, you will learn how to set up a VPC with public and private subnets, connect it to the internet and establish private connections to AWS services.

**Lab Prerequisite**
- Please complete the pre-requisites section in /networking-immersion-ws/Readme.md before continuing this lab.

- In this workshop, we only created one NAT Gateway in AZ1. It is best practice to create a NAT Gateway in each AZ for each subnet that is utilized.

**Meet Prerequisite? Continue...**
- Deploy the CloudFormation template in 02-multiple-vpcs/three-vpc.yaml to create 3 VPCs

- Enter the Stack name 'NetworkingWorkshopMultiVPC'. Update the Parameter 'ParticipantIPAddress'. Leave the other parameter defaults unchanged if you are running in us-east-1 and click Next. If you are running in another region, update the availability zones.


- Now continue with the lab pdf from VPC peering on page 2 of lab docs