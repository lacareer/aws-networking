<!-- Connecting AWS VPC to On-Premises network-->

In this lab, we will be standing up a simulated data center environment and connecting it with the existing Transit Gateway that was set up in the "Multiple VPCs" lab. Recall that at the end of that lab, we had provisioned 3 AWS VPCs and EC2 instances in each VPC. The VPCs were interconnected using Transit Gateway.

To build out our simulated data center environment and connect it to our AWS environment, we will:

- Deploy a VPC containing a simulated datacenter environment, with DNS server and a simple web application.

- Establish VPN connectivity between the simulated datacenter and the AWS environment.

- Set up DNS resolution between the AWS environment and simulated datacenter.

- Test connectivity from the AWS environment to the simulated datacenter.

***Deployment***

- Deploy  the Cloudformation templates in this order because we will use the exported values. 
  1. pre-requisites.yaml
  2. aws-cloud-network.yaml 
  3. onprem-network.yaml
  4. onprem-aws-interconnectivity.yaml

*** Test connectivitty ***
1.  From the private instances from VPC A, B, and C ping the private instance in the onprem network

  - ping 172.16.1.100 -c 3

2.  From the onprem custome gateway instance ping the privates instances in VPC A, B, and C

  - ping 10.0.1.100

  - ping 10.1.1.100

  - ping 10.2.1.100


All pings from step 1/2 should all be successful