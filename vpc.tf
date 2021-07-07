## VPC registry:  https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
## VPC can be viewed here: https://console.cloud.google.com/networking/networks/list?folder=&organizationId=&project=tf-gke-lab-01-np-000001

## 1. Criação da VPC
# resource "google_compute_network" "default" {
#   project                         = data.google_project.this.name
#   name                            = "${local.prefix}-vpc-default"
#   auto_create_subnetworks         = false
#   delete_default_routes_on_create = false
# }


## 2.1. Subnet e NAT para o GKE
# resource "google_compute_subnetwork" "gke" {
#   name                     = "${local.prefix}-subnet-gke"
#   network                  = google_compute_network.default.self_link
#   ip_cidr_range            = "10.0.11.0/24"
#   region                   = var.region
#   project                  = google_compute_network.default.project
#   private_ip_google_access = true
# }

# resource "google_compute_router" "default" {
#   project = data.google_project.this.name
#   name    = "${local.prefix}-router"
#   region  = google_compute_subnetwork.gke.region
#   network = google_compute_network.default.id
# }

# resource "google_compute_router_nat" "default" {
#   project = data.google_project.this.name
#   name                               = "${local.prefix}-nat"
#   router                             = google_compute_router.default.name
#   region                             = google_compute_router.default.region
#   nat_ip_allocate_option             = "AUTO_ONLY"
#   source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
# }