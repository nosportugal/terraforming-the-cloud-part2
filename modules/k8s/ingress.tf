## 3.3 - Deploy de ingress
# data "kubectl_path_documents" "hipster_ingress" {
#   pattern = "k8s/hipster-demo/300-hipster-ingress.yaml"
#   vars = {
#     fqdn = local.fqdn
#   }
# }

# resource "kubectl_manifest" "hipster_ingress" {
#   count     = length(data.kubectl_path_documents.hipster_ingress.documents)
#   yaml_body = element(data.kubectl_path_documents.hipster_ingress.documents, count.index)

#   depends_on = [
#     kubectl_manifest.hipster_workloads
#   ]
# }