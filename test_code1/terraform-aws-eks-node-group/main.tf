resource "random_id" "main" {
  count = var.node_group_name == "" ? 1 : 0

  byte_length = 4

  keepers = {
    ami_type       = var.ami_type
    disk_size      = var.disk_size
    instance_types = var.instance_types != null ? join("|", var.instance_types) : ""
    capacity_type  = var.capacity_type
    node_role_arn  = var.node_role_arn

    ec2_ssh_key               = var.ec2_ssh_key
    source_security_group_ids = join("|", var.source_security_group_ids)

    subnet_ids           = join("|", var.subnet_ids)
    cluster_name         = data.aws_eks_cluster.main.id
    launch_template_id   = lookup(var.launch_template, "id", "")
    launch_template_name = lookup(var.launch_template, "name", "")
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_eks_node_group" "main" {
  cluster_name    = data.aws_eks_cluster.main.id
  node_group_name = var.node_group_name == "" ? join("-", [var.cluster_name, random_id.main[0].hex]) : var.node_group_name
  node_role_arn   = var.node_role_arn == "" ? join("", aws_iam_role.main.*.arn) : var.node_role_arn

  subnet_ids = var.subnet_ids

  ami_type       = var.ami_type
  disk_size      = var.disk_size
  instance_types = var.instance_types
  capacity_type  = var.capacity_type
  labels         = var.kubernetes_labels

  release_version = var.ami_release_version
  version         = data.aws_eks_cluster.main.version

  force_update_version = var.force_update_version

  tags = var.tags

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  dynamic "remote_access" {
    for_each = var.ec2_ssh_key != null && var.ec2_ssh_key != "" ? ["true"] : []
    content {
      ec2_ssh_key               = var.ec2_ssh_key
      source_security_group_ids = var.source_security_group_ids
    }
  }

  dynamic "launch_template" {
    for_each = length(var.launch_template) == 0 ? [] : [var.launch_template]
    content {
      id      = lookup(launch_template.value, "id", null)
      name    = lookup(launch_template.value, "name", null)
      version = lookup(launch_template.value, "version")
    }
  }


  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.main_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.main_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.main_AmazonEC2ContainerRegistryReadOnly_Policy
  ]

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group#ignoring-changes-to-desired-size
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config.0.desired_size]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group#example-iam-role-for-eks-node-group
resource "aws_iam_role" "main" {
  count = var.create_iam_role ? 1 : 0

  name = var.node_group_role_name == "" ? "${var.cluster_name}-managed-group-node" : var.node_group_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main_AmazonEKSWorkerNodePolicy" {
  count = var.create_iam_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.main[0].name
}

resource "aws_iam_role_policy_attachment" "main_AmazonEKS_CNI_Policy" {
  count = var.create_iam_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.main[0].name
}

resource "aws_iam_role_policy_attachment" "main_AmazonEC2ContainerRegistryReadOnly_Policy" {
  count = var.create_iam_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.main[0].name
}
