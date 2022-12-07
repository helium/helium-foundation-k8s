locals {
  lb_role_name = "${local.cluster_name}-aws-load-balancer-controller"
}

resource "aws_iam_role" "lb" {
  name  = local.lb_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_url}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.oidc_url}:sub": "system:serviceaccount:default:lb"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lb" {
  name_prefix = local.lb_role_name
  role        = aws_iam_role.lb.name
  policy      = file("${path.module}/policies/lb.json")
}

resource "helm_release" "lbc" {
  name             = "aws-load-balancer-controller"
  chart            = "aws-load-balancer-controller"
  version          = "1.4.5"
  namespace = "default"
  repository       = "https://aws.github.io/eks-charts"
  create_namespace = true
  cleanup_on_fail  = true
  set {
    name = "clusterName"
    value = local.cluster_name
  }
  set {
    name = "serviceAccount.name"
    value = "lb"
  }
}

resource "kubectl_manifest" "nginx" {
  depends_on = [helm_release.argocd]
  count      = length(data.kubectl_path_documents.nginx.documents)
  yaml_body  = element(data.kubectl_path_documents.nginx.documents, count.index)
}
