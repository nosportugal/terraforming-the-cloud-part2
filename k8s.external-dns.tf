# 3.2 Habilitar o external-dns
module "external_dns" {
  source     = "./modules/external-dns"
  project_id = data.google_project.this.id
  fqdn       = module.dns.fqdn
  sa_gke_dns = var.sa_gke_dns

  depends_on = [
    module.gke,
    module.dns
  ]
}
