data "aws_vpc" "aws_vpc" {
  filter {
    name = "tag:Name"
    values = [ "terraform_default" ]
  }
}

data "aws_subnet_ids" "aws_subnet_ids" {
  vpc_id = data.aws_vpc.aws_vpc.id
}