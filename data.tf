data "kubectl_path_documents" "nginx" {
  pattern = "./lb/ingress-nginx.yaml"
  vars = {
    cert = var.zone_cert
    cidr = var.cidr_block
  }
}

data "aws_eks_cluster" "eks" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = local.cluster_name
}

data "aws_caller_identity" "current" {}

data "kubectl_path_documents" "application" {
  pattern = "./argocd/application.yaml"
}

data "aws_iam_role" "rds_hf_user_access_role" {
  name = "rds_hf_user_access_role" 
}