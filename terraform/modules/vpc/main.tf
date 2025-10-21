resource "aws_vpc" "this" {
cidr_block = var.cidr_block
tags = { Name = "devops-mini-blog-vpc" }
}


resource "aws_subnet" "public" {
for_each = toset(var.public_subnet_cidrs)
vpc_id = aws_vpc.this.id
cidr_block = each.key
map_public_ip_on_launch = true
tags = { Name = "public-${each.key}" }
}


resource "aws_subnet" "private" {
for_each = toset(var.private_subnet_cidrs)
vpc_id = aws_vpc.this.id
cidr_block = each.key
map_public_ip_on_launch = false
tags = { Name = "private-${each.key}" }
}


resource "aws_internet_gateway" "this" { vpc_id = aws_vpc.this.id }


resource "aws_route_table" "public" {
vpc_id = aws_vpc.this.id
route { 
 cidr_block = "0.0.0.0/0"
 gateway_id = aws_internet_gateway.this.id 
 }
}


resource "aws_route_table_association" "public_assoc" {
for_each = aws_subnet.public
subnet_id = each.value.id
route_table_id = aws_route_table.public.id
}