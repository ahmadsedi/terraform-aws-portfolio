variable "region" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }

variable "cluster_name" {
  default = "tf-eks-cluster"
}

variable "node_instance_type" {
  default = "t3.medium"
}

variable "desired_capacity" {
  default = 2
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS cluster"
  type        = list(string)
}