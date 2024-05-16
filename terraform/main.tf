### before everything, download latest crds from https://github.com/argoproj/argo-cd/tree/master/manifests/crds. ###
### execute kubectl apply -k . in argocd/crds folder                                                             ###
###  https://github.com/argoproj/argo-helm/discussions/1476                                                      ###

locals {
  environments = {
    "staging" =  {sourceRepos = "https://github.com/matiasfilsti/gitops-argocd.git",  projectname = "app-go-stg"},
    "production" =  {sourceRepos = "https://github.com/matiasfilsti/gitops-argocd.git",  projectname = "app-go-prod"}
  }

}

module "argocd" {
  source = "./modules/argocd"
  }

module "argocd-config" {
  execute = false
  depends_on = [module.argocd]
  for_each = local.environments
  source = "./modules/argocd-configuration"
  sourceRepos = each.value.sourceRepos
  env = each.key
  projectname = each.value.projectname
  }

  module "argo-rollout" {
  source = "./modules/argo-rollout"
  }