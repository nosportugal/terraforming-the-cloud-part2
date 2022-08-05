
## 2.4. K8s workloads
# module "hipster" {
#   source     = "./modules/hipster-demo"
#   project_id = data.google_project.this.id

#   ## 3.3 - Passar o FQDN do DNS para o modulo
#   # fqdn            = module.dns.fqdn
#   # ingress_enabled = true

#   depends_on = [
#     module.gke
#   ]
# }
