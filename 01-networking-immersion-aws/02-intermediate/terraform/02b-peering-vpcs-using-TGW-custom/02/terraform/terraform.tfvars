vpcs = {
  vpc_a = {
    networking_config = {
      vpc_cidr         = "10.0.0.0/16"
      subnet_count     = 2
      pub_subnets      = ["10.0.0.0/24", "10.0.2.0/24"]
      priv_subnets     = ["10.0.1.0/24", "10.0.3.0/24"]
      tgw_subnets      = ["10.0.5.0/28", "10.0.5.16/28"]
      dns_support      = true
      hostname_support = true
      tenancy          = "default"
    }
    ec2_public        = { name = "ec2_public", private_ip = "10.0.2.100", ec2_instance_size = "t3.medium" }
    ec2_private       = { name = "ec2_private", private_ip = "10.0.1.100", ec2_instance_size = "t3.medium" }
    create_public_ec2 = true
  }

  vpc_b = {
    networking_config = {
      vpc_cidr         = "10.1.0.0/16"
      subnet_count     = 2
      pub_subnets      = ["10.1.0.0/24", "10.1.2.0/24"]
      priv_subnets     = ["10.1.1.0/24", "10.1.3.0/24"]
      tgw_subnets      = ["10.1.5.0/28", "10.1.5.16/28"]
      dns_support      = true
      hostname_support = true
      tenancy          = "default"
    }
    # #no public EC2 instance for this VPC, so ec2_public is commented out and set to null in the variable definition
    ## ec2_public        = { name = "ec2_public", private_ip = "10.1.2.100", ec2_instance_size = "t3.micro" }
    ec2_private       = { name = "ec2_private", private_ip = "10.1.1.100", ec2_instance_size = "t3.micro" }
    create_public_ec2 = false
  }

  vpc_c = {
    networking_config = {
      vpc_cidr         = "10.2.0.0/16"
      subnet_count     = 2
      pub_subnets      = ["10.2.0.0/24", "10.2.2.0/24"]
      priv_subnets     = ["10.2.1.0/24", "10.2.3.0/24"]
      tgw_subnets      = ["10.2.5.0/28", "10.2.5.16/28"]
      dns_support      = true
      hostname_support = true
      tenancy          = "default"
    }
    # #no public EC2 instance for this VPC, so ec2_public is commented out and set to null in the variable definition
    ## ec2_public        = { name = "ec2_public", private_ip = "10.2.2.100", ec2_instance_size = "t3.micro" }
    ec2_private       = { name = "ec2_private", private_ip = "10.2.1.100", ec2_instance_size = "t3.micro" }
    create_public_ec2 = false
  }
}

vpc_peering_list = {
  "vpcs"             = ["vpc_a", "vpc_b", "vpc_c"]
  "aggregated_route" = ["10.0.0.0/8"]
}