variable "cluster_name" {
  default = "eks_cluster"
}
variable "name" {
  default = "eks"
}
variable "aws_eks_cluster_role" {
  description = "aws_eks_cluster_role"
}
variable "subnet_ids_eks" {
  description = "subnet_ids_eks"
}
variable "ec2_tag_name" {
  description = "ec2_tag_name"
}
variable "node_role_arn" {
  description = "node_role_arn"
}



