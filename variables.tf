## project related
variable "lab_folder" {
  type = string
  description = "The resource name of the Folder. Its format is folders/{folder_id}."
  default = "folders/1083891423128"
}

variable "organization_domain" {
  type = string
  description = "The organization domain."
  default = "nos.pt"
}

variable "billing_account" {
  type = string
  description = "The alphanumeric ID of the billing account this project belongs to."
}

variable "labels" {
  description = "A set of key/value label pairs to assign to the project."
  type        = map(string)
  default     = {
        terraform = "true"
    }
}