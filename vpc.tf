## VPC registry:  https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
## VPC can be viewed here: https://console.cloud.google.com/networking/networks/list?folder=&organizationId=&project=tf-gke-lab-01-np-000001

### 1. Criação da VPC e SUBNET default
resource "google_compute_network" "default" {
  project                         = data.google_project.this.name
  name                            = "${local.prefix}-vpc-default"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "default" {
  name                     = "${local.prefix}-subnet-default"
  network                  = google_compute_network.default.self_link
  ip_cidr_range            = "10.0.10.0/24"
  region                   = var.region
  project                  = google_compute_network.default.project
  private_ip_google_access = true
}


# ## 2.1. Subnet para o GKE
resource "google_compute_subnetwork" "gke" {
  name                     = "${local.prefix}-subnet-gke"
  network                  = google_compute_network.default.self_link
  ip_cidr_range            = "10.0.11.0/24"
  region                   = var.region
  project                  = google_compute_network.default.project
  private_ip_google_access = true
}