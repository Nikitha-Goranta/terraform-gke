# Project Configuration
project_id = "project-5369f38e-731c-4f19-af2"
region     = "us-east1"
zone       = "us-east1-b"

# Cluster Configuration
cluster_name     = "my-gke-cluster"
cluster_location = "us-east1"

# Network Configuration
network_name   = "gke-vpc"
subnet_name    = "gke-subnet"
subnet_cidr    = "10.0.0.0/16"
pods_cidr      = "10.1.0.0/16"
services_cidr  = "10.2.0.0/16"

# Node Pool Configuration
node_count        = 3
node_machine_type = "e2-medium"
node_disk_size    = 20

# Environment Configuration
environment = "Test"

# Labels
labels = {
  managed_by  = "terraform"
  environment = "dev"
  team        = "platform"
}