## aqui criamos o namespace usando uma notação `heredoc`
resource "kubectl_manifest" "hipster_namespace" {
  wait      = true
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: hipster-demo
YAML
}

data "kubectl_path_documents" "hipster_workloads" {
  pattern = "${path.module}/k8s/1-*.yaml"
}

resource "kubectl_manifest" "hipster_workloads" {
  count     = length(flatten(toset([for f in fileset(".", data.kubectl_path_documents.hipster_workloads.pattern) : split("\n---\n", file(f))])))
  yaml_body = element(data.kubectl_path_documents.hipster_workloads.documents, count.index)

  depends_on = [
    kubectl_manifest.hipster_namespace
  ]
}

resource "kubectl_manifest" "hipster_loadgenerator" {
  yaml_body = file("${path.module}/k8s/200-loadgenerator.yaml")

  depends_on = [
    kubectl_manifest.hipster_workloads
  ]

  wait = true
}


