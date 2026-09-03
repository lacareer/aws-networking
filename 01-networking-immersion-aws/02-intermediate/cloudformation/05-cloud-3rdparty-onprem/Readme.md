<!-- Connecting to SDWAN -->

AWS Transit Gateway Connect simplifies the integration of third-party SD-WAN and networking appliances with AWS by enabling direct BGP peering with Transit Gateway over GRE tunnels. Transit Gateway Connect allows third-party appliances to leverage existing VPC attachments or Direct Connect attachments as a transport layer, allowing higher bandwidth when compared to VPN.

By using GRE tunnels between network appliances and AWS Transit Gateway, organizations can establish dynamic routing with BGP, enabling seamless route exchange without the complexity of manually configuring static routes. This approach enhances scalability and provides flexible connectivity between SDWAN fabric and AWS VPCs over private network.

A Connect peer can only be established over a VPC attachments or Direct Connect attachments — these serve as the underlying transport that carries GRE traffic between your appliance and the Transit Gateway. This enables appliances running in AWS or in your on-premises environment (via Direct Connect) to dynamically exchange routes with the Transit Gateway.


One-line            Memory Tricks
___________________________________________________________________
 Term	                Dumbed DownSD-WAN	Smart GPS for network traffic
- GRE	                Virtual tunnel between networks
- BGP	                Routers sharing directions with each other
- Transit Gateway	    Central airport/hub inside AWS

# Super Short Version

Imagine you're shipping packages:

Transit Gateway = the airport
GRE = the tunnel to the airport
BGP = workers exchanging route maps
SD-WAN = the smart GPS deciding the best route


In this lab, we will set up a third-party network appliance and integrate it with an existing AWS Transit Gateway using a Transit Gateway Connect Attachment. This hands-on experience will demonstrate how GRE tunneling and BGP peering enable dynamic route propagation, providing a scalable and efficient solution for integrating SD-WAN appliances with AWS networking services.

To build out our simulated network appliance environment and connect it to AWS, we will:

- Deploy a VPC containing a third-party network appliance.
- Create a Transit Gateway Connect Attachment.
- Establish a GRE tunnel between the appliance and Transit Gateway.
- Enable BGP peering over the GRE tunnel.
- Validate connectivity and route propagation.

# NOTE THAT YOU MAY RUN INTO INTERNERT GATEWAY AND ELASTIC IP KIMITS OF 5 FOR EACH IN A PERSONAL ACCOUNT IF THERE ARE EXISTING IGW or EIP ALREADY CONFIG IN THE ACCOUNT


*** Deploy the infra in this order using one of the options below ***
1. If you intend to follow the lab configuration steps using the pdf docs
    - pre-requisites.yaml

    - aws-cloud-network-console.yaml

    - 3rd-party-appliance-console.yaml

2.  If you intend to use a code base that is already configured  
    - pre-requisites.yaml

    - aws-cloud-network-cfn.yaml

    - 3rd-party-appliance-cfn.yaml

If you are deploying 3rd-party-appliance-console.yaml, use the LAB steps along with the AWS console and the commands below to establish estblish BGP connections with the TGW

Otherwise deploy the 3rd-party-appliance-console.yaml and use only the command from the "Third Party Appliance" EC2 to establish BGP conections with the TGW

# Note on TGW CIDR block
You can specify a size /24 CIDR block or larger (for example, /23 or /22) for IPv4, or a size /64 CIDR block or larger (for example, /63 or /62) for IPv6. 
You can associate any public or private IP address range, except for addresses in the 169.254.0.0/16 range, and ranges that overlap with the addresses for your VPC attachments and on-premises networks.

*** Testing connectivity ***

Third Party Appliance" EC2 commands after connecting using session manager from the console

$ sudo ip tunnel add gre1 mode gre local 10.5.0.6 remote 10.10.0.1 ttl 255

    sudo ip link set gre1 upsudo ip link set gre1 up$

$ sudo ip tunnel add gre1 mode gre local 10.5.0.6 remote 10.10.0.1 ttl 255

    add tunnel "gre0" failed: File exists

$ sudo ip link set gre1 up

$ sudo ip addr add 169.254.255.1/30 dev gre1

$ sudo ip link set gre1 up

$ ip tunnel show gre1

    gre1: gre/ip remote 10.10.0.1 local 10.5.0.6 ttl 255

