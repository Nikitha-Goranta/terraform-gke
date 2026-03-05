# Network Outputs
output "network_name" {
  description = "The name of the VPC network"
  value       = module.vpc.network_name
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = module.vpc.subnet_name
}

output "network_self_link" {
  description = "The self link of the VPC network"
  value       = module.vpc.network_self_link
}

# IAM Outputs
output "gke_service_account_email" {
  description = "The email of the GKE service account"
  value       = module.iam.gke_service_account_email
}

# GKE Outputs
output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = module.gke.cluster_name
}

output "cluster_id" {
  description = "The cluster ID in format location/clustername for Harness pipeline"
  value       = "${module.gke.cluster_location}/${module.gke.cluster_name}"
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE cluster"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The CA certificate of the GKE cluster"
  value       = module.gke.cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "The location of the GKE cluster"
  value       = module.gke.cluster_location
}

# kubectl command
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --location=${module.gke.cluster_location} --project=${var.project_id}"
}