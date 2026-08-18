variable "all_vpc_details" {
  type = map(object({
    vpc_id                 = string
    vpc_cidr_block         = string
    public_subnets         = list(string)
    private_subnets        = list(string)
    private_rtb            = list(string)
    private_tgw_rtb        = list(string)
    private_tgw_subnet_ids = list(string)
    vpc_tags               = map(string)
  }))
  description = "A map of all VPC details, where each key is the name of a VPC and the value is an object containing the details of that VPC."
}

variable "vpc_name" {
  type        = list(string)
  description = "The name of the VPC that is requesting peering with another VPC."
  default     = ["vpc_a"]
}

variable "vpcs_to_pair_with" {
  type        = list(string)
  description = "A list of VPCs that are being peered with another VPC."
}

variable "agregated_route" {
  type        = list(string)
  description = "The aggregated route that is being advertised to the peered VPCs."
}



