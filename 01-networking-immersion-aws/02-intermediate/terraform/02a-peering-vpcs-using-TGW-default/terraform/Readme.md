# Changes made the infra
- Changed naming of vpc variable object keys passed as a variable. The "_a" was removed in the root main.tf when creating each vpc and in the vpc variable.tf/main.tf. 
E.g

    vpc_a_cidr        =>>  vpc_cidr        = string
    vpc_a_pub_subnet  =>>  vpc_pub_subnet
    vpc_a_priv_subnet =>>  vpc_priv_subnet

- One of the vpc variable is now optional

    ec2_public = optional(object({
      name              = string
      private_ip        = string
      ec2_instance_size = string
    }), null)

- Root module now checks if the ec_public is null or not

- A new flag, create_public_ec2 = true, added to root module vpcs variable in variable.tf to act as a switch to filter.
  This determines whether to create an ec2 instance in that's public or not

- The new filter is now used in the root module when creating a public instance in the for_each loop

- Added 2 new subnets for each vpc for 