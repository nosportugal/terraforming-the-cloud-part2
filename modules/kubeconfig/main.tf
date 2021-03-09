## Kubeconfig automatic generation
## More info: https://github.com/hashicorp/terraform-provider-kubernetes/tree/master/kubernetes/test-infra/gke

locals {
  kubeconfig_template = "./templates/kubeconfig-template.yaml"
  kubeconfig_filename = "kubeconfig.yaml"
}

data "google_project" "this" {
  project_id = var.project_id
}

data "google_container_cluster" "this" {
  name     = var.gke_name
  location = var.region
  project  = data.google_project.this.name
}


data "template_file" "kubeconfig" {
  template = file(local.kubeconfig_template)

  vars = {
    cluster_name    = data.google_container_cluster.this.name
    user_name       = data.google_container_cluster.this.master_auth[0].username
    user_password   = data.google_container_cluster.this.master_auth[0].password
    endpoint        = data.google_container_cluster.this.endpoint
    cluster_ca      = data.google_container_cluster.this.master_auth[0].cluster_ca_certificate
    client_cert     = data.google_container_cluster.this.master_auth[0].client_certificate
    client_cert_key = data.google_container_cluster.this.master_auth[0].client_key
    token           = ""
  }
}


resource "local_file" "kubeconfig" {
  sensitive_content = data.template_file.kubeconfig.rendered
  filename          = local.kubeconfig_filename
}


