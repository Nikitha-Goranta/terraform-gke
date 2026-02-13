variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "cluster_location" {
  description = "The location (region or zone) of the cluster"
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}

variable "pods_cidr_name" {
  description = "The name of the secondary IP range for pods"
  type        = string
}

variable "services_cidr_name" {
  description = "The name of the secondary IP range for services"
  type        = string
}

variable "service_account_email" {
  description = "The email of the service account for nodes"
  type        = string
}

variable "node_count" {
  description = "The number of nodes in the node pool"
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

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default     = {}
}