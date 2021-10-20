resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = var.aws_eks_cluster_role
  vpc_config {
    subnet_ids = var.subnet_ids_eks
  }
  depends_on = [
    var.ec2_tag_name
  ]
  tags = {
    "Name" = var.name
  }
}

resource "aws_eks_node_group" "node_group" {
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
  cluster_name    = var.cluster_name
  node_group_name = "noge_group_1"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids_eks
  tags = {
	  "Name" = var.name
  }

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  disk_size = 10
  instance_types = [ "t3.medium" ] 
  
  remote_access {
	  ec2_ssh_key = "aws-key"
  }
}