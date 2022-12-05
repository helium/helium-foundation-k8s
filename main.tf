terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.36.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.14.0"
    }
    local = {
      version = "~> 2.1"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.11.3"
    }
  }
}
