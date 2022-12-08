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

resource "kubernetes_service_account" "rds_mobile_oracle_user_access" {
  metadata {
    name        = "rds-mobile-oracle-user-access"
    namespace   = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.rds_mobile_oracle_user_access_role.arn,
    }
  }
}

resource "kubernetes_service_account" "rds_active_device_oracle_user_access" {
  metadata {
    name        = "rds-active-device-oracle-user-access"
    namespace   = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.rds_active_device_oracle_user_access_role.arn,
    }
  }
}