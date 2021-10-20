resource "aws_subnet" "example_public_subnets" {
  vpc_id = aws_vpc.example_vpc.id
  count = length(data.aws_availability_zones.availability_zones.names)
  availability_zone = data.aws_availability_zones.availability_zones.names[count.index]
  cidr_block = "${var.cidr_block}.${10+count.index}.0/24"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.name}_public_subnet_${data.aws_availability_zones.availability_zones.names[count.index]}"
    "Type" = "public"
  }
}

resource "aws_subnet" "example_private_subnet" {
    vpc_id = aws_vpc.example_vpc.id
    count = length(data.aws_availability_zones.availability_zones.names)
    availability_zone = data.aws_availability_zones.availability_zones.names[count.index]
    cidr_block = "${var.cidr_block}.${count.index}.0/24"
    map_public_ip_on_launch = false
    tags = {
        "Name" = "${var.name}_private_subnet_${data.aws_availability_zones.availability_zones.names[count.index]}"
        "Type" = "private"
    }
}