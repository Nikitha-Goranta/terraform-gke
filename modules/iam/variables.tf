variable "project_id" {
  description = "The GCP project ID"
  type        = string
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

variable "create_service_accounts" {
  description = "Whether to create new service accounts or use existing ones"
  type        = bool
  default     = false
}

variable "existing_gke_service_account" {
  description = "Email of existing GKE service account to use"
  type        = string
  default     = ""
}

variable "existing_gke_node_service_account" {
  description = "Email of existing GKE node service account to use"
  type        = string
  default     = ""
}