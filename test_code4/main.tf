module "create_vpc" {
  source = "./modules/create_vpc"
}

module "create_iam_cluster_role" {
  source = "./modules/create_iam_role"
  role_name = var.cluster_role["role_name"]
  service = var.cluster_role["service"]
}
module "create_ec2_role" {
  for_each = toset(var.ec2_role)
  source = "./modules/create_iam_role"
  role_name = each.value
  service = "ec2"
}

module "create_policy_and_attach" {
  source = "./modules/create_policy_and_attach"
  create_ec2_role = module.create_ec2_role
  node_role_name = module.create_ec2_role["node_role"].role_name
  cluster_role_name = var.cluster_role["role_name"]
  cluster_access_policy_role = module.create_ec2_role["access_role"].role_name
}

resource "aws_iam_instance_profile" "access_role_profile" {
  name = module.create_ec2_role["access_role"].role_name
  role = module.create_ec2_role["access_role"].role_name
}

resource "aws_ec2_tag" "tag_subnets" {
  for_each = data.aws_subnet_ids.aws_subnet_ids.ids
  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

module "create_eks_cluster" {
  source = "./modules/create_eks_cluster"
  aws_eks_cluster_role = module.create_iam_cluster_role.role_arn
  subnet_ids_eks = data.aws_subnet_ids.aws_subnet_ids.ids
  ec2_tag_name = aws_ec2_tag.tag_subnets
  node_role_arn = module.create_ec2_role["node_role"].role_arn
}

#IN order to use this resource, you should have AWSCLI & kubectl installed on the machine where terraform client installed
#resource "null_resource" "health_check_cluster" {
#  depends_on = [
#    module.create_eks_cluster.node_group
#  ]
#  provisioner "local-exec" {
#    command = "aws eks update-kubeconfig --name ${var.cluster_name} && kubectl get nodes"
#  }
#}
# ---- provision is not work good
