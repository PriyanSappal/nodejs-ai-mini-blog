provider "aws" {
  region = var.region
  profile = "ci-cd-deployer"
}

resource "aws_key_pair" "devops_key" {
  key_name   = "devops-key"
  # public_key = file("~/.ssh/devops-key.pub")
  # uncomment the above line to use tf locally without CI/CD and comment the variable line below
  public_key = var.devops_public_key
}

resource "aws_security_group" "devops_blog_sg" {
  name        = "devops-blog-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App access (HTTP)"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow public access to app
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_vpc" "default" {
  default = true
}


resource "aws_instance" "devops_blog" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  associate_public_ip_address = true # 👈 ensures we get a public IP
  subnet_id                   = element(data.aws_subnets.default.ids, 0)
  vpc_security_group_ids      = [aws_security_group.devops_blog_sg.id]
  key_name                    = aws_key_pair.devops_key.key_name
  user_data = templatefile("/user-data.sh", {
    OPENAI_API_KEY = var.openai_api_key
    MONGO_URI      = var.mongo_uri
    PORT           = var.PORT
  })

  tags = {
    Name = "DevOpsBlog"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Output of the IP (no interaction with the AWS UI)

output "public_ip" {
  value       = aws_instance.devops_blog.public_ip
  description = "Public IP of the EC2 instance"
}

output "app_url" {
  value       = "http://${aws_instance.devops_blog.public_ip}:3000"
  description = "Access your app in the browser"
}