<!-- AWS Network Firewall -->

AWS Network Firewall is a highly available, managed network firewall service for your Amazon Virtual Private Cloud (Amazon VPC). 
It enables you to easily deploy and manage stateful inspection, intrusion prevention and detection, and web filtering to protect your virtual networks on AWS. 
AWS Network Firewall automatically scales with your traffic, ensuring high availability with no additional customer investment in security infrastructure. 
While AWS Network Firewall secures the network traffic to your applications, Route 53 DNS firewall complements it by performing filtering and securing DNS query traffic to the Route 53 resolver.

*** Learning Objectives *** 
-Introduction to key concepts of AWS Network Firewall 
- How to deploy AWS Network Firewall using Infrastructure as code. 
- How to filter & secure traffic using AWS Network Firewall 
- How to use Open Source rules with AWS Network Firewall.
- How to use Route 53 DNS Firewall to filter and secure DNS traffic.

There are 3 key components of AWS Network Firewall.

1. Rule Groups: Holds a reusable collection of criteria for inspecting traffic and for handling packets and traffic flows that match the inspection criteria.

2. Policy: Defines a reusable set of stateless and stateful rule groups, along with some policy-level behavior settings.

3. Firewall: Enforces the inspection rules in the firewall policy to the VPC that the rules protect. 
   Each firewall requires one firewall policy. The firewall additionally defines settings like how to log information about your network traffic and the firewall's stateful traffic filtering.

***Amazon Route 53 Resolver DNS Firewall (DNS Firewall)***
Amazon Route 53 Resolver DNS Firewall (DNS Firewall) helps you block DNS queries that are made for known malicious domains, while allowing DNS queries to trusted domains. 
A primary use of DNS Firewall protections is to help prevent DNS exfiltration of your data. 
DNS exfiltration can happen when a bad actor compromises an application instance in your VPC and then uses DNS lookup to send data out of the VPC to a domain that they control. 
DNS Firewall has a simple deployment model that makes it straightforward for you to start protecting your VPCs by using managed domain lists, as well as custom domain lists. 
With DNS Firewall, you can filter and regulate outbound DNS requests. 
The service inspects DNS requests that are handled by Route 53 Resolver and applies actions that you define to allow or block requests.

There are 3 components of Route 53 Resolver DNS Firewall

1. Domain Lists: Defines a named, reusable collection of domain specifications for use in DNS filtering. Each rule in a rule group requires a single domain list.

2. Rule Groups: Defines a named, reusable collection of DNS Firewall rules for filtering DNS queries. You populate the rule group with the filtering rules, then associate the rule group with one or more VPCs.

3. Rule: Defines a filtering rule for DNS queries in a DNS Firewall rule group. 
   Each rule specifies one domain list and an action to take on DNS queries whose domains match the domain specifications in the list. 
   You can allow, block, or alert on matching queries. You can also define custom responses for blocked queries.  

***How DNS Firewall works with AWS Network Firewall***
DNS Firewall and AWS Network Firewall both offer domain name filtering, but for different types of traffic. 
With DNS Firewall and AWS Network Firewall together, you can configure domain-based filtering for application layer traffic over two different network paths.

DNS Firewall provides filtering for outbound DNS queries that pass through the Route 53 Resolver from applications within your VPCs. You can also configure DNS Firewall to send custom responses for queries to blocked domain names.

AWS Network Firewall provides filtering for both network and application layer traffic, but does not have visibility into queries made to the Route 53 Resolver.    

***Setup***
- You can use either of the deployment models: Distributed Deployment Model (pre-req/distributed-model.yaml) or Centralized Deployment Model (pre-req/centralized-model.yaml)  to go through the labs in this workshop.

- If you plan to deploy both the models in parallel, deploy the templates in separate AWS regions.

- Since both the templates create certain resources with the same name, deploying in the same region will cause a conflict and CloudFormation template for the subsequent deployment model will fail to deploy.


