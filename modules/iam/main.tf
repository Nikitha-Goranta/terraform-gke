# Service Account for GKE Cluster
resource "google_service_account" "gke_service_account" {
  account_id   = "gke-cluster-sa-${var.environment}"
  display_name = "GKE Cluster Service Account"
  description  = "Service account for GKE cluster nodes"
}

# Service Account for GKE Nodes
resource "google_service_account" "gke_node_service_account" {
  account_id   = "gke-node-sa-${var.environment}"
  display_name = "GKE Node Service Account"
  description  = "Service account for GKE cluster node pools"
}

# IAM bindings for GKE Service Account
resource "google_project_iam_member" "gke_cluster_service_agent" {
  project = var.project_id
  role    = "roles/container.serviceAgent"
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}

# IAM bindings for GKE Node Service Account
resource "google_project_iam_member" "gke_node_service_account_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_node_service_account.email}"
}

resource "google_project_iam_member" "gke_node_service_account_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_node_service_account.email}"
}

resource "google_project_iam_member" "gke_node_service_account_monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.gke_node_service_account.email}"
}

resource "google_project_iam_member" "gke_node_service_account_gcr" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gke_node_service_account.email}"
}

# Optional: IAM binding for Container Registry access
resource "google_project_iam_member" "gke_node_service_account_registry" {
  project = var.project_id
  role    = "roles/containerregistry.ServiceAgent"
  member  = "serviceAccount:${google_service_account.gke_node_service_account.email}"
}

# Optional: IAM binding for Artifact Registry access (for newer projects)
resource "google_project_iam_member" "gke_node_service_account_artifact_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke_node_service_account.email}"
}