output "gke_kubeconfig" {
  value = "export KUBECONFIG=${local.kubeconfig_filename}"
}

# output "gke_kubeconfig" {
#   value = "export KUBECONFIG=$(pwd)/${local.kubeconfig_filename} && gcloud container clusters get-credentials ${data.google_container_cluster.this.name} --region ${data.google_container_cluster.this.location} --project ${data.google_container_cluster.this.project}"
# }