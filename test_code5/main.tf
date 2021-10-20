
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

module "iam_role" {
  source      = "./modules/iam_role"
  name        = "TEST"
  environment = "stage"

  # Using IAM role
  enable_iam_role      = true
  iam_role_name        = "tf-role-eks"
  iam_role_name_prefix = "-cluster"
  iam_role_description = "It's just a simple IAM role to test TF module"
  # Inside additional_files directory I will add additional policies for assume_role_policy usage in the future....
  iam_role_assume_role_policy = file("additional_files/iam/policy.json")

  iam_role_force_detach_policies = true
  iam_role_path                  = "/lambda-role/"
  iam_role_max_session_duration  = 3600

  # Using IAM role policy
  enable_iam_role_policy = true
  iam_role_policy_name   = "my-iam-role-policy-for-testing-terraform"
  iam_role_policy        = file("additional_files/iam/policy1.json")

  # Using IAM role policy attachment
  enable_iam_role_policy_attachment = true
  iam_role_policy_attachment_policy_arns            = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"                                                   
  ]

  # Using IAM instance profile
  enable_iam_instance_profile = true
  iam_instance_profile_name   = "tf-role-for-testing"

  tags = tomap({
    "Environment"   = "dev",
    "Createdby"     = "Admin",
    "Orchestration" = "Terraform"
  })
}



module "vpc" {
  source      = "./modules/vpc"
  name        = "test"
  environment = "stage"

  # VPC
  enable_vpc = true
  vpc_name   = ""

  vpc_instance_tenancy                 = "default"
  vpc_enable_dns_support               = true
  vpc_enable_dns_hostnames             = true
  vpc_assign_generated_ipv6_cidr_block = false
  # Dedicated tenancy VPCs cannot be enabled for ClassicLink by default
  #---------------enable_classiclink = false

  vpc_cidr_block             = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]

  #Internet-GateWay
  enable_internet_gateway = true
  # NAT GW
  enable_nat_gateway = true
  single_nat_gateway = true
  # VPN GW
  enable_vpn_gateway = false
  # DHCP
  enable_dhcp = true
  # EIP
  enable_eip = true

  tags = tomap({
    "Environment"   = "dev",
    "Createdby"     = "Admin",
    "Orchestration" = "Terraform"
  })
}

module "eks" {
  source      = "./modules/eks"
  name        = "TEST"
  environment = "NonProd"

  # Create AWS EKS cluster
  enable_eks_cluster   = true
  eks_cluster_name     = "eks-test-cluster-1"
  eks_cluster_role_arn = module.iam_role.iam_role_arn

  eks_cluster_enabled_cluster_log_types = ["api", "audit"]
  eks_cluster_version                   = null

  eks_cluster_vpc_config = [
    {
      subnet_ids = module.vpc.private_subnets_ids

      public_access_cidrs     = null
      endpoint_private_access = true
      endpoint_public_access  = null
      security_group_ids      = null
    }
  ]

  eks_cluster_encryption_config = []

  # AWS EKS NodeGroup
  enable_eks_node_group          = true
  eks_node_group_node_group_name = "dev-1"
  eks_node_group_node_role_arn   = module.iam_role.iam_role_arn // only as for example!
  eks_node_group_subnet_ids      = module.vpc.private_subnets_ids

  eks_node_group_scaling_config = [
    {
      max_size     = 1
      desired_size = 1
      min_size     = 1
    }
  ]

  eks_node_group_ami_type       = "AL2_x86_64"
  eks_node_group_disk_size      = 20
  eks_node_group_instance_types = ["t3.medium"]

  eks_node_group_remote_access = [
    {
      ec2_ssh_key               = null
      source_security_group_ids = null
    }
  ]

  eks_node_group_launch_template = []
  eks_node_group_timeouts        = []

  tags = tomap({
    "Environment"   = "dev",
    "Createdby"     = "Admin",
    "Orchestration" = "Terraform"
  })
}
