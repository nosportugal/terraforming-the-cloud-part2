/**
 * # stunner
 *
 * This module installs the [STUNner & CloudRetro: Cloudgaming and their nasty UDP streams in Kubernetes](https://github.com/l7mp/stunner/tree/main/examples/cloudretro).
 *
 */

resource "kubernetes_namespace" "cloudretro" {
  metadata {
    name = "cloudretro"
  }

  depends_on = [
    kubectl_manifest.gateway_config
  ]
}

data "kubectl_path_documents" "cloudretro" {
  pattern = "${path.module}/k8s/*.yaml"

  vars = {
    "fqdn" = var.fqdn
  }
}

resource "kubectl_manifest" "cloudretro" {
  count     = length(flatten(toset([for f in fileset(".", data.kubectl_path_documents.cloudretro.pattern) : split("\n---\n", file(f))])))
  yaml_body = element(data.kubectl_path_documents.cloudretro.documents, count.index)

  depends_on = [
    kubernetes_namespace.cloudretro
  ]
}


resource "time_sleep" "wait" {
  depends_on = [kubectl_manifest.cloudretro]

  create_duration = "15s"
}

resource "kubernetes_annotations" "udp_gateway" {
  api_version = "v1"
  kind        = "Service"
  metadata {
    name      = "stunner-gateway-udp-gateway-cloudretro-svc"
    namespace = "stunner"
  }
  annotations = {
    "external-dns.alpha.kubernetes.io/hostname" = "cloudretro-udp.${var.fqdn}"
  }

  depends_on = [
    time_sleep.wait
  ]
}

