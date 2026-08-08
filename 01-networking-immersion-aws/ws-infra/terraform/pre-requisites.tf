terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "my-sandbox"
}



data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "ec2_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "NetworkingWorkshopEC2Role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_role_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_role_s3" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "NetworkingWorkshopInstanceProfile"
  role = aws_iam_role.ec2_role.name
}

data "aws_iam_policy_document" "vpc_flow_log_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vpc_flow_log_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:NetworkingWorkshopFlowLogsGroup:*",
    ]
  }
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name               = "NetworkingWorkshopFlowLogsRole"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_log_assume.json
}

resource "aws_iam_role_policy" "vpc_flow_log_cloudwatch" {
  name   = "CloudWatchLogsWrite"
  role   = aws_iam_role.vpc_flow_log_role.id
  policy = data.aws_iam_policy_document.vpc_flow_log_policy.json
}

resource "aws_s3_bucket" "gateway-endpoint_bucket" {
  bucket        = format("networking-day-%s-%s", data.aws_region.current.id, data.aws_caller_identity.current.account_id)
  force_destroy = true
}

# need to add a lifecycle rule to s3 bucket to delete all object after 3 days
resource "aws_s3_bucket_lifecycle_configuration" "gateway-endpoint_bucket_lifecycle" {
  bucket = aws_s3_bucket.gateway-endpoint_bucket.id

  rule {
    id     = "DeleteObjectsAfter3Days"
    status = "Enabled"

    expiration {
      days = 3
    }

    filter {}
  }
}
