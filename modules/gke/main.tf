# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.cluster_location
  
  # Network configuration
  network    = var.network_name
  subnetwork = var.subnet_name
  
  # Networking mode
  networking_mode = "VPC_NATIVE"
  
  # IP allocation policy for VPC-native networking
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_cidr_name
    services_secondary_range_name = var.services_cidr_name
  }
  
  # Remove default node pool
  remove_default_node_pool = true
  initial_node_count       = 1
  
  # Cluster configuration
  deletion_protection = false
  
  # Network policy
  network_policy {
    enabled  = true
    provider = "CALICO"
  }
  
  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
    
    master_global_access_config {
      enabled = true
    }
  }
  
  # Master authorized networks (allows access from anywhere - customize as needed)
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  
  # Addons
  addons_config {
    http_load_balancing {
      disabled = false
    }
    
    horizontal_pod_autoscaling {
      disabled = false
    }
    
    network_policy_config {
      disabled = false
    }
  }
  
  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Logging and monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  
  # Resource labels
  resource_labels = var.labels
  
  # Timeouts
  timeouts {
    create = "30m"
    update = "40m"
    delete = "30m"
  }
}

# Separately managed node pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.cluster_location
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count
  
  # Node configuration
  node_config {
    preemptible  = false
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size
    disk_type    = "pd-standard"
    image_type   = "COS_CONTAINERD"
    
    # Google recommends custom service accounts with minimal permissions
    service_account = var.service_account_email
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
    
    # Network tags
    tags = ["gke-cluster"]
    
    # Labels
    labels = merge(var.labels, {
      node_pool = "${var.cluster_name}-node-pool"
    })
    
    # Metadata
    metadata = {
      disable-legacy-endpoints = "true"
    }
    
    # Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    
    # Shielded instance features
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }
  
  # Autoscaling
  autoscaling {
    min_node_count = 1
    max_node_count = 10
  }
  
  # Node management
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
  # Upgrade settings
  upgrade_settings {
    strategy        = "SURGE"
    max_surge       = 1
    max_unavailable = 0
  }
  
  # Timeouts
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}