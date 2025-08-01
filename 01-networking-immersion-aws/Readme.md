<!-- Networking Immersion Day -->

**https://catalog.workshops.aws/networking/en-US**

Welcome to the AWS Networking Immersion Day!

The intent of the workshops is to educate users about AWS Networking.

A background in Networking (IP Addressing, Subnetting, VPN, Security, and Routing) is useful but not required.

There are three workshops:

Foundational: Overview of AWS Networking; covering VPCs, connecting VPCs and data centers, security controls, and network monitoring.
AWS Gateway Load Balancer: transparently deploy and scale appliances, such as firewalls, in the AWS network.
AWS Transit Gateway Multicast: Explore how Transit gateway can act as a rendezvous point for multicast sources and receivers within your AWS VPCs.
Please be aware that if you complete these workshops in your own AWS account, costs will be incurred.

***NOTE: Deploy pre-requisites***
Please deploy the ws-infra/pre-requisites.yaml template before beginning the workshop

In order to run this workshop the following resources will be created:

IAM role for EC2 instances. The AmazonS3FullAccess is required to complete the VPC Endpoints section and AmazonSSMManagedInstanceCore allows us to remotely connect to the instance using Session Manager instead of SSH
EC2 instance profile to define the IAM role that EC2 instances should use.
IAM role for VPC Flowlogs
An S3 bucket with the name networking-day-${AWS::Region}-${AWS::AccountId} that will be used to test VPC Endpoints

- To get started, navigate to CloudFormation  section in the AWS console. Click Create stack button and select With new resources (standard).

- Under Specify template, select Upload a template file, click Choose file and select the pre-requisites.yaml CloudFormation template that you downloaded. Click Next.

- Enter a stack name, e.g. NetworkingWorkshopPrerequisites. Click Next.

- Leave everything on this screen as is. Scroll down and click Next.

- Select the checkbox to acknowledge the creation of IAM resources and click the Submit button.

***NEXT**

Go to 01-foundation/01-vpc-fundamentals/Readme.md to continue