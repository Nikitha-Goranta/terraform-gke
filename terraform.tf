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
  # Use Application Default Credentials - avoids JSON parsing issues
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  # Use Application Default Credentials - avoids JSON parsing issues
  project = var.project_id
  region  = var.region
  zone    = var.zone
}