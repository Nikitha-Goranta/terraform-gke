output "gke_service_account_email" {
  description = "The email address of the GKE service account"
  value       = google_service_account.gke_service_account.email
}

output "gke_service_account_name" {
  description = "The name of the GKE service account"
  value       = google_service_account.gke_service_account.name
}

output "gke_node_service_account_email" {
  description = "The email address of the GKE node service account"
  value       = google_service_account.gke_node_service_account.email
}

output "gke_node_service_account_name" {
  description = "The name of the GKE node service account"
  value       = google_service_account.gke_node_service_account.name
}