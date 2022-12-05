resource "helm_release" "argocd" {
  name  = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "5.8.3"
  create_namespace = true

  set {
    name = "server.insecure"
    value = "true"
  }

  set {
    name = "configs.params.server\\.insecure"
    value = "true"
  }

  set {
    name = "server.ingress.enabled"
    value = "true"
  }

  set {
    name = "server.ingress.hosts[0]"
    value = var.argo_url
  }

  set {
    name = "server.ingress.ingressClassName"
    value = "nginx"
  }

  set {
    name = "server.repo.server.strict.tls"
    value = "true"
  }

  set {
    name = "server.service.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
    value = var.argo_url
  }
}

data "kubectl_path_documents" "application" {
    pattern = "./argocd/application.yaml"
}

resource "kubectl_manifest" "argocd" {
  depends_on = [helm_release.argocd]
  count      = length(data.kubectl_path_documents.application.documents)
  yaml_body  = element(data.kubectl_path_documents.application.documents, count.index)
}
