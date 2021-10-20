variable "tags" {
  description = "A map of tags (key-value) passed to resources."
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster, will be lookup-ed"
}

variable "ec2_ssh_key" {
  type        = string
  description = "(not recommended - consider ssm) SSH key name that should be used to access the worker nodes"
  default     = null
}

variable "desired_size" {
  type        = number
  description = "Desired number of worker nodes"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "Maximum number of worker nodes"
  default     = 3
}

variable "min_size" {
  type        = number
  description = "Minimum number of worker nodes"
  default     = 1
}

variable "subnet_ids" {
  description = "A list of subnet IDs to launch resources in"
  type        = list(string)
}

variable "node_role_arn" {
  type        = string
  description = "IAM role arn that will be used by managed node group, consider passing externally created"
  default     = ""
}

variable "ami_type" {
  type        = string
  description = "(optional) Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Valid values: `AL2_x86_64`, `AL2_x86_64_GPU`."
  default     = null
}

variable "disk_size" {
  type        = number
  description = "Disk size in GiB for worker nodes. Defaults to 20. Terraform will only perform drift detection if a configuration value is provided"
  default     = null
}

variable "instance_types" {
  type        = list(string)
  description = "List of instance types associated with the EKS Node Group. Consider passing list for spot groups"
  default     = null
}

variable "kubernetes_labels" {
  type        = map(string)
  description = "Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed"
  default     = {}
}

variable "ami_release_version" {
  type        = string
  description = "AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version"
  default     = null
}

variable "source_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Set of EC2 Security Group IDs to allow SSH access (port 22) from on the worker nodes. If you specify `ec2_ssh_key`, but do not specify this configuration when you create an EKS Node Group, port 22 on the worker nodes is opened to the Internet (0.0.0.0/0)"
}

variable "node_group_name" {
  type        = string
  description = "The name of the cluster node group. Defaults to <cluster_name>-<random value>"
  default     = ""
}

variable "create_iam_role" {
  type        = bool
  description = "Create IAM role for node group. Set to true if you for some reason need to create node_role_arn with this module. Not recommended."
  default     = false
}

variable "node_group_role_name" {
  type        = string
  description = "(optional) The name of the cluster node group role. Defaults to <cluster_name>-managed-group-node"
  default     = ""
}

variable "force_update_version" {
  type        = bool
  description = "(optional) Force version update if existing pods are unable to be drained due to a pod disruption budget issue."
  default     = false
}

variable "launch_template" {
  type        = map(string)
  description = "(optional) Configuration block with Launch Template settings. `name`, `id` and `version` parameters are available."
  default     = {}
}

variable "capacity_type" {
  type        = string
  description = "Type of capacity associated with the EKS Node Group. Defaults to ON_DEMAND. Valid values: ON_DEMAND, SPOT."
  default     = "SPOT"
}