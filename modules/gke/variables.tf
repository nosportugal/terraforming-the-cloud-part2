variable "project_id" {
  description = "The project id to work with"
  type        = string
}

variable "region" {
  description = "region for region-aware resources"
  type = string
  default = "europe-west4"
}

variable "prefix" {
  description = "the prefix to be used"
  type = string
}

variable "vpc_subnet" {
  description = "The vpc's subnet name"
  type = string
}