When running the workshop in your own account, make sure VPC per region  quota does not affect you. Along with existing Default VPC:

- Distributed Deployment Model creates one additional VPC.

- Centralized Deployment Model creates three additional VPCs.

- Lab 5 creates another additional VPC.


*** My deployment ***
- I deployed distributed-model.yaml for lab 1-5 

   I comented firewall, policy, and rulegroups which uses  *** Default rule order ***
   I added firewall, policy, and rulegroups which uses ***strict rule order*** of the centralized model

- Skipped lab 6 as it uses the centralized firewall model with missing code as noted below

- Modified lab 7 template to lab_7_8_DIY.yaml which added the firewall subnets and all required routing

- Deployed lab_7_8_DIY.yaml template for lab 7 instead of lab_7_and_lab_8.yaml

- Skipped lab 8 because not needed at the time



***NOTE THAT LAB ACTIONS AND NAMES SEEM TO MOVE BETWEEN THE distributed-model.yaml and centralized-model.yaml RESOURCES AND MODELS MAKING IT CONFUSING AT SOME POINT***
*** Like referencing the 'AnfwDemo-InspectionFirewall-Policy-Action' firewall policy resources that is not in the distributed model infra. So I added it ***
*** Lmabda function zip code is missing from workshop  in the centralized model iac as shown below ***
   ACMDeleteValidation:
     Type: 'AWS::Lambda::Function'
      Properties:
      ..
      ..

*** Old UI that has changed since lab was written especially arounfd RuleGroups ***


*** Lab 1 commands ***

None

*** Lab 2 commands ***

-$ curl -v https://aws.amazon.com --max-time 5 -o /dev/null

-$  curl -v https://google.com  --max-time 5 -o /dev/null

-$ curl -v https://google.com -o /dev/null --max-time 5

{$.event.src_ip = "10.2.1.176" && $.event.tls.sni = "google.com"}  # search did not work for me try to figure it out

<!-- Optional - ICMP Alerts -->

-$ ping 1.1.1.1 -c 5

Note regarding the quiz question in this section of the lab

Was the ping successful? What changes are required to make the ping successful?

My ping was successfully and I was thinking it should fail based on how the question was phrased. 
The actual question should have been: "Was the ping successful? What changes are required to make the ping unsuccessful?"
The above lab quiz question intent matches my thoughts as explained by Copilot  below:

"The rule's Action is ALERT, not DROP or REJECT. In Suricata/Network Firewall semantics, an ALERT rule logs the match but takes no blocking action on the traffic — the packet is still forwarded." 

"So the ICMP echo request matches signature sid:1, gets logged to the /AnfwDemo/Anfw/Alert CloudWatch log group, but the packet itself is marked "allowed" — hence your ping -c 5 succeeds and you'd see 5 alert log entries."

"This is actually the point of the lab's quiz question: "Was the ping successful? What changes are required to make the ping successful [i.e., to make it actually blocked]?" — the expected answer is that you'd need to change the rule's Action from ALERT to DROP (or REJECT) for ICMP to actually be blocked, since alerting alone never affects traffic flow."

"You didn't misconfigure anything — ALERT rules only log/detect, they don't enforce. If you want ping to fail, change Action: ALERT to Action: DROP in that rule group."


*** Lab 3 commands ***
-$ wget https://rules.emergingthreats.net/open/suricata-5.0/rules/emerging-user_agents.rules -O emerging-user-agents.rules

-$ curl https://rules.emergingthreats.net/open/suricata-5.0/rules/emerging-user_agents.rules -o emerging-user-agents.rules

-$ Invoke-WebRequest https://rules.emergingthreats.net/open/suricata-5.0/rules/emerging-user_agents.rules -OutFile $env:USERPROFILE\Downloads\emerging-user-agents.rules

-$ aws network-firewall create-rule-group --rule-group-name emerging-user-agents-rules --type STATEFUL --capacity 300 —-rules file://emerging-user-agents.rules

