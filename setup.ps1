# PowerShell script to set up GKE Terraform project
# Usage: .\setup.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectId,
    
    [Parameter(Mandatory=$false)]
    [string]$ServiceAccountName = "terraform-gke"
)

Write-Host "🚀 Starting GKE Terraform Setup..." -ForegroundColor Green

# Check if required tools are installed
Write-Host "📋 Checking prerequisites..." -ForegroundColor Yellow

# Check Terraform
try {
    $terraformVersion = terraform version
    Write-Host "✅ Terraform is installed: $($terraformVersion[0])" -ForegroundColor Green
} catch {
    Write-Host "❌ Terraform is not installed. Please install Terraform first." -ForegroundColor Red
    exit 1
}

# Check gcloud
try {
    $gcloudVersion = gcloud version --format="value(Google Cloud SDK)"
    Write-Host "✅ Google Cloud SDK is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Google Cloud SDK is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Set the project
Write-Host "🔧 Setting up GCP project: $ProjectId" -ForegroundColor Yellow
gcloud config set project $ProjectId

# Enable APIs
Write-Host "🔌 Enabling required APIs..." -ForegroundColor Yellow
$apis = @(
    "container.googleapis.com",
    "compute.googleapis.com", 
    "servicenetworking.googleapis.com"
)

foreach ($api in $apis) {
    Write-Host "  Enabling $api..." -ForegroundColor Cyan
    gcloud services enable $api
}

# Create service account
Write-Host "👤 Creating service account: $ServiceAccountName" -ForegroundColor Yellow
gcloud iam service-accounts create $ServiceAccountName --display-name="Terraform GKE Service Account" --quiet

# Grant roles
Write-Host "🔐 Granting IAM roles..." -ForegroundColor Yellow
$roles = @(
    "roles/container.admin",
    "roles/compute.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/servicenetworking.networksAdmin"
)

foreach ($role in $roles) {
    Write-Host "  Granting $role..." -ForegroundColor Cyan
    gcloud projects add-iam-policy-binding $ProjectId `
        --member="serviceAccount:$ServiceAccountName@$ProjectId.iam.gserviceaccount.com" `
        --role="$role" `
        --quiet
}

# Create service account key
Write-Host "🔑 Creating service account key..." -ForegroundColor Yellow
$keyFile = "terraform-key.json"
gcloud iam service-accounts keys create $keyFile `
    --iam-account="$ServiceAccountName@$ProjectId.iam.gserviceaccount.com"

# Set environment variable
Write-Host "🌐 Setting environment variable for authentication..." -ForegroundColor Yellow
$env:GOOGLE_APPLICATION_CREDENTIALS = (Resolve-Path $keyFile).Path

# Initialize Terraform
Write-Host "🏗️  Initializing Terraform..." -ForegroundColor Yellow
terraform init

# Create terraform.tfvars if it doesn't exist
if (-not (Test-Path "terraform.tfvars")) {
    Write-Host "📝 Creating terraform.tfvars..." -ForegroundColor Yellow
    Copy-Item "terraform.tfvars.example" "terraform.tfvars"
    
    # Update project_id in terraform.tfvars
    $content = Get-Content "terraform.tfvars"
    $content = $content -replace 'project_id = "your-gcp-project-id"', "project_id = `"$ProjectId`""
    Set-Content "terraform.tfvars" $content
    
    Write-Host "✅ terraform.tfvars created and updated with your project ID" -ForegroundColor Green
    Write-Host "📝 Please review and edit terraform.tfvars for other settings" -ForegroundColor Cyan
}

Write-Host "🎉 Setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Review and edit terraform.tfvars file" -ForegroundColor White
Write-Host "2. Run: terraform plan" -ForegroundColor White
Write-Host "3. Run: terraform apply" -ForegroundColor White
Write-Host ""
Write-Host "Environment variable set for this session:" -ForegroundColor Yellow
Write-Host "GOOGLE_APPLICATION_CREDENTIALS=$env:GOOGLE_APPLICATION_CREDENTIALS" -ForegroundColor Cyan
Write-Host ""
Write-Host "To set permanently, add this to your PowerShell profile:" -ForegroundColor Yellow
Write-Host "[Environment]::SetEnvironmentVariable('GOOGLE_APPLICATION_CREDENTIALS', '$((Resolve-Path $keyFile).Path)', 'User')" -ForegroundColor Cyan