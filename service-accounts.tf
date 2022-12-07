resource "kubernetes_service_account" "lb" {
  metadata {
    name      = "lb"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lb.arn,
      "meta.helm.sh/release-name" = "aws-load-balancer-controller",
      "meta.helm.sh/release-namespace" = "default",
    }
    labels = {
      "app.kubernetes.io/managed-by" = "Helm",
    }
  }
  automount_service_account_token = true
}

resource "kubernetes_service_account" "rds-hf-user-access" {
  metadata {
    name        = "rds-hf-user-access"
    namespace   = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.rds_hf_user_access_role.arn,
    }
  }
}