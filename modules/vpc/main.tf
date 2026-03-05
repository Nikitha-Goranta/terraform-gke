# Data source for existing VPC Network
data "google_compute_network" "existing_vpc" {
  count   = var.create_vpc ? 0 : 1
  project = var.project_id
  name    = var.existing_network_name
}

# VPC Network (only create if create_vpc is true)
resource "google_compute_network" "vpc" {
  count                   = var.create_vpc ? 1 : 0
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode           = "GLOBAL"
}

# Data source for existing subnet (only if using existing subnet)
data "google_compute_subnetwork" "existing_subnet" {
  count   = var.create_subnet ? 0 : 1
  project = var.project_id
  name    = var.existing_subnet_name
  region  = var.region
}

# Subnet with secondary ranges for pods and services (create new subnet in existing VPC)
resource "google_compute_subnetwork" "subnet" {
  count         = var.create_subnet ? 1 : 0
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  network       = data.google_compute_network.existing_vpc[0].name
  region        = var.region
  
  secondary_ip_range {
    range_name    = "${var.subnet_name}-pods"
    ip_cidr_range = var.pods_cidr
  }
  
  secondary_ip_range {
    range_name    = "${var.subnet_name}-services"
    ip_cidr_range = var.services_cidr
  }
  
  # Enable private Google access
  private_ip_google_access = true
}

# Firewall rule to allow internal communication
resource "google_compute_firewall" "allow_internal" {
  count   = var.create_vpc ? 1 : 0
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc[0].name
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = [
    var.subnet_cidr,
    var.pods_cidr,
    var.services_cidr
  ]
  
  target_tags = ["gke-cluster"]
}

# Firewall rule to allow SSH (optional)
resource "google_compute_firewall" "allow_ssh" {
  count   = var.create_vpc ? 1 : 0
  name    = "${var.network_name}-allow-ssh"
  network = google_compute_network.vpc[0].name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}

# Cloud NAT Router for private nodes (only create if create_vpc is true)
resource "google_compute_router" "router" {
  count   = var.create_vpc ? 1 : 0
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc[0].id
}

resource "google_compute_router_nat" "nat" {
  count                              = var.create_vpc ? 1 : 0
  name                               = "${var.network_name}-nat"
  router                            = google_compute_router.router[0].name
  region                            = var.region
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}