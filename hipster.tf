
## 2.4. K8s workloads
module "hipster" {
  source     = "./modules/hipster-demo"
  project_id = data.google_project.this.id
  ## 3.2 - Passar o FQDN do DNS para o modulo
  #fqdn                    = module.dns.fqdn

  ## TODO: apagar
  ##sa_gke_dns = var.sa_gke_dns

  depends_on = [
    module.gke
  ]
}
