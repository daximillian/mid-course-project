# Allocate EIPs for the NATs
resource "aws_eip" "nat" {
  count  = "${length(var.subnets_cidr_private)}"
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

# Create NAT gateways
resource "aws_nat_gateway" "nat" {
  count = "${length(var.subnets_cidr_private)}"

  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  #make sure it's brought up only once the igw and subnet are ready
  depends_on = ["aws_internet_gateway.terra_igw", "aws_subnet.public"]
  tags = {
    Name        = "NAT-gateway-${count.index+1}"
    Service     = "nat"
  }

  lifecycle {
    create_before_destroy = true
  }
}