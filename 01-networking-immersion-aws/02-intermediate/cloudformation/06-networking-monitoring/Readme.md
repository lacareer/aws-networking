<!-- Review CW Automatic/Custom Dashboards -->
Amazon CloudWatch dashboards are customizable home pages in the CloudWatch console that you can use to monitor your resources in a single view, even those resources that are spread across different Regions. You can use CloudWatch dashboards to create customized views of the metrics and alarms for your AWS resources.

- Navigate to the CloudWatch console 
- Click Dashboards, then click Automatic Dashboards and VPC NAT Gateways
- A dashboard will be shown that contains the key network metrics for NAT Gateways
- Review the metrics

In the CloudFOmration template we have created a CloudWatch dashboard and a NetworkInAlarm alarm for for only VPC B EC2 "VPC B Private AZ1 Server" resource

<!-- VPC Flow Logs -->
VPC Flow Logs is a feature that enables you to capture information (metadata) about the IP traffic going to and from network interfaces in your VPC. For example, if you have a content delivery platform, flow logs can profile, analyze, and predict customer patterns of the content access, and track down top talkers and malicious calls.

*** Generate traffic ***

- Select the check box next to the VPC B Private AZ1 Server instance.
  scroll down and click on the Security tab below and click on the Security groups link for sg-xxxxxxxx (VPC B Security Group)

- In the Security Group screen that opens scroll down to the Inbound rules tab and confirm that port 5201 is open for TCP traffic from 10.0.0.0/8

- In the EC2 Dashboard navigate to Instances 

- Select the check box next to the VPC B Private AZ1 Server instance, click Connect

- Click Connect again in the Session Manager tab to open a command prompt

- Install and start the iperf server on the EC2 instance in VPC B:

    $ sudo dnf install iperf3 -y && iperf3 -s

Leave the Session Manager browser tab open, switch back to the Connect to instance tab and click on the Instances link    

- Select the check box next to the VPC A Private AZ1 Server instance, and click Connect

- Click Connect again in the Session Manager tab to open a command prompt

- Install iperf and set up a TCP transfer with 2 parallel streams for 30 seconds to the EC2 instance in VPC B.
    
    $ sudo dnf install iperf3 -y && iperf3 -c 10.1.1.100 -P 2 -t 30

When iperf completed with an iperf Done. message, terminate the Session Manager connection on the VPC A instance and switch to the Session Manager tab for the connection to the VPC B instance and terminate that session too.
You have successfully generated traffic between the two instances. The next step is to view the flow log in CloudWatch.


*** View logs ***

- In the EC2 Dashboard, navigate to Instances 

- Select the checkbox next to VPC A Private AZ1 Server, scroll down to the Networking tab and make a note of the Interface ID under Network Interfaces

- VPC Flow logs can be sent to either an Amazon S3 bucket or CloudWatch. In this lab, you configured the flow logs from VPC A to be sent to CloudWatch.

- Navigate to Log Groups in the CloudWatch console  and click on the NetworkingWorkshopFlowLogsGroup log group

- Click on the log stream matching the interface ID noted in step (1) to see the flow records for that interface (make sure to select the ENI from VPC A EC2)

- Click on any entry to expand the log line and you would see something like the below:

    2 855455101846 eni-0961a2f8e15504ff1 10.0.1.100 3.94.91.31 46321 123 17 1 76 1787919852 1787919868 ACCEPT OK

*** Check email for Alarm ***

Generating traffic to the instance in VPC B via iperf should have triggered the alarm we created earlier.

Open the inbox for the email destination you configured for the alarm and check that an email notification has arrived.

*** Query Flow Log for Insights ***

See PDF steps on how to query the genrated vpc logs in CW
