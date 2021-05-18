module "k8s" {
  source                  = "./modules/k8s"
  fqdn                    = module.dns.fqdn
  gke_kubeconfig_filename = module.gke.gke_kubeconfig_filename
}
