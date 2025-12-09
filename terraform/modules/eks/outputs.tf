output "cluster_name" {
  value = aws_eks_cluster.cluster.name
}

output "nodegroup_name" {
  value = aws_eks_node_group.node_group.node_group_name
}

output "cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value = aws_eks_cluster.cluster.endpoint
}