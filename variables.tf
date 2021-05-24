## project related
variable "project_id" {
  description = "The project id to work with"
  type        = string
}

variable "region" {
  description = "region for region-aware resources"
  type = string
  default = "europe-west1"
}

variable "gke_location" {
  description = "location for the gke cluster. Will default to region if not specified."
  type = string
  default = null
}

variable "sa_gke_dns" {
  type = string
}

variable "user_prefix" {
  type = string
  description = "Este campo é obrigatório para definir a vossa unicidade."
}
