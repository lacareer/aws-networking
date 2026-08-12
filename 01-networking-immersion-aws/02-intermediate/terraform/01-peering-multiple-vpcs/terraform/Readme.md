<!-- This config peers vpc together without using a transit gateway -->
# Changes made the infra
- Changed naming of vpc variable object keys passed as a variable. The "_a" was removed in the root main.tf when creating each vpc and in the vpc variable.tf/main.tf. 
E.g

    vpc_a_cidr        =>>  vpc_cidr        = string
    vpc_a_pub_subnet  =>>  vpc_pub_subnet
    vpc_a_priv_subnet =>>  vpc_priv_subnet

- Also, a new vpc variable multiple_nats was added to determine whether to create a nat gateway in a single private network or all private subnets

- One of the vpc variable is now optional

    ec2_public = optional(object({
      name              = string
      private_ip        = string
      ec2_instance_size = string
    }), null)

- The vpc module variable networking_config now has a new key, tgw_subnets, for creating tgw subnets

- The new tgw_subnets key has  value of [] for vpc_a, meaning don't create a tgw subnets for vpc_a

- The vpc module main.tf now  has tgw_subnets, tgw_route_table, tgw_route_table_association, tgw_vpc_acl, tgw_igress_rule, tgw_egress_rule, and tgw_subnets_association

- Root module now checks if the ec_public is null or not

- A new flag, create_public_ec2 = true, added to root module vpcs variable in variable.tf to act as a switch to filter.
  This determines whether to create an ec2 instance in that's public or not

- The new filter is now used in the root module when creating a public instance in the for_each loop
