
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
  for_each = local.environments
  source = "./modules/argocd-configureation"
  sourceRepos = each.values.sourceRepos
  env = each.key
  projectname = each.values.projectname
  }