resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd-${var.env}"
  }
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }
}

resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd-staging"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "6.7.18"
  namespace  = "argocd-${var.env}"
  timeout    = "1200"
  values     = [templatefile("./modules/argocd/values.yaml", {})]
}

resource "null_resource" "password" {
  depends_on = [helm_release.argocd]
  provisioner "local-exec" {
    working_dir = "./modules/argocd"
    command     = "kubectl -n argocd-${var.env} get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > argocd-login.txt"
  }
}

resource "null_resource" "del-argo-pass" {
  depends_on = [null_resource.password]
  provisioner "local-exec" {
    command = "kubectl -n argocd-staging delete secret argocd-initial-admin-secret"
  }
}


resource "kubernetes_manifest" "argo_project_test" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "AppProject"
    "metadata" = {
      "name"      = "app-go-test"
      "namespace" = "argocd-${var.env}"
      "finalizers" = "resources-finalizer.argocd.argoproj.io"
    }
    "spec" = {
      "sourceRepos" = "https://github.com/matiasfilsti/gitops-argocd.git"
      "destinations" = {
        "namespace" = "staging"
        "server" = "*"
      }
      "roles" = {
        "name" = "test-access"
        "description" = "Only for test access"
        "policies" = "p, proj:app-go-test:, *, app-test-go-test/*, allow"

      }
    }
  }
}


resource "kubernetes_manifest" "argo_project_prod" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "AppProject"
    "metadata" = {
      "name"      = "app-go-prod"
      "namespace" = "argocd-${var.env}"
      "finalizers" = "resources-finalizer.argocd.argoproj.io"
    }
    "spec" = {
      "sourceRepos" = "https://github.com/matiasfilsti/gitops-argocd.git"
      "destinations" = {
        "namespace" = "production"
        "server" = "*"
      }
      "roles" = {
        "name" = "test-access"
        "description" = "Only for test access"
        "policies" = "p, role:test-access, *, app-test-go-test/*, allow"

      }
    }
  }
}