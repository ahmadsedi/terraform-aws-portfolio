# EKS Cluster Deployment with Terraform

## Overview
This project provisions a production-style AWS EKS cluster and deploys applications using Helm.

## Architecture
- EKS Control Plane (managed)
- Worker Nodes (Node Group)
- IAM Roles (cluster + nodes)
- Helm deployment (NGINX Ingress)

## Features
- Managed Kubernetes cluster
- Auto-scaling node group
- Helm integration via Terraform
- IAM best practices

## Usage

### 1. Provide subnet IDs
Use subnets from your VPC project.

### 2. Run Terraform
```bash
terraform init
terraform apply
```

## Production Features
- Private subnets for worker nodes
- NAT Gateway for outbound traffic
- IRSA for fine-grained IAM permissions
- AWS Load Balancer Controller (ALB)
- Multi-AZ deployment
- Kubernetes-ready networking


## Advanced Platform Features
- External DNS (Route53 automation)
- Cert Manager (automatic TLS via Let’s Encrypt)
- Prometheus + Grafana monitoring stack
- ArgoCD GitOps deployment

This setup represents a production-ready Kubernetes platform.

## Platform Capabilities
This platform demonstrates:

- Private Kubernetes cluster (no public API exposure)
- GitOps deployment using ArgoCD (App of Apps pattern)
- Secure secrets management via AWS Secrets Manager
- Automated DNS + TLS (ExternalDNS + Cert Manager)
- Full observability stack (Prometheus + Grafana)
- CI/CD pipeline integrated with GitHub Actions