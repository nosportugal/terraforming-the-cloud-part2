data "google_service_account" "gke_dns" {
  account_id = var.sa_gke_dns
}

## external-dns
data "kubectl_path_documents" "external_dns" {
  pattern = "k8s/external-dns/00-manifest.yaml"

  vars = {
    dns_service_account = data.google_service_account.gke_dns.email
  }

}

resource "kubectl_manifest" "external_dns" {
  count     = length(data.kubectl_path_documents.external_dns.documents)
  yaml_body = element(data.kubectl_path_documents.external_dns.documents, count.index)

  wait = true
}