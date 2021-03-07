## project related
variable "project_id" {
  description = "The project id to work with"
  type        = string
}

variable "labels" {
  description = "A set of key/value label pairs to assign to the project."
  type        = map(string)
  default = {
    terraform = "true"
    lab       = "true"
  }
}
