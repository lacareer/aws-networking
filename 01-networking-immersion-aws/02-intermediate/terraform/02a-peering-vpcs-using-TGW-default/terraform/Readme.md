AWS Transit Gateway connects your Amazon Virtual Private Clouds (VPCs) and on-premises networks through a central hub. This simplifies your network and puts an end to complex peering relationships. It acts as a cloud router – each new connection is only made once.

The best practice for connecting VPCs to Transit Gateway is to use a dedicated /28 subnet in each availability zone 

<!-- This config peers vpc together without using a transit gateway -->
# Changes made the infra
- I have added 2 TGW subnest to VPC A with corresponding Route table and subnet association
- Also added code for a Transit Gateway, its attachment to VPC A, B, and C using the two private TGW subnets of each VPC (one in u-east-1 and the other in us-east-2) for each VPC. 
- The vpc_with_tgw_default module uses default rtb for creating inter-vpc connectivity without creating a custom rtb for TGW

Look at the default TGW aasociation, Propagation, and Routes. As you will see, the Transit Gateway automatically associates newly attached VPCs to the default route table and propagates routes from the VPCs into the Transit Gateway Route Table. This makes it very easy for VPCs to have connectivity to other VPCs.


# vpc_peering module input variable vpcs_to_pair_with is assigned the value of root module input vpc_peering_list variable show below

  vpc_peering_list = {
    "vpcs" = ["vpc_b", "vpc_c"]

  }

# vpc_peering module input variable all_vpc_details is assigned the value of custom_vpc_details output of root module

  vpc_peering_details = {
    "vpc_a" = {
      "private_rtb" = [
        "rtb-0880f0b61057b6ce7",
        "rtb-05475986b4582798c",
      ]
      "private_subnets" = [
        "subnet-0b8ca3b2f52c8ca70",
        "subnet-0dc2492333d6c01e0",
      ]
      "private_tgw_rtb" = []
      "private_tgw_subnet_ids" = []
      "public_subnets" = [
        "subnet-09a5db7b7c0b78a9a",
        "subnet-09edefe3d6e473e73",
      ]
      "vpc_cidr_block" = "10.0.0.0/16"
      "vpc_id" = "vpc-0290081973ee48513"
      "vpc_tags" = tomap({
        "Environment" = "dev"
        "Name" = "vpc_a"
        "Owner" = "Network Team"
        "company" = "chukky.com"
      })
    }
    "vpc_b" = {
      "private_rtb" = [
        "rtb-06fd8672f0789ac22",
        "rtb-0e847a993100d0426",
      ]
      "private_subnets" = [
        "subnet-053c6747c56b2eb27",
        "subnet-0394c60f0878a4cae",
      ]
      "private_tgw_rtb" = tolist([
        "rtb-0a5000f3c1e1bbc35",
      ])
      "private_tgw_subnet_ids" = tolist([
        "subnet-08e86d7bec758d965",
        "subnet-058f19b7ef5842a4e",
      ])
      "public_subnets" = [
        "subnet-0e9f5e00f4c92ccc5",
        "subnet-09ab5856af87063ca",
      ]
      "vpc_cidr_block" = "10.1.0.0/16"
      "vpc_id" = "vpc-0a453f6febbc806d1"
      "vpc_tags" = tomap({
        "Environment" = "dev"
        "Name" = "vpc_b"
        "Owner" = "Network Team"
        "company" = "chukky.com"
      })
    }
    "vpc_c" = {
      "private_rtb" = [
        "rtb-0096fa0ab19ba48eb",
        "rtb-0b677969449c08bcc",
      ]
      "private_subnets" = [
        "subnet-0dd8551f5d88b112f",
        "subnet-00890f413b61fd0a1",
      ]
      "private_tgw_rtb" = tolist([
        "rtb-0efaa750a529cdb0e",
      ])
      "private_tgw_subnet_ids" = tolist([
        "subnet-08858264527abf8e9",
        "subnet-0459ac3cd5d13fdae",
      ])
      "public_subnets" = [
        "subnet-0674bf7d6bc6ea45d",
        "subnet-0578c2e2512059212",
      ]
      "vpc_cidr_block" = "10.2.0.0/16"
      "vpc_id" = "vpc-0940b798737fd6d58"
      "vpc_tags" = tomap({
        "Environment" = "dev"
        "Name" = "vpc_c"
        "Owner" = "Network Team"
        "company" = "chukky.com"
      })
    }
  }



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
   

