resource "aws_vpc" "example_vpc" {
  cidr_block = "${var.cidr_block}.0.0/16"
  instance_tenancy = var.instance_tenancy
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = var.name
  }
}