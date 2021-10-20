resource "aws_iam_role_policy_attachment" "aws-cluster-policy-attachment01" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy", 
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ])
  role       = var.cluster_role_name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "aws-node-policy-attachment04" {
  depends_on = [
    var.create_ec2_role
  ]
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", 
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])
  role       = var.node_role_name
  policy_arn = each.value
}

#inline policy to be attached for cluster access policy.
resource "aws_iam_role_policy" "cluster_access_policy" {
  name = "cluster_access_policy"
  role = var.cluster_access_policy_role
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "ssm:GetParameter",
          "eks:ListUpdates",
          "eks:ListFargateProfiles"
        ],
        "Resource": "*"
      }
    ]
  })
}