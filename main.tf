# Data source to get available zones
data "google_compute_zones" "available" {
  region = var.region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  project_id               = var.project_id
  region                   = var.region
  network_name             = var.network_name
  subnet_name              = var.subnet_name
  subnet_cidr              = var.subnet_cidr
  pods_cidr                = var.pods_cidr
  services_cidr            = var.services_cidr
  environment              = var.environment
  labels                   = var.labels
  create_vpc               = false
  existing_network_name    = "vpc-hr-test"
  create_firewall_rules    = false
}

# IAM Module
module "iam" {
  source = "./modules/iam"
  
  project_id                       = var.project_id
  environment                      = var.environment
  labels                           = var.labels
  create_service_accounts          = false
  existing_gke_service_account     = "gke-cluster-sa-dev"
  existing_gke_node_service_account = "gke-node-sa-dev"
}

# GKE Module
module "gke" {
  source = "./modules/gke"
  
  project_id           = var.project_id
  region              = var.region
  cluster_name        = var.cluster_name
  cluster_location    = var.cluster_location
  network_name        = module.vpc.network_name
  subnet_name         = module.vpc.subnet_name
  pods_cidr_name      = module.vpc.pods_secondary_range_name
  services_cidr_name  = module.vpc.services_secondary_range_name
  service_account_email = module.iam.gke_service_account_email
  node_count          = var.node_count
  node_machine_type   = var.node_machine_type
  node_disk_size      = var.node_disk_size
  environment         = var.environment
  labels              = var.labels
  
  depends_on = [
    module.vpc,
    module.iam
  ]
}