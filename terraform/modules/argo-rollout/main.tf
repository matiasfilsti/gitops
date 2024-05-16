
resource "kubernetes_namespace" "argo-namespace" {
  metadata {
    name = "argo-rollouts"
  }
}

resource "helm_release" "argocd" {
  name       = "argo-rollouts"
  chart      = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "2.35.2"
  namespace  = "argo-rollouts"
  timeout    = "1200"
  values     = [templatefile("./modules/argo-rollout/values.yaml", {})]
  skip_crds  = false
}
