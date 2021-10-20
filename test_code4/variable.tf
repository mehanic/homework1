variable "cluster_role" {
  type = map
  default = {
    role_name = "cluster_role"
    service = "eks"
  }
}
variable "ec2_role" {
  default = ["node_role","access_role"]
}

variable "cluster_name" {
  default = "eks_cluster"
}

# variable "aws_iam_cluster_role" {
#   default = ["AmazonEKSClusterPolicy","AmazonEKSVPCResourceController"]
# }

# variable "aws_iam_node_role" {
#   default = ["AmazonEKSWorkerNodePolicy","AmazonEKS_CNI_Policy","AmazonEC2ContainerRegistryReadOnly"]
# }