## 2.3. Utilizar modules dentro de modules
module "kubeconfig" {
  source     = "../kubeconfig"
  project_id = data.google_project.this.id
  gke_name   = google_container_cluster.default.name
  region     = google_container_cluster.default.location

  # wtf? Ask me about this 😉
  depends_on = [ google_container_cluster.default ]
}

output "gke_kubeconfig" {
  value = module.kubeconfig.gke_kubeconfig
}