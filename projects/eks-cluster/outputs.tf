output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "private_subnet_ids" {
  description = "IDs of the private subnets for EKS nodes"
  value       = aws_subnet.private[*].id
}