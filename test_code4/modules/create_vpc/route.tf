resource "aws_route" "example_nat_route" {
  route_table_id = aws_vpc.example_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.example_nat_gateway.id
}