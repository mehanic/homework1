resource "aws_nat_gateway" "example_nat_gateway" {
  allocation_id = aws_eip.example_nat_eip.id
  subnet_id     = aws_subnet.example_public_subnets[0].id

  tags = {
    Name = var.name
  }

}