
## 3.2 Habilitar o external-dns
# data "google_service_account" "gke_dns" {
#   account_id = var.sa_gke_dns
# }

# resource "kubernetes_namespace" "external_dns" {
#   metadata {
#     name = "external-dns"
#   }
# }

# resource "helm_release" "external_dns" {
#   name             = "external-dns"
#   repository       = "https://kubernetes-sigs.github.io/external-dns"
#   chart            = "external-dns"
#   version          = "1.9.0"
#   namespace        = kubernetes_namespace.external_dns.metadata[0].name
#   wait_for_jobs    = true
#   create_namespace = false

#   values = [
#     <<YAML
#   serviceAccount:
#     create: true
#     annotations:
#       iam.gke.io/gcp-service-account: ${data.google_service_account.gke_dns.email}
#     name: external-dns

#   sources:
#     - ingress
#     - service

#   extraArgs:
#     - --google-zone-visibility=public

#   podLabels:
#     app: external-dns

#   resources:
#     requests:
#       memory: 50Mi
#       cpu: 10m
#     limits:
#       memory: 200Mi

#   domainFilters:
#   - ${local.fqdn}

#   txtOwnerId: ${var.project_id}/external-dns
#   policy: sync
#   registry: txt
#   provider: google
#   YAML
#   ]
# }
