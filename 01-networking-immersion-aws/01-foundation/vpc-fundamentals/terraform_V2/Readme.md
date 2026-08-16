<!-- Changes to module code from 01-networking-immersion-aws/01-foundation/vpc-fundamentals/terraform_V1  -->

# Note that this version is what is used and modified for the rest of my learning

# root module 
- Changed instance size in terraform.tfvars from t3.micro to "t3.medium"
- Added new variable, 'vpcs', in variable.tf to hold vpc and ec2 info
- Added new local variable, ec2_classification, in main.tf to choose between creating a private or publc EC2

# child module
- No change EC2 module
- No change to VPC module

