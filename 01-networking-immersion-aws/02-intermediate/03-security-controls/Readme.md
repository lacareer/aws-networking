*** Network ACLs ***
Network ACLs are stateless access controls you configure at a subnet level, to allow or block a CIDR block on a particular port or range of ports. Network ACL rules are numbered list and evaluated top down, with a DENY ALL at the end. If a rule is matched, subsequent rules are not evaluated.

Both inbound and outbound traffic can be controlled with these rules. By default when you create subnets, they will be attached to the default Network ACL which has an ALLOW ALL rule for both inbound and outbound traffic.

In this section, we will modify the Network ACL associated with the workload subnets in VPC A to only ICMP traffic from VPC B's CIDR; and test connectivity from VPC A to VPC C, and test other connectivity from VPC B to VPC C as well.

*** Deployment ***

- Deploy the cfn template three-vpcs-TGW-3 in this directory which is similar to three-vpcs-TGW-2 but with added security control
