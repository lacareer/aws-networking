<!-- Connecting to SDWAN -->

AWS Transit Gateway Connect simplifies the integration of third-party SD-WAN and networking appliances with AWS by enabling direct BGP peering with Transit Gateway over GRE tunnels. Transit Gateway Connect allows third-party appliances to leverage existing VPC attachments or Direct Connect attachments as a transport layer, allowing higher bandwidth when compared to VPN.

By using GRE tunnels between network appliances and AWS Transit Gateway, organizations can establish dynamic routing with BGP, enabling seamless route exchange without the complexity of manually configuring static routes. This approach enhances scalability and provides flexible connectivity between SDWAN fabric and AWS VPCs over private network.

A Connect peer can only be established over a VPC attachments or Direct Connect attachments — these serve as the underlying transport that carries GRE traffic between your appliance and the Transit Gateway. This enables appliances running in AWS or in your on-premises environment (via Direct Connect) to dynamically exchange routes with the Transit Gateway.


One-line            Memory Tricks
___________________________________________________________________
Term	              Dumbed DownSD-WAN	Smart GPS for network traffic
GRE	                Virtual tunnel between networks
BGP	                Routers sharing directions with each other
Transit Gateway	    Central airport/hub inside AWS

# Super Short Version

Imagine you're shipping packages:

Transit Gateway = the airport
GRE = the tunnel to the airport
BGP = workers exchanging route maps
SD-WAN = the smart GPS deciding the best route