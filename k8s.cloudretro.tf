##
## ⭐⭐ hidden bonus ⭐⭐
##
## Apenas descomenta quando acabares a demo toda
module "cloudretro" {
  source     = "./modules/cloudretro"
  fqdn       = module.dns.fqdn

  depends_on = [
    module.gke,
    module.dns
  ]
}

output "cloudretro_endpoint" {
  value = module.cloudretro.endpoint
}