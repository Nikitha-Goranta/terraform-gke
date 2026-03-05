variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "existing_network_name" {
  description = "The name of the existing VPC network to use"
  type        = string
  default     = ""
}

variable "create_vpc" {
  description = "Whether to create a new VPC or use existing one"
  type        = bool
  default     = false
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}

variable "existing_subnet_name" {
  description = "The name of the existing subnet to use (optional)"
  type        = string
  default     = ""
}

variable "create_subnet" {
  description = "Whether to create a new subnet or use existing one"
  type        = bool
  default     = false
}

variable "create_firewall_rules" {
  description = "Whether to create firewall rules or use existing ones"
  type        = bool
  default     = false
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
}

variable "pods_cidr" {
  description = "The CIDR block for pods"
  type        = string
}

variable "services_cidr" {
  description = "The CIDR block for services"
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