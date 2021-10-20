resource "aws_route_table" "example_routetable" {
  vpc_id = aws_vpc.example_vpc.id 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }

  tags = {
    Name = "${var.name}_route_table"
  }
}