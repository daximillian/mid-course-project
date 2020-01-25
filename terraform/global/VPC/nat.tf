# Allocate EIPs for the NATs
resource "aws_eip" "nat" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

# Create NAT gateways
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.0.id

  #make sure it's brought up only once the igw and subnet are ready
  depends_on = [aws_internet_gateway.terra_igw, aws_subnet.public]
  tags = {
    Name        = "NAT-gateway"
    Service     = "nat"
  }

  lifecycle {
    create_before_destroy = true
  }
}