


terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.9.4"
    }
  }
}

locals {
  gke_kubeconfig_filename = var.gke_kubeconfig_filename
  fqdn = trim(var.fqdn, ".")
  kube_ingress_manifest = "templates/hipster-ingress-template.yaml"
}

# usar o kubectl provider através de um kubeconfig
provider "kubectl" {
  config_path    = local.gke_kubeconfig_filename
  load_config_file = true
}


## usar o kubectl provider através do certificado - NÃO DESCOMENTAR: exemplo apenas
# data "google_client_config" "this" {}
# provider "kubectl" {
#   host                   = module.gke.gke_default_endpoint
#   cluster_ca_certificate = base64decode(module.gke.gke_ca_certificate)
#   token                  = data.google_client_config.this.access_token
#   load_config_file = false
# }


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
}


## Ingress part
data "kubectl_path_documents" "hipster_ingress" {
  pattern = "templates/hipster-ingress-template.yaml"
  vars = {
    fqdn = local.fqdn
  }
}

resource "kubectl_manifest" "hipster_ingress" {
  count     = length(data.kubectl_path_documents.hipster_ingress.documents)
  yaml_body = element(data.kubectl_path_documents.hipster_ingress.documents, count.index)

  depends_on = [
    kubectl_manifest.hipster_workloads
  ]
}