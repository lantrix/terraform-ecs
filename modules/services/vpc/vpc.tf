variable "region" {}
resource "aws_vpc" "ecs-vpc" {
   cidr_block = "192.168.0.0/16"
   instance_tenancy = "default"
   enable_dns_support = "true"
   enable_dns_hostnames = "true"
   tags = {
     Name = "ecs-vpc"
   }
}
resource "aws_subnet" "ecs-public-subnet-1" {
   vpc_id = "${aws_vpc.ecs-vpc.id}"
   cidr_block = "192.168.1.0/24"
   map_public_ip_on_launch = "false"
   availability_zone = "${var.region}a"
   tags = {
     Name = "ecs-public-subnet-1"
   }
}
resource "aws_subnet" "ecs-public-subnet-2" {
   vpc_id = "${aws_vpc.ecs-vpc.id}"
   cidr_block = "192.168.2.0/24"
   map_public_ip_on_launch = "false"
   availability_zone = "${var.region}b"
   tags = {
     Name = "ecs-public-subnet-2"
   }
}
resource "aws_internet_gateway" "ecs-internetgateway" {
   vpc_id = "${aws_vpc.ecs-vpc.id}"
   tags = {
     Name = "ecs-internetgateway"
   }
}
resource "aws_route_table" "ecs-public-routetable" {
   vpc_id = "${aws_vpc.ecs-vpc.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_internet_gateway.ecs-internetgateway.id}"
   }
   tags = {
     Name = "ecs-public-routetable"
   }
}
resource "aws_route_table_association" "ecs-public-1" {
   subnet_id = "${aws_subnet.ecs-public-subnet-1.id}"
   route_table_id = "${aws_route_table.ecs-public-routetable.id}"
}
resource "aws_route_table_association" "ecs-public-2" {
   subnet_id = "${aws_subnet.ecs-public-subnet-2.id}"
   route_table_id = "${aws_route_table.ecs-public-routetable.id}"
}
resource "aws_security_group" "ecs-sg" {
  name        = "ecs-sg"
  description = "Allow no traffic in"
  vpc_id = "${aws_vpc.ecs-vpc.id}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
     Name = "ecs-sg"
   }
}
