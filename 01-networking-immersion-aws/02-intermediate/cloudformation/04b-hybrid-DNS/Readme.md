<!-- Hybrid DNS -->
Route 53 Resolver makes hybrid cloud easier for enterprise customers by enabling seamless DNS query resolution across your entire hybrid cloud. You can create DNS endpoints and conditional forwarding rules to allow resolution of DNS namespaces between your on-premises data center and AWS VPCs.

Recall that our simulated on-premises datacenter has a DNS server, providing authoritative name service for the example.corp domain where all internal application hosts are registered. In order to provide a complete hybrid-connectivity solution, we want to enable hosts in our AWS VPCs to resolve names of hosts in the datacenter environment. This can be achieved using Route 53 resolvers and conditional forwarding rules for the example.corp domain, while allowing the AWS instances to continue to take advantage of the highly available Amazon DNS service for all other name resolution inside the VPC and the internet.

For this exercise, we will focus on establishing DNS resolution from the AWS environment to the simulated datacenter, but it's important to note that the reverse is possible as well. Route 53 Resolvers supports inbound DNS queries that are conditionally forwarded from an on-premises DNS server. You can learn more about inbound DNS resolution in the AWS documentation .

<!-- Configure a Route 53 Resolver Outbound Endpoint -->
Route 53 Resolver uses endpoints to communicate with external DNS servers. An endpoint is an Elastic Network Interface (ENI) placed inside of a VPC which has connectivity to the existing DNS server. This may be a DNS server running on an EC2 instance, or a DNS server running on-premises accessible via Direct Connect or VPN. Since all three VPCs in our AWS environment have connectivity to the simulated datacenter via the Transit Gateway, we can use any of them for our endpoint. The endpoint will create interfaces in a minimum of two availability zones in your chosen VPC for high availability.

# NOTE THAT THE LAB ONLY CREATES AN OUTBOUND RESOLVER [aws ==> onprem] BUT I'D ADDED AN INBOUND RESOLVER TOO [onprem ==> aws] for 2 way resolution

***Deployment***

- Deploy  the Cloudformation templates in this order because we will use the exported values. 
  1. pre-requisites.yaml
  2. aws-cloud-network.yaml 
  3. onprem-network.yaml
  4. onprem-aws-interconnectivity.yaml
  5. hybrib-dns.yaml


*** Test DNS connectivitty ***
Connect to the private instances on the cloud network using AWS console via  Session Manager connection.
From the private instances from VPC A, B, and C run the following commands:

  $ cat /etc/resolv.conf

    nameserver 10.1.0.2
    search ec2.internal

Note that the instance is using the AWS provided DNS server (e.g. 10.1.0.2) and not your on-premises DNS server for name resolution

Now check that the hostname for myapp.example.corp resolves to an IP address (remember it fail in the previous lab - was able to resolve IP but not hostname)

  $ nslookup myapp.example.corp

    Server:         10.1.0.2
    Address:        10.1.0.2#53

    Non-authoritative answer:
    Name:   myapp.example.corp
    Address: 172.16.1.100


  $ curl http://myapp.example.corp

      Hello, world.