module "nginx_ssh_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "nginx_ssh_sg"
  description = "Security group for nginx_ssh_sg"
  vpc_id      = aws_vpc.uclimate.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
}

module "nginx_web_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "nginx_web_sg"
  description = "Security group for nginx_web_sg"
  vpc_id      = aws_vpc.uclimate.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

resource "aws_instance" "nginx" {
  ami           = "ami-06cffe063efe892ad"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.uclimate.id
  key_name      = "Kotlin Server"

  vpc_security_group_ids = [
    module.nginx_web_sg.security_group_id,
    module.nginx_ssh_sg.security_group_id
  ]

  tags = {
    project = "uclimate"
    Name    = "nginx"
  }

  monitoring              = true
  disable_api_termination = false
  ebs_optimized           = false
}

resource "aws_eip" "nginx" {
  instance = aws_instance.nginx.id
  vpc      = true
}

resource "aws_route53_record" "www" {
  zone_id = "Z079033821740MUFD7UFW"
  name    = "api.gzmo.io"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.nginx.public_ip]
}