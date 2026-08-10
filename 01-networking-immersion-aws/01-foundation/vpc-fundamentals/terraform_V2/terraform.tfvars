vpcs = {
  vpc_a = {
    networking_config = {
      vpc_cidr         = "10.0.0.0/16"
      subnet_count     = 2
      pub_subnets      = ["10.0.0.0/24", "10.0.2.0/24"]
      priv_subnets     = ["10.0.1.0/24", "10.0.3.0/24"]
      dns_support      = true
      hostname_support = true
      tenancy          = "default"
    }
    ec2_public  = { name = "ec2_public", private_ip = "10.0.2.100", ec2_instance_size = "t3.medium" }
    ec2_private = { name = "ec2_private", private_ip = "10.0.1.100", ec2_instance_size = "t3.medium" }
  }

}