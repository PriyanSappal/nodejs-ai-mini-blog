# resource "aws_security_group" "mongo_sg" {
#   name        = "${var.project_name}-mongo-sg"
#   description = "Allow only ECS app to access MongoDB"
#   vpc_id      = var.vpc_id

#   ingress {
#     description = "MongoDB access from ECS subnet"
#     from_port   = 27017
#     to_port     = 27017
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.1.0/24"] # public subnet where ECS lives
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_instance" "mongo" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.micro"
#   subnet_id     = var.private_subnet_id
#   key_name      = var.ssh_key_name
#   vpc_security_group_ids = [aws_security_group.mongo_sg.id]

#   user_data = <<-EOF
#               #!/bin/bash
#               apt update -y
#               apt install -y mongodb
#               systemctl enable mongodb
#               systemctl start mongodb
#               EOF

#   tags = { Name = "${var.project_name}-mongo" }
# }

# data "aws_ami" "ubuntu" {
#   most_recent = true
#   owners = ["099720109477"]
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }
# }

# output "private_ip" {
#   value = aws_instance.mongo.private_ip
# }