Create a file policy.json with ARN of Stateful Rule
   {
      "StatelessDefaultActions": [
         "aws\:forward_to_sfe"
      ],
      "StatelessFragmentDefaultActions": [
         "aws\:forward_to_sfe"
      ],
      "StatefulRuleGroupReferences": [
         {
               "ResourceArn": "arn\:aws\:network-firewall\:us-west-2\:XXXXXXXXXX\:stateful-rulegroup/AnfwDemo-Emerging-User-Agents-Rules-RuleGroup"
         }
      ]
   }

-$ UPDATETOKEN=(`aws network-firewall describe-firewall-policy --firewall-policy-name anfw-demo-firewall-policy --output text --query UpdateToken`)

-$ aws network-firewall update-firewall-policy --firewall-policy-name anfw-demo-firewall-policy --firewall-policy file://policy.json --update-token $UPDATETOKEN

-$ aws network-firewall describe-firewall-policy --firewall-policy-arn arn\:aws\:network-firewall\:us-west-2\:XXXXXXXXXX\:firewall-policy/AnfwDemo-InspectionFirewall-Policy --region us-east-1

alert http $HOME_NET any -> $EXTERNAL_NET any (msg:"ET USER_AGENTS Observed Suspicious UA (easyhttp client)"; flow\:established,to_server; http.user_agent; content:"easyhttp client"; bsize:15; classtype\:bad-unknown; sid:2029569; rev:1; metadata\:attack_target Client_Endpoint, created_at 2020_03_04, deployment Perimeter, former_category USER_AGENTS, signature_severity Informational, updated_at 2020_03_04;)

-$ wget -U "easyhttp client" http://www.amazon.com -o /dev/null


{$.event.src_ip = "10.2.1.176" && $.event.http.http_user_agent = "easyhttp client" && $.event.alert.signature_id = 2029569}

*** Lab 4 commands ***

Make sure TestInstance1 instance has been updated to use 'sudo' privilege and to install httpd and enable it because the lab did not and your curl command to the resource will fail
      sudo yum update -y
      sudo yum install -y ftp
      sudo yum install -y httpd
      sudo systemctl enable --now httpd

<!-- Change surricata rule to below (basically changing .<region>.compute.interal (used in lab) to .ec2.internal for ec2 private dns name) -->

pass http $HOME_NET any -> $EXTERNAL_NET 80 (http.host; dotprefix; content:".ec2.internal"; endswith; msg:"Allowed HTTP domain"; sid:172191; rev:1;)
pass tcp $HOME_NET any -> $EXTERNAL_NET 22 (msg:"Allow TCP 22"; sid:172192; rev:1;)
drop tcp $HOME_NET any -> $EXTERNAL_NET 80 (msg:"Drop established TCP:80"; flow: from_client,established; sid:172190; rev:1;)
drop tcp $HOME_NET any -> $EXTERNAL_NET !80 (msg:"Drop All non-TCP:80"; flow: from_client,established; sid:172193; rev:1;)


$ curl http://<private IP DNS name of instance AnfwDemo-SpokeVPCA-TestInstance1> --max-time 5

$ curl http://ip-10-1-0-108.ec2.internal --max-time 5

$ curl http://www.example.com --max-time 5


<!-- CW Search  -->
{ $.event.src_ip = "10.1.1.69"  && $.event.http.hostname = "www.example.com" && $.event.alert.signature_id = 172190}

<!-- Another rule -->

alert http $HOME_NET any ->  $EXTERNAL_NET 80 (http.host; dotprefix; content:".ec2.internal"; endswith; msg:"Allowed HTTP domain through sid 172192"; sid:172191; rev:1;)
pass http $HOME_NET any ->  $EXTERNAL_NET 80 (http.host; dotprefix; content:".ec2.internal"; endswith; msg:"Allowed HTTP domain"; sid:172192; rev:1;)
alert tcp $HOME_NET any -> $EXTERNAL_NET 22 (msg:"Allow TCP 22 through sid 172194"; sid:172193; rev:1;)
pass tcp $HOME_NET any -> $EXTERNAL_NET 22 (msg:"Allow TCP 22"; sid:172194; rev:1;)

