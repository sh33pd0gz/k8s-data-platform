provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.colima_profile
}

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = var.colima_profile
    insecure       = true
  }
}
