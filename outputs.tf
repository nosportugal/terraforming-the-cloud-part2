output "my_identifier" {
  value       = local.prefix
  description = "All my resources will be created using this prefix, so that I don't conflict with other's resources"
}

output "project_id" {
  value       = var.project_id
  description = "The project identifier"
}
