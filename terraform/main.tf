provider "aws" {
  region = "us-west-2"
}

terraform {
  required_version = ">= 0.12.0"
}

resource "aws_vpc" "uclimate" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "uclimate"
  }
}

resource "aws_subnet" "uclimate" {
  vpc_id                  = aws_vpc.uclimate.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.uclimate.id
}

resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.uclimate.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

### ECR

resource "aws_ecr_repository" "uclimate" {
  name                 = "uclimate"
  image_tag_mutability = "MUTABLE"

  tags = {
    project = "uclimate"
  }
}

### EC2

module "dev_ssh_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ec2_sg"
  description = "Security group for ec2_sg"
  vpc_id      = aws_vpc.uclimate.id

  ingress_cidr_blocks = ["75.157.140.243/32"]
  ingress_rules       = ["ssh-tcp"]
}

module "ec2_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ec2_sg"
  description = "Security group for ec2_sg"
  vpc_id      = aws_vpc.uclimate.id

  ingress_cidr_blocks = ["75.157.140.243/32"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

resource "aws_iam_role" "ec2_role_uclimate" {
  name = "ec2_role_uclimate"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    project = "uclimate"
  }
}

resource "aws_iam_instance_profile" "ec2_profile_uclimate" {
  name = "ec2_profile_uclimate"
  role = aws_iam_role.ec2_role_uclimate.name
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2_policy"
  role = aws_iam_role.ec2_role_uclimate.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "s3:*",
        "s3-object-lambda:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_instance" "web" {
  ami           = "ami-06cffe063efe892ad"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.uclimate.id
  key_name      = "Kotlin Server"

  user_data = <<-EOF
    #!/bin/bash
    set -ex
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  EOF

  vpc_security_group_ids = [
    module.ec2_sg.security_group_id,
    module.dev_ssh_sg.security_group_id
  ]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile_uclimate.name

  tags = {
    project = "uclimate"
    Name    = "uclimate"
  }

  monitoring              = true
  disable_api_termination = false
  ebs_optimized           = false
}

resource "aws_eip" "web" {
  instance = aws_instance.web.id
  vpc      = true
}

resource "aws_route53_record" "www" {
  zone_id = "Z079033821740MUFD7UFW"
  name    = "api.gzmo.io"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.web.public_ip]
}
