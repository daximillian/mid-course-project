# VPC
resource "aws_vpc" "terra_vpc" {
  cidr_block       = "${var.vpc_cidr}"
  tags = {
    Name = "TerraVPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = "${aws_vpc.terra_vpc.id}"
  tags = {
    Name = "main"
  }
}

# Subnets : public
resource "aws_subnet" "public" {
  count = "${length(var.subnets_cidr_public)}"
  vpc_id = "${aws_vpc.terra_vpc.id}"
  cidr_block = "${element(var.subnets_cidr_public,count.index)}"
  availability_zone = "${element(var.azs,count.index)}"
  tags = {
    Name = "Subnet-public-${count.index+1}"
  }
}

# Subnets : private
resource "aws_subnet" "private" {
  count = "${length(var.subnets_cidr_private)}"
  vpc_id = "${aws_vpc.terra_vpc.id}"
  cidr_block = "${element(var.subnets_cidr_private,count.index)}"
  availability_zone = "${element(var.azs,count.index)}"
  tags = {
    Name = "Subnet-private-${count.index+1}"
  }
}

# Route table: attach Internet Gateway 
resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.terra_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terra_igw.id}"
  }
  tags = {
    Name = "publicRouteTable"
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "a" {
  count = "${length(var.subnets_cidr_public)}"
  subnet_id      = "${element(aws_subnet.public.*.id,count.index)}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

# Create private route tables
resource "aws_route_table" "private_rt" {
  count = "${length(var.subnets_cidr_private)}"

  vpc_id = "${aws_vpc.terra_vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  }

  tags = {
    Name        = "Private-routetb-${count.index+1}"
    Service     = "nat"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route table association with private subnets
resource "aws_route_table_association" "b" {
  count = "${length(var.subnets_cidr_private)}"
  subnet_id      = "${element(aws_subnet.private.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.private_rt.*.id,count.index)}"
}

