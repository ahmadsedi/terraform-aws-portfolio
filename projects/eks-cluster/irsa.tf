data "aws_iam_policy_document" "alb_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_eks_cluster.this.identity[0].oidc[0].issuer]
    }
  }
}

resource "aws_iam_role" "alb_irsa" {
  name               = "alb-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.alb_assume_role.json
}