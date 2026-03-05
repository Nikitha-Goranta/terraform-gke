output "gke_service_account_email" {
  description = "The email address of the GKE service account"
  value       = local.gke_service_account_email
}

output "gke_service_account_name" {
  description = "The name of the GKE service account"
  value       = var.create_service_accounts ? google_service_account.gke_service_account[0].name : data.google_service_account.existing_gke_service_account[0].name
}

output "gke_node_service_account_email" {
  description = "The email address of the GKE node service account"
  value       = local.gke_node_service_account_email
}

output "gke_node_service_account_name" {
  description = "The name of the GKE node service account"
  value       = var.create_service_accounts ? google_service_account.gke_node_service_account[0].name : data.google_service_account.existing_gke_node_service_account[0].name
}