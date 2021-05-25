## preparar alguns objectos que vamos precisar
##  também poderiamos faze-lo sem referenciando diretamente os valores, 
##  mas ter os objectos da-nos acesso o modelo de dados

data "google_project" "this" {
  project_id = var.project_id
}

data "google_compute_subnetwork" "gke" {
  self_link = var.vpc_subnet
}