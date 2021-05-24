variable "project_id" {
  description = "The project id to work with"
  type        = string
}

variable "location" {
  description = "location for region-aware resources"
  type = string
}

variable "prefix" {
  description = "the prefix to be used"
  type = string
}

variable "vpc_subnet" {
  description = "The vpc's subnet name"
  type = string
}