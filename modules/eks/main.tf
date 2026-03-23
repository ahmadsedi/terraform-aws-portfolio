resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = var.role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}