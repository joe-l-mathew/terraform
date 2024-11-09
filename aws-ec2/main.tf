provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "terraform-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "terraform-vpc"
    }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.terraform-vpc.id
  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public-route-table" {
    vpc_id = aws_vpc.terraform-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
  }
  
}

resource "aws_subnet" "terraform-subnet" {
    vpc_id = aws_vpc.terraform-vpc.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true

}

resource "aws_route_table_association" "main-aws_route_table_association" {
  subnet_id      = aws_subnet.terraform-subnet.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_security_group" "allow-ssh" {
    vpc_id = aws_vpc.terraform-vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow-ssh-ingeress" {
    security_group_id = aws_security_group.allow-ssh.id
    ip_protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allow-internet-egress" {
  security_group_id = aws_security_group.allow-ssh.id
  ip_protocol = -1
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_instance" "terraform-aws-instance" {
  ami = "ami-08bf489a05e916bbd"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.terraform-subnet.id
  security_groups = [ aws_security_group.allow-ssh.id ]
  key_name = "mi-notebook"
}

output "ec2-instance-public_ip" {
  value = aws_instance.terraform-aws-instance.public_ip
}

output "ec2-instance-private-ip" {
  value = aws_instance.terraform-aws-instance.private_ip
}



