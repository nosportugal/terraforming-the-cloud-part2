
## terraform & providers
terraform {
  required_version = ">= 0.14.0"
  backend "local" {
    path = "terraform.tfstate"
  }
  # backend "artifactory" {
  #   url = "https://artifactory.nosinovacao.pt/artifactory"
  #   repo = "terraform-ccoe"
  #   subpath = "labs/tf-gke-lab-01"
  # }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.58.0"
    }
  }
}


## referenciar um recurso já existente
## ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project
data "google_project" "this" {
  project_id = var.project_id
}

## local resources
resource "random_pet" "this" {
  length = 2
  separator = "-"
}

locals {
  prefix = random_pet.this.id
}

# ## remote resources
# ## google_service_account doc: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
# resource "google_service_account" "default" {
#   account_id = "${random_pet.this.id}-sa-1"
#   display_name = "random_pet.this.id"
#   project = data.google_project.this.project_id
# }