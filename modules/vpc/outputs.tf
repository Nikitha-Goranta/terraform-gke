output "network_name" {
  description = "The name of the VPC network"
  value       = var.create_vpc ? google_compute_network.vpc[0].name : data.google_compute_network.existing_vpc[0].name
}

output "network_self_link" {
  description = "The self link of the VPC network"
  value       = var.create_vpc ? google_compute_network.vpc[0].self_link : data.google_compute_network.existing_vpc[0].self_link
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = var.create_subnet ? google_compute_subnetwork.subnet[0].name : data.google_compute_subnetwork.existing_subnet[0].name
}

output "subnet_self_link" {
  description = "The self link of the subnet"
  value       = var.create_subnet ? google_compute_subnetwork.subnet[0].self_link : data.google_compute_subnetwork.existing_subnet[0].self_link
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
  value       = var.create_subnet ? google_compute_subnetwork.subnet[0].ip_cidr_range : data.google_compute_subnetwork.existing_subnet[0].ip_cidr_range
}

output "router_name" {
  description = "The name of the Cloud Router"
  value       = var.create_vpc ? google_compute_router.router[0].name : null
}