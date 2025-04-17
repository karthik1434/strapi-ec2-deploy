provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg-new"
  description = "Allow SSH and Strapi port 1337"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "strapi" {
  ami                         = "ami-0c101f26f147fa7fd" # Amazon Linux 2
  instance_type               = "t2.medium"
  key_name                    = "karthik"  # Replace with your actual key
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.strapi_sg.id]

  user_data = <<-EOF
              #!/bin/bash

              yum update -y
              yum install -y curl git gcc-c++ make

              curl -sL https://rpm.nodesource.com/setup_18.x | bash -
              yum install -y nodejs

              npm install -g yarn

              cd /home/ec2-user

              export STRAPI_DISABLE_TELEMETRY=true
              export STRAPI_DISABLE_GENERATE_APP_PROMPT=true

              npx create-strapi-app@latest strapi-app --quickstart --no-run

              cd strapi-app
              nohup npm run develop > /home/ec2-user/strapi.log 2>&1 &

              chown -R ec2-user:ec2-user /home/ec2-user/strapi-app
              EOF

  tags = {
    Name = "Strapi-EC2-Instance"
  }
}

output "strapi_public_ip" {
  value = aws_instance.strapi.public_ip
}
