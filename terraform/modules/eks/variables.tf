variable "project_name" {
  description = "Name prefix for resources"
  type = string
}

variable "cluster_name" {
  description = "Name of the cluster"
  type = string
  default = "cluster"
}

variable "cluster_version" {
  description = "kubernetes version for the EKS cluster"
  type = string
  default = "1.34"
}

variable "vpc_id" {
  description = "ID of the VPC where EKS will be deployed"
  type = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDS for worker nodes and cluster endpoint"
  type = list(string)
}

variable "node_instance_type" {
  description = "Instance types for the worker nodes"
  type = string
  default = "t3.small"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type = number
  default = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type = number
  default = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type = number
  default = 3
}
