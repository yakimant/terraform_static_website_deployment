data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "website_sg" {
  name   = "website_${terraform.workspace}_sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    description      = "SSH"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    description      = "HTTP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform_${terraform.workspace}_key"
  public_key = var.ssh_public_key
}

resource "aws_instance" "ec2_website" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.website_sg.id]
  key_name               = aws_key_pair.terraform_key.key_name
  tags = {
    Name = "ec2-website-${terraform.workspace}"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.ec2_website.public_ip
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nginx",
      "sudo service nginx start",
      "sudo chown -R ec2-user /usr/share/nginx/html",
    ]
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"
  name    = "website-alb-${terraform.workspace}"

  load_balancer_type = "application"

  vpc_id          = data.aws_vpc.default.id
  subnets         = data.aws_subnets.default.ids
  security_groups = [aws_security_group.website_sg.id]

  target_groups = [
    {
      name             = "website-tg-${terraform.workspace}"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
        my_other_target = {
          target_id = aws_instance.ec2_website.id
          port      = 80
        }
      }
  }]

  http_tcp_listeners = [
    {
      port     = 80
      protocol = "HTTP"
    }
  ]
}

resource "aws_cloudfront_distribution" "ec2_website_cloudfront" {
  origin {
    domain_name = module.alb.lb_dns_name
    origin_id   = module.alb.lb_dns_name

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled = true

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  default_cache_behavior {
    target_origin_id       = module.alb.lb_dns_name
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }
}