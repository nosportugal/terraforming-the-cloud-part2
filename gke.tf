## 2.2. GKE module
# module "gke" {
#   source     = "./modules/gke"
#   project_id = var.project_id
#   location   = coalesce(var.gke_location, var.region)
#   prefix     = local.prefix
#   vpc_subnet = google_compute_subnetwork.gke.self_link
# }

# output "gke_name" {
#   value = module.gke.gke_name
# }

# output "gke_location" {
#   value = module.gke.gke_location
# }