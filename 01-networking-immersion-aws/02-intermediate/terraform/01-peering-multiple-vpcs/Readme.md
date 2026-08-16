<!-- Changes to module code from 01-networking-immersion-aws/01-foundation/vpc-fundamentals/terraform_V2  -->

# Note that this version is what is used and modified for the rest of my learning

# root module 
- The new vpc module variable, multiple-nats, is passed to the module with a value of "no"
- This ensures only one private subnet has one elastic ip and one nat-gateway attached


# child module
- Nothing was changed in the EC2 module
- Added new variable, multiple-nats, in variable.tf to vpc module to determine when to create a elastic ip 
  and attach it to each private subnet nat-gateway for each private subnet. The default is value is "yes"
- This new variable is to determine whether to create multiple Nat gatway and elastic ip for each private subnet because the  EIP limit is 5.
  Since we will be working general with 3 vpc's each with two public and private subnet, all 6 private subnets cannot have EIP since we have a hard limit of 5 and requires 6.
- The variable is used in the vpc private subnet, rtb, nat-gateway, and route as:
    "count  = var.multiple_nats == "yes" ? local.vpc_network_info.subnet_count : 1"

