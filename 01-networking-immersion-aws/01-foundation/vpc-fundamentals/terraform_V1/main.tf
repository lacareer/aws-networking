locals {
  config_tags = var.config_tags
  vpc_a_name  = "vpc_a"

  vpc_b_name = "vpc_b"

  ec2_egress_rule = {
    cidr      = "0.0.0.0/0"
    type      = "egress"
    to_port   = 0
    from_port = 0
    protocol  = "-1"
  }

  ec2_ingress_rule = {
    cidr      = "0.0.0.0/0"
    type      = "ingress"
    to_port   = 0
    from_port = 0
    protocol  = "-1"
  }
  # ec2_instance_size = "t3.micro"

  ec2_instance_info = {
    classification = ["public", "private"]
    public         = { name = "ec2_instance_public", default = "10.0.2.100", ec2_instance_size = "t3.micro" },
    private        = { name = "ec2_instance_private", default = "10.0.1.100", ec2_instance_size = "t3.micro" }
  }

}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

## Networking Resources
# dynamic create multiple vpc
#  bring vpc variable networking_config into root variable with value for the various
# vpcs that need to be created with a an appended number
# remove default values for the variable above

module "vpc_a" {
  source   = "./modules/vpc"
  vpc_name = local.vpc_a_name
  vpc_tags = merge(local.config_tags, { Name = local.vpc_a_name })
}

module "ec2_instance" {
  for_each       = toset(local.ec2_instance_info.classification)
  source         = "./modules/ec2"
  vpc_id         = module.vpc_a.custome_vpc_id
  ec2_ingress    = local.ec2_ingress_rule
  ec2_egress     = local.ec2_egress_rule
  ec2_data       = local.ec2_instance_info
  vpc_cidr_range = module.vpc_a.custom_vpc_cidr_block
  # uses either the 2nd public subnet for the public instance and the 1st private subnet for the private instance
  subnet_id = each.value == "public" ? module.vpc_a.custome_vpc_public_subnet_ids[1] : module.vpc_a.custome_vpc_private_subnet_ids[0]

  ec2_tags = merge(local.config_tags, { Name = each.value })

}