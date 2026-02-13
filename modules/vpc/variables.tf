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

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
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