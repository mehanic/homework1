
locals {
  subnets = [
    aws_subnet.eks-private.id,
    aws_subnet.eks-private-2.id,
  ]

  node_role_arn = "arn:aws:iam::064058741680:root"
}

#####
# EKS Node Group
#####
module "eks-node-group" {
#  source = "git::https://github.com/softasap/terraform-aws-eks-node-group.git?ref=develop"
  source = "./terraform-aws-eks-node-group"
  node_group_name = "spot-nodegroup"
  node_role_arn   = aws_iam_role.EKSNodeRole.arn
  cluster_name = var.cluster_name
  subnet_ids   = flatten(local.subnets)
  desired_size = 1
  max_size     = 3
  min_size     = 1

  //  ec2_ssh_key = "voronenko_info"
  //  kubernetes_labels = {
  //  }
  instance_types = ["t3.small"]
  ami_release_version = "1.18.9-20210208"
  capacity_type = "SPOT"
  disk_size = 100
  create_iam_role = false
  launch_template = {}
  tags = {
    Environment = var.cluster_name
  }
  depends_on = [aws_eks_cluster.eks-cluster]
  }


module "terraform-aws-eks-external-dns" {
  count                   = var.option_external_dns_enabled ? 1 : 0
  source                  = "./terraform-aws-eks-external-dns"
  domain                  = var.domain
  cluster_name            = var.cluster_name
  cluster_region          = var.AWS_REGION
  cluster_oidc_issuer_url = local.cluster_oidc_issuer_url
  //  cluster_vpc_id = aws_vpc.cluster.id
  common_tags       = var.common_tags
  oidc_provider_arn = local.oidc_provider_arn
  depends_on        = [aws_eks_cluster.eks-cluster]
}

# module "terraform-aws-eks-vpc" {
#     source = "./terraform-aws-eks-vpc"
#     vpc_cidr  = "10.11.0.0/16"
#     use_simple_vpc = true
#     public_subnet_cidr = "10.11.0.0/24"
#     private_subnet_cidr = "10.11.1.0/24"
#     public_subnet_cidr2 = "10.11.2.0/24"
#     private_subnet_cidr2 = "10.11.3.0/24"

# }

module "eks-alb-ingress" {
  count                   = var.option_alb_ingress_enabled ? 1 : 0
  source                  = "./terraform-aws-eks-alb-ingress"
  cluster_name            = var.cluster_name
  cluster_region          = var.AWS_REGION
  cluster_oidc_issuer_url = local.cluster_oidc_issuer_url
  cluster_vpc_id          = aws_vpc.cluster.id
  common_tags             = var.common_tags
  oidc_provider_arn       = local.oidc_provider_arn
  depends_on              = [aws_eks_cluster.eks-cluster]
}
