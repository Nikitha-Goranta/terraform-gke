# Terraform GKE Cluster Setup

This repository contains Terraform code to create a Google Kubernetes Engine (GKE) cluster on Google Cloud Platform with a modular architecture.

## 📁 Project Structure

```
terraform-gke/
├── main.tf                 # Root configuration calling modules
├── variables.tf            # Root variables
├── outputs.tf             # Root outputs
├── terraform.tf           # Provider configuration
├── terraform.tfvars.example # Example variables file
└── modules/
    ├── vpc/
    │   ├── main.tf        # VPC and networking resources
    │   ├── variables.tf   # VPC module variables
    │   └── outputs.tf     # VPC module outputs
    ├── iam/
    │   ├── main.tf        # IAM service accounts and roles
    │   ├── variables.tf   # IAM module variables
    │   └── outputs.tf     # IAM module outputs
    └── gke/
        ├── main.tf        # GKE cluster and node pools
        ├── variables.tf   # GKE module variables
        └── outputs.tf     # GKE module outputs
```

## 🚀 Quick Start

### Prerequisites

1. **Terraform** (>= 1.5)
2. **Google Cloud SDK (gcloud)**
3. **kubectl**
4. GCP Project with billing enabled

### Step 1: Install Terraform

**For Windows (PowerShell):**
```powershell
# Create tools directory
New-Item -ItemType Directory -Force -Path "C:\tools\terraform"

# Download Terraform (replace with latest version)
$url = "https://releases.hashicorp.com/terraform/1.14.5/terraform_1.14.5_windows_amd64.zip"

# Download with timeout and progress settings to avoid timeout issues
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $url -OutFile "C:\tools\terraform\terraform.zip" -TimeoutSec 300

# Alternative: If download times out, manually download from:
# https://developer.hashicorp.com/terraform/install

# Extract
Expand-Archive -Path "C:\tools\terraform\terraform.zip" -DestinationPath "C:\tools\terraform"

# Add to PATH
$env:PATH += ";C:\tools\terraform"

# Verify installation
terraform version
```

### Step 2: Install Google Cloud SDK

1. Download from: https://cloud.google.com/sdk/docs/install
2. Run the installer
3. Initialize: `gcloud init`

### Step 3: Set Up GCP Project

```powershell
# Create a new project (optional)
gcloud projects create YOUR-PROJECT-ID

# Set the project
gcloud config set project YOUR-PROJECT-ID

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable servicenetworking.googleapis.com

# Create service account for Terraform
gcloud iam service-accounts create terraform-gke --display-name="Terraform GKE Service Account"

# Grant necessary roles
gcloud projects add-iam-policy-binding YOUR-PROJECT-ID --member="serviceAccount:terraform-gke@YOUR-PROJECT-ID.iam.gserviceaccount.com" --role="roles/container.admin"

gcloud projects add-iam-policy-binding YOUR-PROJECT-ID --member="serviceAccount:terraform-gke@YOUR-PROJECT-ID.iam.gserviceaccount.com" --role="roles/compute.admin"

gcloud projects add-iam-policy-binding YOUR-PROJECT-ID --member="serviceAccount:terraform-gke@YOUR-PROJECT-ID.iam.gserviceaccount.com" --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding YOUR-PROJECT-ID --member="serviceAccount:terraform-gke@YOUR-PROJECT-ID.iam.gserviceaccount.com" --role="roles/servicenetworking.networksAdmin"

# Create and download service account key
gcloud iam service-accounts keys create terraform-key.json --iam-account=terraform-gke@YOUR-PROJECT-ID.iam.gserviceaccount.com

# Set environment variable (PowerShell) - Choose one of these methods:
# Method 1: Using full path
$env:GOOGLE_APPLICATION_CREDENTIALS = "$PWD\terraform-key.json"

# Method 2: Using Join-Path (recommended)
$env:GOOGLE_APPLICATION_CREDENTIALS = Join-Path -Path $PWD -ChildPath "terraform-key.json"

# Method 3: Using absolute path (replace C:\your\actual\path)
# $env:GOOGLE_APPLICATION_CREDENTIALS = "C:\full\path\to\terraform-key.json"
```

### Step 4: Configure Terraform Variables

```powershell
# Copy the example file (PowerShell)
Copy-Item terraform.tfvars.example terraform.tfvars

# Edit with your values
# terraform.tfvars content:
project_id = "your-actual-project-id"
region     = "us-central1"
zone       = "us-central1-a"
cluster_name = "my-gke-cluster"
# ... other variables
```

### Step 5: Deploy the Infrastructure

```powershell
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### Step 6: Configure kubectl

```powershell
# Get cluster credentials
gcloud container clusters get-credentials CLUSTER-NAME --location=LOCATION --project=PROJECT-ID

# Verify connection
kubectl get nodes
```

## 📋 Module Details

### VPC Module
Creates:
- VPC network with custom subnetting
- Subnets with secondary IP ranges for pods and services
- Cloud NAT for outbound internet access
- Firewall rules for cluster communication

### IAM Module
Creates:
- Service accounts for GKE cluster and nodes
- IAM bindings for required permissions
- Workload Identity configuration

### GKE Module
Creates:
- GKE cluster with VPC-native networking
- Managed node pool with autoscaling
- Private cluster configuration
- Network policy enabled

## 🔧 Customization

### Scaling the Cluster

Modify `variables.tf` or `terraform.tfvars`:
```hcl
node_count = 5
node_machine_type = "e2-standard-4"
```

### Multi-Zone Cluster

Change cluster location to a region:
```hcl
cluster_location = "us-central1"  # Regional cluster
```

### Different Network Configuration

Modify CIDR blocks in `terraform.tfvars`:
```hcl
subnet_cidr   = "10.0.0.0/16"
pods_cidr     = "10.1.0.0/16"
services_cidr = "10.2.0.0/16"
```

## 🛠️ Operational Commands

### Update Cluster
```powershell
# Update variables and apply changes
terraform plan
terraform apply
```

### Scale Node Pool
```powershell
# Manually scale (or use autoscaling)
kubectl scale deployment your-app --replicas=10
```

### Destroy Infrastructure
```powershell
terraform destroy
```

## 📊 Monitoring and Logging

The cluster is configured with:
- Google Cloud Monitoring
- Google Cloud Logging
- Network policy enforcement
- Workload Identity for secure access to GCP services

## 🔒 Security Features

- Private cluster with private nodes
- Network policies enabled
- Workload Identity for pod-to-GCP service authentication
- Shielded GKE nodes
- Minimal IAM permissions

## 📚 Useful Commands

```powershell
# View cluster info
kubectl cluster-info

# Get node information
kubectl get nodes -o wide

# View cluster resources
kubectl get all --all-namespaces

# Access cluster dashboard (if enabled)
kubectl proxy
```

## 🚨 Troubleshooting

### Common Issues:

1. **API not enabled**: Enable required APIs in GCP Console
2. **Insufficient permissions**: Check IAM roles for service account
3. **Quota limits**: Check GCP quotas for compute resources
4. **Network conflicts**: Ensure CIDR ranges don't overlap

### Debug Commands:
```powershell
# Check Terraform state
terraform show

# Validate configuration
terraform validate

# View detailed plan
terraform plan -detailed-exitcode

# Get cluster events
kubectl get events --sort-by=.metadata.creationTimestamp
```

## 🔗 Additional Resources

- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)