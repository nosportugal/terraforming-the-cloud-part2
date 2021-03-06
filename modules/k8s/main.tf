terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

data "google_project" "this" {
  project_id = var.project_id
}


locals {
  fqdn = trim(var.fqdn, ".")
}

## hipster demo
resource "kubectl_manifest" "hipster_ns" {
  yaml_body = file("k8s/hipster-demo/00-namespace.yaml")
  wait      = true
}

data "kubectl_path_documents" "hipster_workloads" {
  pattern = "k8s/hipster-demo/1-*.yaml"
}

resource "kubectl_manifest" "hipster_workloads" {
  count     = length(flatten(toset([for f in fileset(".", data.kubectl_path_documents.hipster_workloads.pattern) : split("\n---\n", file(f))])))
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


