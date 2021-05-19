locals {
  gke = {
    cluster_name    = "${var.prefix}-gke"
    region          = var.region
    release_channel = "STABLE"

    master_auth = {
      username = "administrator"
      password = random_password.gke.result
    }
  }
}

resource "google_container_cluster" "default" {
  name     = local.gke.cluster_name
  project  = data.google_project.this.name
  location = local.gke.region
  network                   = data.google_compute_subnetwork.gke.network
  subnetwork                = data.google_compute_subnetwork.gke.self_link
  default_max_pods_per_node = 64
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  #remove_default_node_pool = true
  initial_node_count       = 1
  remove_default_node_pool = false
  node_version = data.google_container_engine_versions.default.latest_node_version
  min_master_version = data.google_container_engine_versions.default.latest_node_version

  node_config {
    disk_size_gb    = 30
    disk_type       = "pd-standard"
    image_type      = "COS_CONTAINERD"
    local_ssd_count = 0
    machine_type    = "e2-standard-2" # gcloud compute machine-types list --zones=europe-west1-b --sort-by CPUS
    preemptible     = true
    metadata = {
      "disable-legacy-endpoints" = "true"
    }
    shielded_instance_config {
      enable_integrity_monitoring = false
      enable_secure_boot          = true
    }
  }

  release_channel {
    channel = "UNSPECIFIED"
  }
  cluster_autoscaling {
    enabled = false
  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/24"
  }
  # If this block is provided and both username and password are empty, basic authentication will be disabled. 
  # If this block is not provided, GKE will generate a password for you with the username admin.
  master_auth {
    username = local.gke.master_auth.username
    password = local.gke.master_auth.password
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  private_cluster_config {
    enable_private_endpoint = false         # O cluster é publico
    enable_private_nodes    = true          # Os nodes do cluster são privados
    master_ipv4_cidr_block  = "10.0.1.0/28" # obrigatório quando nodes são privados
  }
  vertical_pod_autoscaling {
    enabled = true
  }
  workload_identity_config {
    identity_namespace = "${data.google_project.this.project_id}.svc.id.goog"
  }
}

data "google_container_engine_versions" "default" {
  project  = data.google_project.this.name
  location       = local.gke.region
  version_prefix = "1.18."
}