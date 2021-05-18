
## 2.4. K8s workloads
module "k8s" {
  source                  = "./modules/k8s"
  fqdn                    = module.dns.fqdn
  gke_kubeconfig_filename = module.gke.gke_kubeconfig_filename
  sa_gke_dns              = var.sa_gke_dns
}
