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