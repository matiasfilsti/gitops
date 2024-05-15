
resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "${var.env}"
  }
}


resource "kubernetes_manifest" "argo_project" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "AppProject"
    "metadata" = {
      "name"      = var.projectname
      "namespace" = "argocd"
    }
    "spec" = {
      "sourceRepos" = [var.sourceRepos]
      "destinations" = [{
        "namespace" = kubernetes_namespace.namespace.metadata[0].name
        "server" = "*"
      }]
    }
  }
}