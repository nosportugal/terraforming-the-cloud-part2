# data "kubectl_file_documents" "cert_manager" {
#   content = file("k8s/cert-manager/00-manifest.yaml")
# }

# resource "kubectl_manifest" "cert_manager" {
#   count     = length(data.kubectl_file_documents.cert_manager.documents)
#   yaml_body = element(data.kubectl_file_documents.cert_manager.documents, count.index)
# }

# resource "time_sleep" "cert_manager_webhook_ready" {
#   create_duration = "60s"

#   triggers = {
#     # This sets up a proper dependency on the RAM association
#     cert_manager_live_uid = kubectl_manifest.cert_manager[0].live_uid
#   }
# }

# # cert-manager letsencrypt cluster-issuer
# data "kubectl_path_documents" "cert_manager_letsencrypt" {
#   pattern = "k8s/cert-manager/20-letsencrypt-*.yaml"
#   vars = {
#     google_project      = data.google_project.this.project_id
#     project_owner_email = var.project_owner_email
#   }
# }

# resource "kubectl_manifest" "cert_manager_letsencrypt" {
#   count     = length(data.kubectl_path_documents.cert_manager_letsencrypt.documents)
#   yaml_body = element(data.kubectl_path_documents.cert_manager_letsencrypt.documents, count.index)

#   depends_on = [ 
#     time_sleep.cert_manager_webhook_ready
#   ]
# }


# # add service-account annotations, so that it can impersonate the gke_dns service account that was created
# resource "kubectl_manifest" "cert_manager_sa" {
#   yaml_body     = <<YAML
# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   name: cert-manager
#   namespace: "cert-manager"
#   annotations:
#     iam.gke.io/gcp-service-account: ${google_service_account.gke_dns.email}
#   labels:
#     app: cert-manager
#     app.kubernetes.io/component: "controller"
#     app.kubernetes.io/instance: cert-manager
#     app.kubernetes.io/name: cert-manager
# YAML
#   depends_on = [
#     time_sleep.cert_manager_webhook_ready
#   ]
# }