## DNS management
locals {
  fqdn = "${var.prefix}.${data.google_dns_managed_zone.lab_01_clg_nos_pt.dns_name}"
  dns = {
    parent_zone_name = "dns-lab-01"
  }
}


data "google_project" "this" {
  project_id = var.project_id
}

## Esta é a zona parent: lab-01.clg.nos.pt
## É nesta zona que iremos criar sub-zonas, uma para cada aluno
data "google_dns_managed_zone" "lab_01_clg_nos_pt" {
  name    = local.dns.parent_zone_name
  project = data.google_project.this.name
}

# Esta é a zona que irás usar, o nome varia consoante o teu prefixo
# mas será algo tipo my-prefix.lab-01.clg.nos.pt
resource "google_dns_managed_zone" "this" {
  name     = "${var.prefix}-dns"
  dns_name = local.fqdn
  project  = data.google_project.this.name

  # Set this true to delete all records in the zone.
  force_destroy = true
}

# parent zone - NS records for the child zone
# gcloud dns record-sets list -z cloud-demo-zone --project poc-anthos-on-prem
resource "google_dns_record_set" "parent_ns" {
  managed_zone = data.google_dns_managed_zone.lab_01_clg_nos_pt.name
  project      = data.google_dns_managed_zone.lab_01_clg_nos_pt.project
  
  name         = local.fqdn
  type         = "NS"
  ttl          = 300
  rrdatas      = google_dns_managed_zone.this.name_servers
}
