//EKS Master Cluster
//This resource is the actual Kubernetes master cluster. It can take a few minutes to provision in AWS.

resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.EKSClusterRole.arn
  version  = var.cluster_version

  vpc_config {
    security_group_ids = [aws_security_group.eks-control-plane-sg.id]

    subnet_ids = [
      aws_subnet.eks-private.id,
      aws_subnet.eks-private-2.id,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-policy-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-policy-AmazonEKSServicePolicy,
  ]
}

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks-cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks-cluster.certificate_authority[0].data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws-${var.cluster_name}
current-context: aws-${var.cluster_name}
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster_name}"
KUBECONFIG
}

output "kubeconfig" {
  value = local.kubeconfig
}

resource "local_file" "kubeconfig" {
  content         = local.kubeconfig
  filename        = "${path.root}/kubeconfig"
  file_permission = "0644"
}
