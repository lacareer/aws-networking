locals {
  config_tags = var.config_tags
  ##OLD CODE
  # vpc_a_name  = "vpc_a"

  # vpc_b_name = "vpc_b"

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
  ##OLD CODE
  # ec2_instance_info = {
  #   classification = ["public", "private"]
  #   public         = { name = "ec2_instance_public", default = "10.0.2.100", ec2_instance_size = "t3.micro" },
  #   private        = { name = "ec2_instance_private", default = "10.0.1.100", ec2_instance_size = "t3.micro" }
  # }
  ec2_classification = ["public", "private"]
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


##OLD CODE
# module "vpc_a" {
#   source   = "./modules/vpc"
#   vpc_name = local.vpc_a_name
#   vpc_tags = merge(local.config_tags, { Name = local.vpc_a_name })
# }

# module "ec2_instance" {
#   for_each       = toset(local.ec2_instance_info.classification)
#   source         = "./modules/ec2"
#   vpc_id         = module.vpc_a.custome_vpc_id
#   ec2_ingress    = local.ec2_ingress_rule
#   ec2_egress     = local.ec2_egress_rule
#   ec2_data       = local.ec2_instance_info
#   vpc_cidr_range = module.vpc_a.custom_vpc_cidr_block
#   # uses eith the 2nd public subnet for the public instance and the 1st private subnet for the private instance
#   subnet_id = each.value == "public" ? module.vpc_a.custome_vpc_public_subnet_ids[1] : module.vpc_a.custome_vpc_private_subnet_ids[0]

#   ec2_tags = merge(local.config_tags, { Name = each.value })

# }


# NEW DYNAMIC CODE FOR CREATING VPC AND EC2

# ─── VPCs ────────────────────────────────────────────────────────────────────
module "vpc" {
  for_each = var.vpcs
  source   = "./modules/vpc"
  vpc_name = each.key
  networking_config = {
    vpc_a_cidr        = each.value.networking_config.vpc_cidr
    subnet_count      = each.value.networking_config.subnet_count
    vpc_a_pub_subnet  = each.value.networking_config.pub_subnets
    vpc_a_priv_subnet = each.value.networking_config.priv_subnets
    dns_support       = each.value.networking_config.dns_support
    hostname_support  = each.value.networking_config.hostname_support
    tenancy           = each.value.networking_config.tenancy
  }
  vpc_tags = merge(local.config_tags, { Name = each.key })
}

# ─── Public EC2 instances (one per VPC) ──────────────────────────────────────
module "ec2_public" {
  for_each       = var.vpcs
  source         = "./modules/ec2"
  vpc_id         = module.vpc[each.key].custome_vpc_id
  vpc_cidr_range = module.vpc[each.key].custom_vpc_cidr_block
  subnet_id      = module.vpc[each.key].custome_vpc_public_subnet_ids[1]
  ec2_ingress    = local.ec2_ingress_rule
  ec2_egress     = local.ec2_egress_rule
  ec2_tags       = merge(local.config_tags, { Name = "${local.ec2_classification[0]}" })

  ec2_data = {
    classification = local.ec2_classification
    public         = { name = each.value.ec2_public.name, default = each.value.ec2_public.private_ip, ec2_instance_size = each.value.ec2_public.ec2_instance_size }
    private        = { name = each.value.ec2_private.name, default = each.value.ec2_private.private_ip, ec2_instance_size = each.value.ec2_private.ec2_instance_size }
  }
}

# ─── Private EC2 instances (one per VPC) ─────────────────────────────────────
module "ec2_private" {
  for_each       = var.vpcs
  source         = "./modules/ec2"
  vpc_id         = module.vpc[each.key].custome_vpc_id
  vpc_cidr_range = module.vpc[each.key].custom_vpc_cidr_block
  subnet_id      = module.vpc[each.key].custome_vpc_private_subnet_ids[0]
  ec2_ingress    = local.ec2_ingress_rule
  ec2_egress     = local.ec2_egress_rule
  ec2_tags       = merge(local.config_tags, { Name = "${local.ec2_classification[1]}" })

  ec2_data = {
    classification = local.ec2_classification
    public         = { name = each.value.ec2_public.name, default = each.value.ec2_public.private_ip, ec2_instance_size = each.value.ec2_public.ec2_instance_size }
    private        = { name = each.value.ec2_private.name, default = each.value.ec2_private.private_ip, ec2_instance_size = each.value.ec2_private.ec2_instance_size }
  }
}