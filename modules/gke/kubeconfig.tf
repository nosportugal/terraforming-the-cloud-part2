## 2.3. Utilizar modules dentro de modules
# module "kubeconfig" {
#   source     = "../kubeconfig"
#   project_id = data.google_project.this.id
#   gke_name   = google_container_cluster.default.name
#   location   = google_container_cluster.default.location
# }

# output "gke_kubeconfig_filename" {
#   value = module.kubeconfig.gke_kubeconfig_filename
# }
