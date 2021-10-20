
resource "aws_vpc" "cluster" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = merge(
    var.common_tags,
    {
      "Name" = "${var.cluster_name}-eks-vpc"
    },
  )
}


resource "aws_subnet" "eks-public" {
  vpc_id = aws_vpc.cluster.id

  cidr_block        = var.public_subnet_cidr
  availability_zone = var.availabilityzone

  tags = merge(
    var.common_tags,
    {
      "Name" = "${var.cluster_name}-eks-public"
    },
  )
}

resource "aws_subnet" "eks-public-2" {
  vpc_id = aws_vpc.cluster.id

  cidr_block        = var.public_subnet_cidr2
  availability_zone = var.availabilityzone2

  tags = merge(
    var.common_tags,
    {
      "Name" = "${var.cluster_name}-eks-public-2"
    },
  )
}

// private subnet
resource "aws_subnet" "eks-private" {
  vpc_id = aws_vpc.cluster.id

  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availabilityzone

  map_public_ip_on_launch = var.use_simple_vpc

  tags = merge(
    var.common_tags,
    {
      "Name" = "${var.cluster_name}-eks-private"
    },
  )
}

resource "aws_subnet" "eks-private-2" {
  vpc_id = aws_vpc.cluster.id

  cidr_block        = var.private_subnet_cidr2
  availability_zone = var.availabilityzone2

  map_public_ip_on_launch = var.use_simple_vpc

  tags = merge(
    var.common_tags,
    {
      "Name" = "${var.cluster_name}-eks-private-2"
    },
  )
}

// internet gateway, note: creation takes a while

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.cluster.id
  tags = {
    Environment = var.cluster_name
  }
}

// reserve elastic ip for nat gateway

resource "aws_eip" "nat_eip" {
  count = var.use_simple_vpc ? 0 : 1
  vpc   = true
  tags = {
    Environment = var.cluster_name
  }
}

resource "aws_eip" "nat_eip_2" {
  count = var.use_simple_vpc ? 0 : 1
  vpc   = true
  tags = {
    Environment = var.cluster_name
  }
}

// create nat once internet gateway created
resource "aws_nat_gateway" "nat_gateway" {
  count         = var.use_simple_vpc ? 0 : 1
  allocation_id = aws_eip.nat_eip.0.id
  subnet_id     = aws_subnet.eks-public.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Environment = var.cluster_name
  }
}

resource "aws_nat_gateway" "nat_gateway_2" {
  count         = var.use_simple_vpc ? 0 : 1
  allocation_id = aws_eip.nat_eip_2.0.id
  subnet_id     = aws_subnet.eks-public-2.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Environment = var.cluster_name
  }
}

//Create private route table and the route to the internet
//This will allow all traffics from the private subnets to the internet through the NAT Gateway (Network Address Translation)

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.cluster.id
  tags = {
    Environment = var.cluster_name
    Name        = "${var.cluster_name}-private-route-table"
  }
}

resource "aws_route_table" "private_route_table_2" {
  vpc_id = aws_vpc.cluster.id
  tags = {
    Environment = var.cluster_name
    Name        = "${var.cluster_name}-private-route-table-2"
  }
}

resource "aws_route" "private_route_nat" {
  count                  = var.use_simple_vpc ? 0 : 1
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.0.id
}

resource "aws_route" "private_route_2_nat" {
  count                  = var.use_simple_vpc ? 0 : 1
  route_table_id         = aws_route_table.private_route_table_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_2.0.id
}

resource "aws_route" "private_route_igw" {
  count                  = var.use_simple_vpc ? 1 : 0
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_route_2_igw" {
  count                  = var.use_simple_vpc ? 1 : 0
  route_table_id         = aws_route_table.private_route_table_2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table" "eks-public" {
  vpc_id = aws_vpc.cluster.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Environment = var.cluster_name
    Name        = "${var.cluster_name}-eks-public"
  }
}

resource "aws_route_table" "eks-public-2" {
  vpc_id = aws_vpc.cluster.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Environment = var.cluster_name
    Name        = "${var.cluster_name}-eks-public-2"
  }
}

// associate route tables

resource "aws_route_table_association" "eks-public" {
  subnet_id      = aws_subnet.eks-public.id
  route_table_id = aws_route_table.eks-public.id
}

resource "aws_route_table_association" "eks-public-2" {
  subnet_id      = aws_subnet.eks-public-2.id
  route_table_id = aws_route_table.eks-public-2.id
}

resource "aws_route_table_association" "eks-private" {
  subnet_id      = aws_subnet.eks-private.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "eks-private-2" {
  subnet_id      = aws_subnet.eks-private-2.id
  route_table_id = aws_route_table.private_route_table_2.id
}


