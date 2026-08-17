#output each vpc details
output "vpc_peering_details" {
  value = { for k, v in module.vpc : k => v.custom_vpc_details }
}

#output each ec2 public instance details
output "ec2_public_details" {
  value = { for k, v in module.ec2_public : k => v.ec2_info.public }
}

output "ec2_private_details" {
  value = { for k, v in module.ec2_private : k => v.ec2_info.private }
}
