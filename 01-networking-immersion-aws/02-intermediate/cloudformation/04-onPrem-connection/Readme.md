<!-- Connecting to On-Premises -->
Please note, this module is optional and is not required to be completed to proceed with this workshop. You may skip to Network Monitoring
Amazon Virtual Private Cloud (Amazon VPC) provides multiple options to integrate existing data center networks with your AWS VPCs, including AWS Managed Site-to-site (IPsec) VPNs and Direct Connect connections. AWS VPN connections provide up to 1.25gbps of throughput per tunnel. When used in conjunction with the Transit Gateway, AWS VPN supports Equal-Cost Multipathing (ECMP) to allow you to scale VPN throughput.

In this lab, we will be standing up a simulated data center environment and connecting it with the existing Transit Gateway that was set up in the "Multiple VPCs" lab. Recall that at the end of that lab, we had provisioned 3 AWS VPCs and EC2 instances in each VPC. The VPCs were interconnected using Transit Gateway.

To build out our simulated data center environment and connect it to our AWS environment, we will:

- Deploy a VPC containing a simulated datacenter environment, with DNS server and a simple web application.

- Establish VPN connectivity between the simulated datacenter and the AWS environment.

- Set up DNS resolution between the AWS environment and simulated datacenter.

- Test connectivity from the AWS environment to the simulated datacenter.

***Deployment***

- Deploy  the Cloudformation templates in the list order because we will use the exported values  for our on-prem stack. 
  
  1. aws-cloud-network.yaml 
  2. onprem-network.yaml

- Follow the lab instruction from "Update Route Tables with On-Premise CIDR" section to complete connecting the similated on-prem environment to the AWS cloud network
