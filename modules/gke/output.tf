output "gke_default_node_version" {
  value = google_container_cluster.default.node_version
}

output "gke_default_endpoint" {
  value = google_container_cluster.default.endpoint
}

output "gke_ca_certificate" {
  value = google_container_cluster.default.master_auth[0].cluster_ca_certificate
  sensitive = true
}