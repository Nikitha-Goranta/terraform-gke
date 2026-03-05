# Project Configuration
project_id = "project-5369f38e-731c-4f19-af2"
region     = "us-east1"
zone       = "us-east1-b"

# Cluster Configuration
cluster_name     = "my-gke-cluster"
cluster_location = "us-east1"

# Network Configuration
network_name   = "vpc-hr-test"  # Using existing VPC
subnet_name    = "gke-subnet-us-east1"  # New subnet to create in existing VPC
subnet_cidr    = "10.0.3.0/24"  # Avoiding conflict with existing subnets
pods_cidr      = "10.1.0.0/16"  # Secondary range for pods
services_cidr  = "10.2.0.0/16"  # Secondary range for services

# Node Pool Configuration
node_count        = 3
node_machine_type = "e2-medium"
node_disk_size    = 20

# Environment Configuration
environment = "dev"

# Labels
labels = {
  managed_by  = "terraform"
  environment = "dev"
  team        = "platform"
}