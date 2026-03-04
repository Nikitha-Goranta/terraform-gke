terraform {
  required_version = ">= 1.5"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  # Use access token instead of credentials file to avoid parsing issues
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  # Use access token instead of credentials file to avoid parsing issues
  project = var.project_id
  region  = var.region
  zone    = var.zone
}