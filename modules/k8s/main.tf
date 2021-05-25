terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.11.1"
    }
  }
}

data "google_project" "this" {
  project_id = var.project_id
}


locals {
  fqdn = trim(var.fqdn, ".")
  gke_default_endpoint = var.gke_default_endpoint
  gke_ca_certificate = var.gke_ca_certificate
}

## usar o kubectl provider através do certificado - NÃO DESCOMENTAR: exemplo apenas
data "google_client_config" "this" {}
provider "kubectl" {
  host                   = local.gke_default_endpoint
  cluster_ca_certificate = base64decode(local.gke_ca_certificate)
  token                  = data.google_client_config.this.access_token
  load_config_file = false
}


## hipster demo
resource "kubectl_manifest" "hipster_ns" {
  yaml_body = file("k8s/hipster-demo/00-namespace.yaml")
  wait = true
}

data "kubectl_path_documents" "hipster_workloads" {
  pattern = "k8s/hipster-demo/1-*.yaml"
}

resource "kubectl_manifest" "hipster_workloads" {
  count     = length(data.kubectl_path_documents.hipster_workloads.documents)
  yaml_body = element(data.kubectl_path_documents.hipster_workloads.documents, count.index)
  
  depends_on = [
    kubectl_manifest.hipster_ns
  ]
}

resource "kubectl_manifest" "hipster_loadgenerator" {
  yaml_body = file("k8s/hipster-demo/200-loadgenerator.yaml")

  depends_on = [
    kubectl_manifest.hipster_workloads
  ]

  wait = true
}


