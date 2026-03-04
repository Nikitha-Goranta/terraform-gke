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

## � Version Control with GitHub

### Push Code to Private Repository

**Important:** Before committing, ensure sensitive files are excluded by the `.gitignore`:

```powershell
# Step 1: Verify safe files only (sensitive files should NOT appear)
git status --ignored

# Step 2: Initialize git repository (if needed)
git init

# Step 3: Add safe files
git add .

# Step 4: Check what's being committed (NO .tfvars or .json files!)
git status

# Step 5: Commit your code
git commit -m "Initial commit: Terraform GKE cluster configuration"

# Step 6: Create GitHub repository
# Manual step: Go to https://github.com/new and create a PRIVATE repository named 'terraform-gke'

# Step 7: Connect to GitHub (replace YOUR-USERNAME)
git remote add origin https://github.com/YOUR-USERNAME/terraform-gke.git

# Step 8: Push to GitHub
git branch -M main
git push -u origin main
```

**Security Note:** Your `.gitignore` protects these sensitive files:
- `*.tfvars` (contains project details)
- `*.json` (service account keys)  
- `*.tfstate*` (terraform state with secrets)

## 🚀 Deploy Applications to Your Cluster

### Deploy Sample Hello World Application

```powershell
# Deploy Google's sample hello world application
kubectl create deployment hello-world --image=gcr.io/google-samples/hello-app:1.0

# Check deployment status
kubectl get pods
kubectl get deployment hello-world

# Expose the deployment to the internet
kubectl expose deployment hello-world --type=LoadBalancer --port 8080 --target-port 8080

# Wait for external IP (takes 2-3 minutes)
kubectl get services hello-world --watch
# Press Ctrl+C when you see an external IP assigned

# Test your application
# Copy the EXTERNAL-IP and open: http://EXTERNAL-IP:8080
kubectl get services hello-world
```

### Deploy Custom Applications

#### Prerequisites
- Docker Desktop installed
- Your application code in a folder
- Google Cloud SDK configured

#### Step 1: Create Dockerfile

**For Node.js app:**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

**For Python app:**
```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["python", "app.py"]
```

**For .NET app:**
```dockerfile
FROM mcr.microsoft.com/dotnet/runtime:6.0
WORKDIR /app
COPY bin/Release/net6.0/publish/ .
EXPOSE 80
ENTRYPOINT ["dotnet", "YourApp.dll"]
```

#### Step 2: Build and Deploy

```powershell
# Navigate to your app folder
cd C:\path\to\your\app

# Build the Docker image
docker build -t my-app:latest .

# Test locally (optional)
docker run -p 8080:3000 my-app:latest
# Open http://localhost:8080 to test, then Ctrl+C to stop

# Tag for Google Container Registry
docker tag my-app:latest gcr.io/YOUR-PROJECT-ID/my-app:latest

# Configure Docker credentials
gcloud auth configure-docker

# Push to registry
docker push gcr.io/YOUR-PROJECT-ID/my-app:latest

# Deploy to Kubernetes
kubectl create deployment my-app --image=gcr.io/YOUR-PROJECT-ID/my-app:latest

# Expose as service
kubectl expose deployment my-app --type=LoadBalancer --port=80 --target-port=3000

# Get external IP
kubectl get services my-app
```

#### Step 3: Update Your Application

```powershell
# Make code changes, then build new version
docker build -t gcr.io/YOUR-PROJECT-ID/my-app:v2 .
docker push gcr.io/YOUR-PROJECT-ID/my-app:v2

# Update deployment
kubectl set image deployment/my-app my-app=gcr.io/YOUR-PROJECT-ID/my-app:v2
```

#### Optional: Use YAML Manifests

Create `deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: gcr.io/YOUR-PROJECT-ID/my-app:latest
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 3000
  selector:
    app: my-app
```

Apply with:
```powershell
kubectl apply -f deployment.yaml
```

## �🔗 Additional Resources

- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)