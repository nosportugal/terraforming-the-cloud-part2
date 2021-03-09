## 3.1. Descomentar para ativar o modulo de DNS
# module "dns" {
#   source     = "./modules/dns"
#   project_id = data.google_project.this.id
#   prefix     = local.prefix
# }

# output "fqdn" {
#   value = module.dns.fqdn
# }