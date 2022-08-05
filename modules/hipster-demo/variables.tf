variable "project_id" {
  description = "The project id to work with."
  type        = string
}

variable "fqdn" {
  description = "The project FQDN (fully-qualified-domain-name) for DNS purposes."
  type        = string
  default     = ""
}

variable "ingress_enabled" {
  description = "Controls if the ingress resources are applied."
  type        = bool
  default     = false
}
