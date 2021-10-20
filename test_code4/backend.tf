terraform {
  backend "s3" {
    bucket = "terraform-state-eks-key-s3"
    key = "eks-bootcamp-6.tf"
    region = "us-east-1"
  }
}