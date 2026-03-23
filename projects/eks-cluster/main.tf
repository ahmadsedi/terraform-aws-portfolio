locals {
  name = "${var.project_name}-${var.environment}"
}

# -------------------
# IAM Role for EKS
# -------------------
resource "aws_iam_role" "eks_cluster" {
  name = "${local.name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# -------------------
# EKS Cluster
# -------------------
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = aws_subnet.private[*].id
  }
}

# -------------------
# Node Group Role
# -------------------
resource "aws_iam_role" "node_group" {
  name = "${local.name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "registry_policy" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# -------------------
# Node Group
# -------------------
resource "aws_eks_node_group" "this" {
  cluster_name  = aws_eks_cluster.this.name
  node_role_arn = aws_iam_role.node_group.arn
  subnet_ids    = aws_subnet.private[*].id

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 4
  }

  instance_types = [var.node_instance_type]

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy
  ]
}

# -------------------
# Helm Deployment (NGINX)
# -------------------
resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  values = [
    file("${path.module}/helm/nginx-values.yml")
  ]

  depends_on = [aws_eks_node_group.this]
}

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  values = [
    file("${path.module}/helm/alb-values.yml")
  ]

  depends_on = [aws_eks_node_group.this]
}