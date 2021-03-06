variable "AWS_REGION" {
  default = "us-east-1"
}

variable "SCALING_DESIRED_CAPACITY" {
  default = 2
}

 variable "cluster_name" {
   default = "istio"

 }

variable "cluster_version" {
  default     = "1.18"
  description = "Version of the kubernetes cluster"
}

variable "enable_irsa" {
  description = "Whether to create OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = true
}

variable "availabilityzone" {
   default = "us-east-1a"
}

variable "availabilityzone2" {
   default = "us-east-1b"
}


variable "common_tags" {
     type = map
     default =  {
     "kubernetes.io/cluster"                       = "myproject"
     "SupportTeam"                                = "PlatformEngineering"
     "Contact"                                     = "group@example.com"
  
  
  } 
}

locals {

  ec2_principal = "ec2.${data.aws_partition.current.dns_suffix}"
  sts_principal = "sts.${data.aws_partition.current.dns_suffix}"

  oidc_provider_arn = var.enable_irsa ? concat(aws_iam_openid_connect_provider.oidc_provider[*].arn, [""])[0] : null

  cluster_oidc_issuer_url = flatten(concat(aws_eks_cluster.eks-cluster.identity[*].oidc.0.issuer, [""]))[0]

}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.11.0.0/16"
}

// Primary pair of public/private networks

variable "use_simple_vpc" {
  default     = true
  type        = bool
  description = ""
}

variable "public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default     = "10.11.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the Private Subnet"
  default     = "10.11.1.0/24"
}

// Secondary pair of public/private networks (if you ever needed that)

variable "public_subnet_cidr2" {
  description = "CIDR for the Public Subnet"
  default     = "10.11.2.0/24"
}

variable "private_subnet_cidr2" {
  description = "CIDR for the Private Subnet"
  default     = "10.11.3.0/24"
}

variable "eks_oidc_root_ca_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

# ingress

variable "option_alb_ingress_enabled" {
  default = false

}

variable "ingress_alb_helm_chart_name" {
  type    = string
  default = "aws-load-balancer-controller"
}

variable "ingress_alb_helm_chart_version" {
  type    = string
  default = "1.0.3"
}

variable "ingress_alb_helm_release_name" {
  type    = string
  default = "aws-load-balancer-controller"
}

variable "ingress_alb_helm_repo_url" {
  type    = string
  default = "https://aws.github.io/eks-charts"
}

variable "ingress_alb_k8s_namespace" {
  type = string
  # kube-system is recommended over alb-ingress
  # per https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
  default     = "kube-system"
  description = "The k8s namespace in which the alb-ingress service account has been created"
}

variable "ingress_alb_k8s_service_account_name" {
  type        = string
  default     = "aws-load-balancer-controller"
  description = "The k8s alb-ingress service account name, should match to helm chart expectations"
}


variable "ingress_alb_k8s_dummy_dependency" {
  default     = null
  description = "TODO: eliminate allows dirty re-drop"
}

variable "ingress_alb_settings" {
  type        = map(any)
  default     = {}
  description = "Additional settings for Helm chart check https://artifacthub.io/packages/helm/helm-incubator/aws-alb-ingress-controller"
}


# /ingress

# external dns

variable "option_external_dns_enabled" {
  default = false
  type    = bool
}

variable "external_dns_helm_chart_name" {
  type    = string
  default = "external-dns"
}

variable "external_dns_helm_chart_version" {
  type    = string
  default = "3.5.1"
}

variable "external_dns_helm_release_name" {
  type    = string
  default = "external-dns"
}

variable "external_dns_helm_repo_url" {
  type    = string
  default = "https://charts.bitnami.com/bitnami"
}

variable "external_dns_k8s_namespace" {
  type        = string
  default     = "kube-system"
  description = "The k8s namespace in which the alb-ingress service account has been created"
}

variable "external_dns_k8s_service_account_name" {
  type        = string
  default     = "external-dns"
  description = "The k8s external-dns service account name, ideally should match to helm chart expectations"
}



variable "external_dns_settings" {
  type        = map(any)
  default     = {}
  description = "Additional settings for external-dns helm chart check https://github.com/bitnami/charts/tree/master/bitnami/external-dns"
}
# /external dns


# Application specific variables

variable "domain" {
  default = ""
}

variable "namespaces" {
  type        = list(string)
  description = "List of namespaces to be created in our EKS Cluster."
  default     = []
}

# /Application specific variables
