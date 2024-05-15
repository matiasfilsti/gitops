
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