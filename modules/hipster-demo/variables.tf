variable "project_id" {
  description = "The project id to work with."
  type        = string
}

variable "fqdn" {
  description = "The project FQDN (fully-qualified-domain-name) for DNS purposes."
  type        = string
  default     = ""
}