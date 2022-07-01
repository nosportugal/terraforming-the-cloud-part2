
## 2.4. K8s workloads
module "k8s" {
  source     = "./modules/k8s"
  project_id = data.google_project.this.id
  ## 3.2 - Passar o FQDN do DNS para o modulo
  fqdn                    = module.dns.fqdn
  sa_gke_dns              = var.sa_gke_dns

  depends_on = [
    module.gke.gke_default_node_pool
  ]
}
