# Project Configuration
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "credentials_file" {
  description = "Path to the GCP service account credentials JSON file"
  type        = string
  default     = null
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-central1-a"
}

# Cluster Configuration
variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "my-gke-cluster"
}

variable "cluster_location" {
  description = "The location (region or zone) of the cluster"
  type        = string
  default     = "us-central1"
}

# Network Configuration
variable "network_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "gke-vpc"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "gke-subnet"
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "pods_cidr" {
  description = "The CIDR block for pods"
  type        = string
  default     = "10.1.0.0/16"
}

variable "services_cidr" {
  description = "The CIDR block for services"
  type        = string
  default     = "10.2.0.0/16"
}

# Node Pool Configuration
variable "node_count" {
  description = "The number of nodes in the default node pool"
  type        = number
  default     = 3
}

variable "node_machine_type" {
  description = "The machine type for cluster nodes"
  type        = string
  default     = "e2-medium"
}

variable "node_disk_size" {
  description = "The disk size for cluster nodes"
  type        = number
  default     = 20
}

# Tags and Labels
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}