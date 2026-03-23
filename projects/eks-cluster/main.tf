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


resource "aws_iam_policy" "external_dns" {
  name = "ExternalDNSPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "route53:ChangeResourceRecordSets",
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_policy" "external_secrets" {
  name = "ExternalSecretsPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "secretsmanager:GetSecretValue"
      ],
      Resource = "*"
    }]
  })
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

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"

  values = [
    file("${path.module}/helm/external-dns-values.yaml")
  ]

  depends_on = [aws_eks_node_group.this]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  values = [
    file("${path.module}/helm/cert-manager-values.yaml")
  ]
}

resource "helm_release" "kube_prometheus" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [
    file("${path.module}/helm/prometheus-values.yaml")
  ]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  values = [
    file("${path.module}/helm/argocd-values.yaml")
  ]
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
}

resource "kubernetes_manifest" "letsencrypt" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "your-email@example.com"
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [{
          http01 = {
            ingress = {
              class = "nginx"
            }
          }
        }]
      }
    }
  }
}
