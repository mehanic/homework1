resource "aws_eip" "example_nat_eip" {
  tags = {
    Name = "${var.name}_nat"
  }
}