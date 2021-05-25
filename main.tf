
## terraform & providers
terraform {
  required_version = ">= 0.14.0"
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.69.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.9.4"
    }
  }
}

## referenciar um recurso já existente
## ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project
data "google_project" "this" {
  project_id = var.project_id
}

## local resources
locals {
  prefix = var.user_prefix
}