resource "aws_internet_gateway" "example_igw" {
  tags = {
    "Name" = var.name
  }
  vpc_id = aws_vpc.example_vpc.id
}