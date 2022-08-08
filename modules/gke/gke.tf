locals {
  gke = {
    cluster_name       = "${var.prefix}-gke"
    location           = var.location
    release_channel    = "REGULAR"
    min_master_version = "1.23"
    network            = data.google_compute_subnetwork.gke.network
    subnetwork         = data.google_compute_subnetwork.gke.self_link
  }
}

resource "google_container_cluster" "default" {
  project    = var.project_id
  name       = local.gke.cluster_name
  location   = local.gke.location
  network    = local.gke.network
  subnetwork = local.gke.subnetwork

  min_master_version = local.gke.min_master_version
  enable_autopilot   = true # esta flag indica que o cluster  vai ser instanciado em modo autopilot

  release_channel {
    channel = local.gke.release_channel
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = data.google_compute_subnetwork.gke.secondary_ip_range[0].range_name
    services_secondary_range_name = data.google_compute_subnetwork.gke.secondary_ip_range[1].range_name
  }

  private_cluster_config {
    enable_private_endpoint = false         # O cluster é publico
    enable_private_nodes    = true          # Os nodes do cluster são privados
    master_ipv4_cidr_block  = "10.0.1.0/28" # obrigatório quando nodes são privados
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
  }

  maintenance_policy {
    recurring_window {
      end_time   = "2020-04-11T05:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH"
      start_time = "2020-04-11T01:00:00Z"
    }
  }

  vertical_pod_autoscaling {
    enabled = true
  }
}
