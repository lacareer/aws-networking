
Multicast is a communication protocol used for delivering a single stream of data to multiple receiving computers simultaneously. A
WS Transit Gateway supports routing multicast traffic between hosts in the same subnet or between subnets of attached VPCs, and it serves as a multicast router for instances sending traffic destined for multiple receiving instances. 
While an AWS VPC by itself does not support multicast, Transit Gateway can provide this new capability. 
Transit Gateway will act as the rendezvous point, receiving the packets from the multicast source, replicate it, and send it to the multicast receiver. 
Transit Gateway supports routing multicast using the Internet Group Management Protocol (IGMP) protocol or static source and member configurations.

For this lab, please be aware of the following:

You will create a transit gateway multicast domain on the existing Transit Gateway.
Multicast group membership is managed using the Amazon VPC Console, the AWS CLI, or IGMP.
In this lab, IGMPv2 is automatically configured on the EC2 instances created by the CloudFormation stack. IGMPv3 is currently not supported.
To check the IGMP version run cat /proc/net/igmp on the EC2 instances.
A subnet can only be in one multicast domain.
For additional considerations outside of those needed for this lab, please see the Multicast on Transit Gateways  documentation.

# Note: multicast-infra.yaml Stack
This CloudFormation template has been provided to create the EC2, and Clouwatch dashboard resources used in this lab. The CloudFormation template also modifies the VPC A and VPC B inbound security groups to allow IGMP and the multicast test traffic.

    Type	                Protocol	    Port range	    Source	    Description
    Custom Protocol         IGMP(2)	        All	            0.0.0.0/32	IGMP query
    Custom UDP Protocol	    UDP	            8123	        10.0.0.0/8	Inbound multicast traffic

A multicast domain allows segmentation of a multicast network into different domains, and makes the Transit Gateway act as multiple multicast routers. You define multicast domain membership at the subnet level. For this domain, you will configure static sources support which allows the addition of multicast members as sources. Only multicast sources are allowed to send multicast data.

*** Testing multicast ***
Follow the lab pdf doc to complete and test lab
Note that you may need to install 'iperf3' instead of using the legacy package 'iperf' package used in the lab test and then use the substitute commands below instead where appropriate:

    sudo yum clean metadata
    sudo yum install -y iperf3
    iperf3 -s -p 8123
    iperf3 -c <MEMBER_1_IP> -p 8123 -u -b 1M -t 600 &
    iperf3 -c <MEMBER_1_IP> -p 8123 -u -b 1M -t 600 &