$ sudo ip addr show dev gre1

    8: gre1@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 8977 qdisc noqueue state UNKNOWN group default qlen 1000
        link/gre 10.5.0.6 peer 10.10.0.1
        inet 169.254.255.1/30 scope global gre1
        valid_lft forever preferred_lft forever
        inet6 fe80::5efe:a05:6/64 scope link
        valid_lft forever preferred_lft forever

$ sudo ip route replace 10.10.0.1/32 via 10.5.0.1 dev ens6 src 10.5.0.6

$ sudo vtysh

    Hello, this is FRRouting (version 8.1).
    Copyright 1996-2005 Kunihiro Ishiguro, et al.

edge-router1# configure terminal

edge-router1(config)# router bgp 65500

edge-router1(config-router)# router bgp 65500
    neighbor 169.254.255.2 remote-as 64512
    neighbor 169.254.255.2 update-source gre1
    neighbor 169.254.255.2 ebgp-multihop 2
    neighbor 169.254.255.2 soft-reconfiguration inbound

    address-family ipv4 unicast
        neighbor 169.254.255.2 route-map ALLOW_ALL out
        neighbor 169.254.255.2 route-map ALLOW_ALL in
    exit-address-family

edge-router1(config-router)# end

edge-router1# write

    Note: this version of vtysh never writes vtysh.conf
    Building Configuration...
    Integrated configuration saved to /etc/frr/frr.conf
    [OK]

edge-router1# exit

$ sudo vtysh

    Hello, this is FRRouting (version 8.1).
    Copyright 1996-2005 Kunihiro Ishiguro, et al.

edge-router1# show ip bgp summary

    IPv4 Unicast Summary (VRF default):
    BGP router identifier 192.168.255.1, local AS number 65500 vrf-id 0
    BGP table version 4
    RIB entries 7, using 1288 bytes of memory
    Peers 2, using 1446 KiB of memory

    Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
    169.254.255.2   4      64512         8         9        0    0    0 00:00:41            0        4 N/A
    192.168.255.2   4      65501        32        35        0    0    0 00:26:34            3        4 N/A

    Total number of neighbors 2

Set #2 commands    

    $ sudo vtysh -c "show ip bgp"

        BGP table version is 5, local router ID is 192.168.255.1, vrf id 0
        Default local pref 100, local AS 65500
        Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
                    i internal, r RIB-failure, S Stale, R Removed
        Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
        Origin codes:  i - IGP, e - EGP, ? - incomplete
        RPKI validation codes: V valid, I invalid, N Not found

        Network          Next Hop            Metric LocPrf Weight Path
        *> 10.0.0.0/16      169.254.255.2          100             0 64512 i
        *> 10.5.0.0/28      0.0.0.0                  0         32768 i
        *> 172.20.0.0/28    192.168.255.2            0             0 65501 i
        *> 172.20.16.0/20   192.168.255.2            0             0 65501 i
        *> 192.168.255.0/30 192.168.255.2            0             0 65501 ?

        Displayed  5 routes and 5 total paths


From Branch1 Router EC2 instance run:

    $ sudo vtysh -c "show ip bgp 10.0.1.100"

        BGP routing table entry for 10.0.0.0/16, version 5
        Paths: (1 available, best #1, table default)
        Advertised to non peer-group peers:
        192.168.255.1
        65500 64512
            192.168.255.1 from 192.168.255.1 (192.168.255.1)
            Origin IGP, valid, external, best (First path received)
            Last update: Tue Sep  1 15:30:21 2026

    $ ping -I 172.20.0.5 10.0.1.100 -c 5

        PING 10.0.1.100 (10.0.1.100) from 172.20.0.5 : 56(84) bytes of data.
        64 bytes from 10.0.1.100: icmp_seq=1 ttl=125 time=6.42 ms
        64 bytes from 10.0.1.100: icmp_seq=2 ttl=125 time=2.58 ms
        64 bytes from 10.0.1.100: icmp_seq=3 ttl=125 time=1.62 ms
        64 bytes from 10.0.1.100: icmp_seq=4 ttl=125 time=1.53 ms
        64 bytes from 10.0.1.100: icmp_seq=5 ttl=125 time=1.79 ms

        --- 10.0.1.100 ping statistics ---
        5 packets transmitted, 5 received, 0% packet loss, time 4007ms
        rtt min/avg/max/mdev = 1.530/2.786/6.417/1.853 ms

Since we allowed the network 172.20.0.0/16 in the Security Group for the instance VPC A Private Route Table, we are using the source IP 172.20.0.5 of the directly connected interface for the ICMP testing.

You should receive successful replies — confirming end-to-end routing from the Third-Party network to VPC A is working dynamically via the TGW Connect Attachment.        