locals {
  config_tags = var.config_tags
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
  ec2_classification = ["public", "private"]
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# ─── VPCs ────────────────────────────────────────────────────────────────────
module "vpc" {
  for_each = var.vpcs
  source   = "./modules/vpc"
  vpc_name = each.key
  networking_config = {
    vpc_cidr         = each.value.networking_config.vpc_cidr
    subnet_count     = each.value.networking_config.subnet_count
    vpc_pub_subnet   = each.value.networking_config.pub_subnets
    vpc_priv_subnet  = each.value.networking_config.priv_subnets
    tgw_subnets      = each.value.networking_config.tgw_subnets
    dns_support      = each.value.networking_config.dns_support
    hostname_support = each.value.networking_config.hostname_support
    tenancy          = each.value.networking_config.tenancy
  }
  multiple_nats = "no" #new variable to control whether multiple NAT gateways are created or not
  vpc_tags      = merge(local.config_tags, { Name = each.key })
}

# ─── Public EC2 instances (one per VPC) ──────────────────────────────────────
module "ec2_public" {
  for_each       = { for k, v in var.vpcs : k => v if v.create_public_ec2 } #if condition acts as a filter and allows creates public EC2 instances only for VPCs where create_public_ec2 is true
  source         = "./modules/ec2"
  vpc_id         = module.vpc[each.key].custome_vpc_id
  vpc_cidr_range = module.vpc[each.key].custom_vpc_cidr_block
  subnet_id      = module.vpc[each.key].custome_vpc_public_subnet_ids[1]
  ec2_ingress    = local.ec2_ingress_rule
  ec2_egress     = local.ec2_egress_rule
  ec2_tags       = merge(local.config_tags, { Name = "${local.ec2_classification[0]}" }, { VPC_Name = "${module.vpc[each.key].vpc_tags.Name}" })

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
  ec2_tags       = merge(local.config_tags, { Name = "${local.ec2_classification[1]}" }, { VPC_Name = "${module.vpc[each.key].vpc_tags.Name}" })

  ec2_data = {
    classification = local.ec2_classification
    # public         = { name = each.value.ec2_public.name, default = each.value.ec2_public.private_ip, ec2_instance_size = each.value.ec2_public.ec2_instance_size }
    public  = each.value.ec2_public != null ? { name = each.value.ec2_public.name, default = each.value.ec2_public.private_ip, ec2_instance_size = each.value.ec2_public.ec2_instance_size } : { name = "", default = "", ec2_instance_size = "" }
    private = { name = each.value.ec2_private.name, default = each.value.ec2_private.private_ip, ec2_instance_size = each.value.ec2_private.ec2_instance_size }
  }
}

