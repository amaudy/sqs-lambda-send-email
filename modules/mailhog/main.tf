data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "mailhog" {
  name        = "mailhog-sg"
  description = "Security group for Mailhog EC2 instance"

  ingress {
    from_port   = 8025
    to_port     = 8025
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
    description = "Mailhog Web UI"
  }

  ingress {
    from_port   = 1025
    to_port     = 1025
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Mailhog SMTP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "mailhog-security-group"
    }
  )
}

resource "aws_iam_role" "ssm_role" {
  name = "mailhog_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ssm_role.name
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "mailhog_ssm_profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "mailhog" {
  ami                  = data.aws_ami.amazon_linux_2.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  vpc_security_group_ids = [aws_security_group.mailhog.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo docker run -d --name mailhog -p 1025:1025 -p 8025:8025 mailhog/mailhog
              EOF

  tags = merge(
    var.common_tags,
    {
      Name = "mailhog-instance"
    }
  )
}