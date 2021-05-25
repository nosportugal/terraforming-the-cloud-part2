
## 2.4. K8s workloads
# module "k8s" {
#   source     = "./modules/k8s"
#   project_id = data.google_project.this.id
#   ## 3.2 - Passar o FQDN do DNS para o modulo
#   #fqdn                    = module.dns.fqdn
#   sa_gke_dns              = var.sa_gke_dns
#   gke_ca_certificate      = module.gke.gke_ca_certificate
#   gke_default_endpoint    = module.gke.gke_default_endpoint
#   gke_default_node_pool   = module.gke.gke_default_node_pool
# }
