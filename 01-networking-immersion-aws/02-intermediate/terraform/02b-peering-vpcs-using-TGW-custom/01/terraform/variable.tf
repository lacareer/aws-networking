variable "profile" {
  description = "AWS CLI profile to use."
  default     = "my-sandbox"
  type        = string
}

variable "region" {
  description = "AWS region to use."
  default     = "us-east-1"
  type        = string
}

variable "config_tags" {
  description = "A map of tags to apply to resources."
  type        = map(string)
  default = {
    Environment = "dev"
    Owner       = "Network Team"
    company     = "chukky.com"
  }
}

##NEW CODE
variable "vpcs" {
  description = "Map of VPCs to create"
  type = map(object({
    networking_config = object({
      vpc_cidr     = string
      subnet_count = number
      pub_subnets  = list(string)
      priv_subnets = list(string)
      tgw_subnets  = list(string)
      # pair_cidrs       = list(string)
      dns_support      = bool
      hostname_support = bool
      tenancy          = string
    })
    ec2_public = optional(object({
      name              = string
      private_ip        = string
      ec2_instance_size = string
    }), null)
    ec2_private = object({
      name              = string
      private_ip        = string
      ec2_instance_size = string
    })
    create_public_ec2 = bool
    # #create_private_ec2 = bool
  }))
}

variable "vpc_peering_list" {
  description = "Map of VPC peering groups"
  type        = map(list(string))
}