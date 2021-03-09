output "gke_kubeconfig" {
  value = "export KUBECONFIG=$(pwd)/${local.kubeconfig_filename}"
}