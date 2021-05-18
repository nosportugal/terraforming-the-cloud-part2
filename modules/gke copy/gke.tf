locals {
  gke = {
    cluster_name    = "${var.prefix}-gke"
    region          = var.region
    release_channel = "STABLE"

    master_auth = {
      username = "administrator"
      password = random_password.gke.result
    }

    workload_identity_config = {
      identity_namespace = "${data.google_project.this.project_id}.svc.id.goog"
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
  initial_node_count       = 2

  node_config {
    # https://cloud.google.com/compute/docs/machine-types
    machine_type = "e2-standard-2"
    image_type   = "cos_containerd"
  }

  release_channel {
    channel = "STABLE"
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

  network_policy {
    enabled = false
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
    identity_namespace = local.gke.workload_identity_config.identity_namespace
  }

  lifecycle {
    ## Se repararem nisto e eu não explicar, por favor avisem 😅
    ignore_changes = [
      node_pool,
      node_config
    ]
  }
}


