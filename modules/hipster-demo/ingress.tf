# 3.3 - Deploy de ingress
data "kubectl_path_documents" "hipster_ingress" {
  pattern = "k8s/hipster-demo/300-hipster-ingress.yaml"
  vars = {
    fqdn = var.fqdn
  }
}

resource "kubectl_manifest" "hipster_ingress" {
  count     = var.ingress_enabled ? length(flatten(toset([for f in fileset(".", data.kubectl_path_documents.hipster_ingress.pattern) : split("\n---\n", file(f))]))) : 0
  yaml_body = element(data.kubectl_path_documents.hipster_ingress.documents, count.index)

  depends_on = [
    kubectl_manifest.hipster_workloads
  ]
}
