output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "network_self_link" {
  description = "The self link of the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_self_link" {
  description = "The self link of the subnet"
  value       = google_compute_subnetwork.subnet.self_link
}

output "pods_secondary_range_name" {
  description = "The name of the secondary range for pods"
  value       = "${var.subnet_name}-pods"
}

output "services_secondary_range_name" {
  description = "The name of the secondary range for services"
  value       = "${var.subnet_name}-services"
}

output "subnet_cidr" {
  description = "The CIDR block of the subnet"
  value       = google_compute_subnetwork.subnet.ip_cidr_range
}

output "router_name" {
  description = "The name of the Cloud Router"
  value       = google_compute_router.router.name
}