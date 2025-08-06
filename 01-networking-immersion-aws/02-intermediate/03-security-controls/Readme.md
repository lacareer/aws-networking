 <!-- Network ACLs -->
Network ACLs are stateless access controls you configure at a subnet level, to allow or block a CIDR block on a particular port or range of ports. Network ACL rules are numbered list and evaluated top down, with a DENY ALL at the end. If a rule is matched, subsequent rules are not evaluated.

Both inbound and outbound traffic can be controlled with these rules. By default when you create subnets, they will be attached to the default Network ACL which has an ALLOW ALL rule for both inbound and outbound traffic.

In this section, we will modify the Network ACL associated with the workload subnets in VPC A to only ICMP traffic from VPC B's CIDR; and test connectivity from VPC A to VPC C, and test other connectivity from VPC B to VPC C as well.

*** Deployment ***

- Deploy the cfn template 3vpc-tgw-nacl.yaml in this directory which is similar to three-vpcs-TGW-2 but with added security control

***CHANGES***
1. Relace the logical ID VpcAWorkloadSubnetsNaclInboundRule in the template with the below:

  VpcAWorkloadSubnetsNaclInboundRule:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      NetworkAclId: !Ref VpcAWorkloadSubnetsNacl
      RuleNumber: 100
      Protocol: 1
      Icmp: 
        Code: -1
        Type: -1
      RuleAction: allow
      CidrBlock: 10.1.0.0/16

<!-- Security Group -->
This ensures that traffic is only allowed from VPC B into A and not from VPC C. NACL are a layer of protection by making sure only certain CIDR's are allowed

Security Groups are virtual, stateful firewalls attached to an instance or network interface. Both inbound and outbound rules can be defined to allow specific protocols, ports and source/destination CIDR. A DENY is not possible with security groups.

With Security Groups, all rules are evaluated before a network packet is allowed or blocked, unlike Network ACLs where the rules are evaluated in order of rule number and once a rule matches subsequent rules are not evaluated.

In this exercise, we will modify the security group attached to VPC A Private AZ1 Server to allow only ICMP traffic inbound from VPC C's CIDR only. We will verify that the EC2 instance in VPC C is able to ping the EC2 instance in VPC A, but that the EC2 instance in VPC B is not able to ping the same EC2 instance in VPC A.


***CHANGES***
1. Relace the logical ID VpcAEc2SecGroup in the template with the below:

  VpcAEc2SecGroup:
    Type: AWS::EC2::SecurityGroup
    DependsOn: VpcA
    Properties:
      GroupDescription: Open-up ports for ICMP
      GroupName: "VPC A Security Group"
      VpcId: !Ref VpcA
      SecurityGroupIngress:
        - IpProtocol: icmp
          CidrIp: 10.2.0.0/16
          FromPort: "-1"
          ToPort: "-1"

This allows traffic only from VPC C    


<!-- Endpoint Policies -->

Endpoint policies are IAM policies attached to VPC endpoints to restrict/grant permission to the service's API calls. For example, with an S3 endpoint, a policy can be attached to limit only read access to one or more S3 buckets from the VPC.

***CHANGES***
1. Add the below to the template just under the EndpointS3:


  MyVPCEndpoint:
    Type: AWS::EC2::VPCEndpoint
    Properties:
      ServiceName: !Sub "com.amazonaws.${AWS::Region}.s3"
      VpcId: !Ref VpcA
      RouteTableIds:
        - !Ref VpcAPrivateSubnetRouteTable
      PolicyDocument:
        Version: "2008-10-17"
        Statement:
          - Sid: "NoWriteAccess"
            Effect: "Allow"
            Principal: "*"
            Action:
              - "s3:Get*"
              - "s3:List*"
            Resource: "*"
      VpcEndpointType: Gateway

The policy ensures instances in the private subnets of VPC A can only perform Get and List action and not write