<!-- Another rule -->
alert tcp any any <> any 443 (msg:"TCP connection on port 443, but app-layer-protocol is not TLS"; flow:to_server,established; sid:2271003; rev:1;)

<!-- CW Search  -->
{ $.event.src_ip = "10.1.1.242"  && $.event.http.hostname = "ip-10-2-1-177.ec2.internal" && $.event.alert.signature_id = 172191}
{ $.event.src_ip = "10.1.1.242"  && $.event.http.hostname = "www.example.com" && $.event.alert.signature_id = 4}

*** Lab 5 commands ***
<!-- Change surricata rule to below (basically changing .<region>.compute.interal (used in lab) to .ec2.internal for ec2 private dns name) -->

alert tcp any any <> any 443 (msg:"TCP connection on port 443, but app-layer-protocol is not TLS"; flow:to_server,established; sid:2271003; rev:1;)

drop tcp any any <> any 443 (msg:"TCP connection on port 443, but app-layer-protocol is not TLS"; flow:to_server,established; app-layer-protocol:!tls; sid:2271003; rev:1;)


*** Lab 6 commands ***

   Not completed as it uses the centralized model that is not deployable bcs of the missing lambda code or zip in s3 bucket


*** Lab 7 commands ***

The provided templated for lab is lab_7_and_lab_8.yaml but without the firewall subnet.

I have added the firewall subnets and all the routing needed in lab_7_8_DIY.

So deploy the lab_7_8_DIY.yaml template instead. Enter you IP address with subnet mask and leave all the other paramter with their default


Routes per route table

Route table	      Destination CIDR	         Target	                        Purpose
------------------------------------------------------------------------------------------------------------------
PrivateRtbA	      172.31.0.0/16	            local	                           intra‑VPC
                  0.0.0.0/0	               FW Endpoint A (FwVpceId1)	      egress → inspection

PrivateRtbB	      172.31.0.0/16	            local	                           intra‑VPC
                  0.0.0.0/0	               FW Endpoint B (FwVpceId2)	      egress → inspection

PublicRtbA	      172.31.0.0/16	            local	                           intra‑VPC
                  172.31.121.0/24	         FW Endpoint A (FwVpceId1)	      NAT‑return to Private A → inspection
                  0.0.0.0/0	               Internet Gateway	               egress to internet

PublicRtbB	      172.31.0.0/16	            local	                           intra‑VPC
                  172.31.122.0/24	         FW Endpoint B (FwVpceId2)	      NAT‑return to Private B → inspection
                  0.0.0.0/0	               Internet Gateway	               egress to internet

FirewallRtbA	   172.31.0.0/16	            local	                           intra‑VPC
                  0.0.0.0/0	               NAT GW A	inspected               egress → NAT

FirewallRtbB	   172.31.0.0/16	            local	intra‑VPC
                  0.0.0.0/0	               NAT GW B	inspected egress → NAT


NOW FOLLOW LAB INSTRUCTION TO COMPLETE LAB

From each instance run:

$: curl AnfwDemo-IngressVPC-ExternalAlb-1810537438.us-west-2.elb.amazonaws.com

<html>
  <head>
    <title>Test Web Server</title>
    <meta http-equiv='Content-Type' content='text/html; charset=ISO-8859-1'>
  </head>
  <body>
    <h1>Welcome to AWS Network Firewall Workshop:</h1>
    <h2>This is a simple web server running in "us-west-2b".</h2>
  </body>
</html>

Or visit the browser: http://anfwdemo-ingressvpc-externalalb-1711083534.us-east-1.elb.amazonaws.com/



*** Lab 8 commands ***
   Not completed

