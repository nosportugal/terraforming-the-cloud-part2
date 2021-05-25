variable "project_id" {
  description = "The project id to work with"
  type        = string
}

variable "fqdn" {
  type = string
  default = ""
}

variable "sa_gke_dns" {
  type = string
}

variable "gke_default_endpoint" {
  type = string
}

variable "gke_ca_certificate" {
  type = string
}

variable "gke_default_node_pool" {
  type = any
}