locals {
  instance_tags = var.ec2_tags
  ec2_sg_rule_public = [
    {
      cidr      = "0.0.0.0/0"
      type      = "ingress"
      to_port   = 0
      from_port = 0
      protocol  = "-1"
  }]

  ec2_sg_rule_private = [
    {
      cidr      = "10.0.0.0/16"
      type      = "ingress"
      to_port   = 0
      from_port = 0
      protocol  = "-1"
    },
    {
      cidr      = "10.1.0.0/16"
      type      = "ingress"
      to_port   = 0
      from_port = 0
      protocol  = "-1"
    },
    {
      cidr      = "10.2.0.0/16"
      type      = "ingress"
      to_port   = 0
      from_port = 0
      protocol  = "-1"
    }

  ]
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "public_instance_sg" {
  description = "Security group for public instances"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.ec2_sg_rule_public
    content {
      protocol    = ingress.value.protocol
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      cidr_blocks = [ingress.value.cidr]
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "private_instance_sg" {
  description = "Security group for private instances"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.ec2_sg_rule_private
    content {
      protocol    = ingress.value.protocol
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      cidr_blocks = [ingress.value.cidr]
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# # ec2 instance resource and security groups
# resource "aws_security_group" "allow_all_traffic" {
#   name        = "${var.ec2_tags.Name}-sg"
#   description = "Allow all inbound traffic and all outbound traffic"
#   vpc_id      = var.vpc_id
#   tags        = merge(local.instance_tags, { Name = "${var.ec2_tags.Name}-sg" })

# }

# resource "aws_security_group_rule" "allow_all_traffic_ingress" {
#   # dynamic "ingress" {
#   #   for_each = [for rule in locals.ec2_sg_rule : rule if rule.type == "ingress"]
#   #   content {
#   #     cidr_blocks       = [ingress.value.cidr]
#   #     from_port         = ingress.value.from_port
#   #     to_port           = ingress.value.to_port
#   #     protocol          = ingress.value.protocol
#   #     security_group_id = aws_security_group.allow_all_traffic.id
#   #     # cidr_blocks = [var.ec2_tags.Name == "private" ? var.vpc_cidr_range : var.ec2_ingress.cidr]
#   #   }
#   # }


#   type              = var.ec2_ingress.type
#   from_port         = var.ec2_ingress.from_port
#   to_port           = var.ec2_ingress.to_port
#   protocol          = var.ec2_ingress.protocol
#   security_group_id = aws_security_group.allow_all_traffic.id
#   # cidr_blocks       = ["10.0.0.0/16", "10.1.0.0/16", "10.2.0.0/16"]
#   cidr_blocks = [var.ec2_tags.Name == "private" ? var.vpc_cidr_range : var.ec2_ingress.cidr]

# }


# # dynamic "ingress" {
# #   for_each = [for rule in var.ec2_sg_rule : rule if rule.type == "ingress"]
# #   content {
# #     cidr_blocks       = [ingress.value.cidr]
# #     from_port         = ingress.value.from_port
# #     to_port           = ingress.value.to_port
# #     protocol          = ingress.value.protocol
# #     security_group_id = aws_security_group.allow_all_traffic.id
# #     cidr_blocks = [var.ec2_tags.Name == "private" ? var.vpc_cidr_range : var.ec2_ingress.cidr]
# #   }
# # # }


# resource "aws_security_group_rule" "allow_all_traffic_egress" {
#   type              = var.ec2_egress.type
#   from_port         = var.ec2_egress.from_port
#   to_port           = var.ec2_egress.to_port
#   protocol          = var.ec2_egress.protocol
#   cidr_blocks       = [var.ec2_egress.cidr]
#   security_group_id = aws_security_group.allow_all_traffic.id
# }


resource "aws_instance" "web" {
  iam_instance_profile        = var.ec2_instance_profile
  ami                         = nonsensitive(data.aws_ami.amazon_linux.id)
  instance_type               = var.ec2_data[var.ec2_tags.Name].ec2_instance_size
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.ec2_tags.Name == "public" ? true : false
  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/templates/ec2-user-data.tpl",
    {
      environment   = var.environment,
      instance_name = var.ec2_tags.Name,
      instance_ip   = var.ec2_data[var.ec2_tags.Name].default
  })

  private_ip = var.ec2_data[var.ec2_tags.Name].default


  # vpc_security_group_ids = [aws_security_group.allow_all_traffic.id]
  vpc_security_group_ids = [var.ec2_tags.Name == "private" ? aws_security_group.private_instance_sg.id : aws_security_group.public_instance_sg.id]

  tags = merge(local.instance_tags, { Name = "${var.ec2_tags.VPC_Name}-${var.ec2_tags.Name}-instance" })
}
