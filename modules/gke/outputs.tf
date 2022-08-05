output "gke_default_endpoint" {
  value = google_container_cluster.default.endpoint
}

output "gke_ca_certificate" {
  value = google_container_cluster.default.master_auth[0].cluster_ca_certificate
  sensitive = true
}

output "gke_name" {
  value = google_container_cluster.default.name
}

output "gke_location" {
  value = google_container_cluster.default.location
}