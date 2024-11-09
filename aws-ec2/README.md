# Provision an EC2 instance using Terraform

### Steps
- ### Create a vpc using aws_vpc
```
resource "aws_vpc" "terraform-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "terraform-vpc"
    }
}
```
- ### Create a subnet inside vpc

```
resource "aws_subnet" "terraform-subnet" {
    vpc_id = aws_vpc.terraform-vpc.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true

}
```

- ### Create an internet gateway and attach to subnet route table

    - #### Create an internet gateway
    ```
    resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.terraform-vpc.id
    tags = {
        Name = "main"
    }
    }
    ```
    - #### Create a route Table
    ```
    resource "aws_route_table" "public-route-table" {
        vpc_id = aws_vpc.terraform-vpc.id
        route {
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_internet_gateway.gw.id
    }
    }
    ```
    - #### Associate route table to subnet
    ```
    resource "aws_route_table_association" "main-aws_route_table_association" {
    subnet_id      = aws_subnet.terraform-subnet.id
    route_table_id = aws_route_table.public-route-table.id
    }
    ```
- ### Create an SG iniside vpc with 
    - #### Create a Security Group
    ```
    resource "aws_security_group" "allow-ssh" {
        vpc_id = aws_vpc.terraform-vpc.id
    }
    ```
    - #### Allow ssh on port 22 from 0.0.0.0
    ```
    resource "aws_vpc_security_group_ingress_rule" "allow-ssh-ingeress" {
        security_group_id = aws_security_group.allow-ssh.id
        ip_protocol = "tcp"
        from_port = 22
        to_port = 22
        cidr_ipv4 = "0.0.0.0/0"
    }
    ```
    - #### Allow access to internet
    ```
    resource "aws_vpc_security_group_egress_rule" "allow-internet-egress" {
    security_group_id = aws_security_group.allow-ssh.id
    ip_protocol = -1
    cidr_ipv4 = "0.0.0.0/0"
    }
    ```
- ### Create an ec2 instance inside the created vpc
```
resource "aws_instance" "terraform-aws-instance" {
  ami = "ami-08bf489a05e916bbd"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.terraform-subnet.id
  security_groups = [ aws_security_group.allow-ssh.id ]
  key_name = "mi-notebook"
}
```

## To stdout the details from created resources

```
output "ec2-instance-public_ip" {
  value = aws_instance.terraform-aws-instance.public_ip
}

output "ec2-instance-private-ip" {
  value = aws_instance.terraform-aws-instance.private_ip
}
```


[Back to Main README](../README.md)
