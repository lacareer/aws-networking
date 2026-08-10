<!-- Changes to module code from 01-networking-immersion-aws/01-foundation/vpc-fundamentals/terraform  -->

# Note that this version is what is used and modified for the rest of my learning

# root module 
- Changed instance size in terraform.tfvars from t3.micro to "t3.medium"
- Added new variable, 'vpcs', in variable.tf to hold vpc and ec2 info
- Added new local variable, ec2_classification, in main.tf to choose between creating a private or publc EC2

# child module
- Nothing was changed in the EC2 module
- VPC module:
    - Added a new variable to determine whether to create multiple Nat gatway and elastic ip for each private subnet because the  EIP limit is 5.
    Since we will be working general with 3 vpc's each with two public and private subnet, all 6 private subnets cannot have EIP since we have a hard limit of 5 and requires 6.

