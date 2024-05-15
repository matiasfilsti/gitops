resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "6.7.18"
  namespace  = "argocd"
  timeout    = "1200"
  values     = [templatefile("./modules/argocd/values.yaml", {})]
}

resource "null_resource" "password" {
  depends_on = [helm_release.argocd]
  provisioner "local-exec" {
    working_dir = "./modules/argocd"
    command     = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > argocd-login.txt"
  }
}

resource "null_resource" "del-argo-pass" {
  depends_on = [null_resource.password]
  provisioner "local-exec" {
    command = "kubectl -n argocd delete secret argocd-initial-admin-secret"
  }
}
