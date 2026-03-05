# Data sources for existing service accounts
data "google_service_account" "existing_gke_service_account" {
  count      = var.create_service_accounts ? 0 : 1
  account_id = var.existing_gke_service_account
  project    = var.project_id
}

data "google_service_account" "existing_gke_node_service_account" {
  count      = var.create_service_accounts ? 0 : 1
  account_id = var.existing_gke_node_service_account
  project    = var.project_id
}

# Service Account for GKE Cluster (only create if create_service_accounts is true)
resource "google_service_account" "gke_service_account" {
  count        = var.create_service_accounts ? 1 : 0
  account_id   = "gke-cluster-sa-${var.environment}"
  display_name = "GKE Cluster Service Account"
  description  = "Service account for GKE cluster nodes"
}

# Service Account for GKE Nodes (only create if create_service_accounts is true)
resource "google_service_account" "gke_node_service_account" {
  count        = var.create_service_accounts ? 1 : 0
  account_id   = "gke-node-sa-${var.environment}"
  display_name = "GKE Node Service Account"
  description  = "Service account for GKE cluster node pools"
}

# Local values for service account emails
locals {
  gke_service_account_email = var.create_service_accounts ? google_service_account.gke_service_account[0].email : data.google_service_account.existing_gke_service_account[0].email
  gke_node_service_account_email = var.create_service_accounts ? google_service_account.gke_node_service_account[0].email : data.google_service_account.existing_gke_node_service_account[0].email
}

# IAM bindings for GKE Service Account
resource "google_project_iam_member" "gke_cluster_service_agent" {
  project = var.project_id
  role    = "roles/container.serviceAgent"
  member  = "serviceAccount:${local.gke_service_account_email}"
}

# IAM bindings for GKE Node Service Account
resource "google_project_iam_member" "gke_node_service_account_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${local.gke_node_service_account_email}"
}

resource "google_project_iam_member" "gke_node_service_account_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${local.gke_node_service_account_email}"
}

resource "google_project_iam_member" "gke_node_service_account_monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${local.gke_node_service_account_email}"
}

resource "google_project_iam_member" "gke_node_service_account_gcr" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${local.gke_node_service_account_email}"
}

# Optional: IAM binding for Container Registry access
resource "google_project_iam_member" "gke_node_service_account_registry" {
  project = var.project_id
  role    = "roles/containerregistry.ServiceAgent"
  member  = "serviceAccount:${local.gke_node_service_account_email}"
}

# Optional: IAM binding for Artifact Registry access (for newer projects)
resource "google_project_iam_member" "gke_node_service_account_artifact_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${local.gke_node_service_account_email}"
}