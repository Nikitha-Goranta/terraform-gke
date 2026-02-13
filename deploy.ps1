# PowerShell script to deploy GKE cluster
# Usage: .\deploy.ps1

param(
    [Parameter(Mandatory=$false)]
    [switch]$AutoApprove = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Destroy = $false
)

$ErrorActionPreference = "Stop"

if ($Destroy) {
    Write-Host "🚨 DESTROYING GKE INFRASTRUCTURE..." -ForegroundColor Red
    Write-Host "This will permanently delete all resources!" -ForegroundColor Red
    
    if (-not $AutoApprove) {
        $confirmation = Read-Host "Are you sure you want to destroy? Type 'destroy' to confirm"
        if ($confirmation -ne "destroy") {
            Write-Host "❌ Destruction cancelled." -ForegroundColor Yellow
            exit 0
        }
    }
    
    Write-Host "🔥 Running terraform destroy..." -ForegroundColor Red
    if ($AutoApprove) {
        terraform destroy -auto-approve
    } else {
        terraform destroy
    }
    
    Write-Host "💥 Infrastructure destroyed!" -ForegroundColor Red
    exit 0
}

Write-Host "🚀 Deploying GKE Cluster with Terraform..." -ForegroundColor Green

# Check if terraform.tfvars exists
if (-not (Test-Path "terraform.tfvars")) {
    Write-Host "❌ terraform.tfvars not found. Please run setup.ps1 first or create terraform.tfvars manually." -ForegroundColor Red
    exit 1
}

# Validate Terraform configuration
Write-Host "✅ Validating Terraform configuration..." -ForegroundColor Yellow
terraform validate
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform validation failed!" -ForegroundColor Red
    exit 1
}

# Format Terraform files
Write-Host "📐 Formatting Terraform files..." -ForegroundColor Yellow
terraform fmt -recursive

# Plan the deployment
Write-Host "📋 Planning deployment..." -ForegroundColor Yellow
terraform plan -out=tfplan
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform plan failed!" -ForegroundColor Red
    exit 1
}

# Apply the configuration
Write-Host "🏗️  Applying Terraform configuration..." -ForegroundColor Yellow
if ($AutoApprove) {
    terraform apply -auto-approve tfplan
} else {
    terraform apply tfplan
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform apply failed!" -ForegroundColor Red
    exit 1
}

# Clean up plan file
Remove-Item "tfplan" -ErrorAction SilentlyContinue

Write-Host "🎉 Deployment completed successfully!" -ForegroundColor Green

# Get cluster information
Write-Host "📊 Getting cluster information..." -ForegroundColor Yellow
$projectId = terraform output -raw project_id
$clusterName = terraform output -raw cluster_name
$clusterLocation = terraform output -raw cluster_location

Write-Host "Cluster Details:" -ForegroundColor Cyan
Write-Host "  Project ID: $projectId" -ForegroundColor White
Write-Host "  Cluster Name: $clusterName" -ForegroundColor White  
Write-Host "  Location: $clusterLocation" -ForegroundColor White

# Configure kubectl
Write-Host "🔧 Configuring kubectl..." -ForegroundColor Yellow
$kubectlCommand = terraform output -raw kubectl_config_command
Invoke-Expression $kubectlCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ kubectl configured successfully!" -ForegroundColor Green
    
    # Test cluster connection
    Write-Host "🧪 Testing cluster connection..." -ForegroundColor Yellow
    kubectl get nodes
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "🎉 Cluster is ready and accessible!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "1. Deploy your applications: kubectl apply -f your-app.yaml" -ForegroundColor White
        Write-Host "2. Access cluster dashboard (if enabled)" -ForegroundColor White
        Write-Host "3. Monitor cluster: kubectl get pods --all-namespaces" -ForegroundColor White
    } else {
        Write-Host "⚠️  Cluster created but connection test failed. Please check manually." -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  kubectl configuration failed. Please run manually:" -ForegroundColor Yellow
    Write-Host "  $kubectlCommand" -ForegroundColor Cyan
}