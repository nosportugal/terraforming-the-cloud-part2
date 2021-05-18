variable "project_id" {
  description = "The project id to work with"
  type        = string
}

variable "fqdn" {
  type = string
  default = ""
}

variable "gke_kubeconfig_filename" {
  type = string
}

variable "sa_gke_dns" {
  type = string
}


## apenas necessário caso se use certificate authentication
variable "gke_default_endpoint" {
  type = string
  default = null
}

variable "gke_ca_certificate" {
  type = string
  default = null
}