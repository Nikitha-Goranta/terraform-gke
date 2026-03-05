#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Deploy application to GKE cluster

.DESCRIPTION
    This script deploys the application to the GKE cluster using kubectl.
    It applies all Kubernetes manifests in the correct order.

.PARAMETER Environment
    The environment to deploy to (dev, staging, prod)

.PARAMETER Action
    The action to perform: deploy, delete, status, logs

.PARAMETER ImageTag
    The image tag to deploy (default: latest)

.EXAMPLE
    .\deploy-app.ps1 -Action deploy -Environment dev
    .\deploy-app.ps1 -Action status
    .\deploy-app.ps1 -Action logs
    .\deploy-app.ps1 -Action delete
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("deploy", "delete", "status", "logs", "port-forward")]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [string]$ImageTag = "latest",
    
    [Parameter(Mandatory=$false)]
    [string]$Namespace = "my-app"
)

# Color output functions
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Cyan }

# Check if kubectl is available
function Test-Kubectl {
    try {
        kubectl version --client | Out-Null
        return $true
    }
    catch {
        Write-Error "kubectl is not installed or not in PATH"
        return $false
    }
}

# Check if connected to the correct cluster
function Test-ClusterConnection {
    try {
        $currentContext = kubectl config current-context
        Write-Info "Current kubectl context: $currentContext"
        
        $clusterInfo = kubectl cluster-info
        Write-Info "Cluster info: $($clusterInfo[0])"
        return $true
    }
    catch {
        Write-Error "Not connected to a Kubernetes cluster"
        return $false
    }
}

# Deploy function
function Deploy-Application {
    Write-Info "🚀 Deploying application to $Environment environment..."
    
    # Apply manifests in order
    $manifests = @(
        "namespace.yaml",
        "secret.yaml", 
        "configmap.yaml",
        "deployment.yaml",
        "service.yaml",
        "hpa.yaml",
        "ingress.yaml"
    )
    
    foreach ($manifest in $manifests) {
        if (Test-Path $manifest) {
            Write-Info "📄 Applying $manifest..."
            kubectl apply -f $manifest
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to apply $manifest"
                return
            }
        } else {
            Write-Warning "⚠️  $manifest not found, skipping..."
        }
    }
    
    Write-Success "✅ Application deployed successfully!"
    Write-Info "📊 Checking deployment status..."
    kubectl get pods -n $Namespace
}

# Delete function
function Remove-Application {
    Write-Warning "🗑️  Deleting application from $Environment environment..."
    
    $confirmation = Read-Host "Are you sure you want to delete the application? (yes/no)"
    if ($confirmation -ne "yes") {
        Write-Info "Deployment deletion cancelled"
        return
    }
    
    # Delete in reverse order
    $manifests = @(
        "ingress.yaml",
        "hpa.yaml", 
        "service.yaml",
        "deployment.yaml",
        "configmap.yaml",
        "secret.yaml"
        # Keep namespace for now
    )
    
    foreach ($manifest in $manifests) {
        if (Test-Path $manifest) {
            Write-Info "🗑️  Deleting $manifest..."
            kubectl delete -f $manifest --ignore-not-found=true
        }
    }
    
    Write-Success "✅ Application deleted successfully!"
}

# Status function
function Get-ApplicationStatus {
    Write-Info "📊 Getting application status for $Environment environment..."
    
    Write-Info "`n🏗️  Deployments:"
    kubectl get deployments -n $Namespace -o wide
    
    Write-Info "`n🔵 Pods:"
    kubectl get pods -n $Namespace -o wide
    
    Write-Info "`n🌐 Services:"
    kubectl get services -n $Namespace -o wide
    
    Write-Info "`n📈 HPA Status:"
    kubectl get hpa -n $Namespace -o wide
    
    Write-Info "`n🔀 Ingress:"
    kubectl get ingress -n $Namespace -o wide
}

# Logs function
function Get-ApplicationLogs {
    Write-Info "📋 Getting application logs for $Environment environment..."
    
    $pods = kubectl get pods -n $Namespace -l app=my-app -o jsonpath='{.items[*].metadata.name}'
    
    if ([string]::IsNullOrEmpty($pods)) {
        Write-Warning "No pods found for app=my-app in namespace $Namespace"
        return
    }
    
    $podArray = $pods.Split(' ')
    Write-Info "📋 Found $($podArray.Length) pod(s): $pods"
    
    foreach ($pod in $podArray) {
        Write-Info "`n📋 Logs for pod $pod:"
        kubectl logs $pod -n $Namespace --tail=50
    }
}

# Port forward function
function Start-PortForward {
    Write-Info "🔌 Starting port forward to application..."
    
    $service = "my-app-service"
    $localPort = "8080"
    $remotePort = "80"
    
    Write-Info "🔌 Port forwarding localhost:$localPort -> $service:$remotePort"
    Write-Info "🌐 Access the application at: http://localhost:$localPort"
    Write-Info "⏹️  Press Ctrl+C to stop port forwarding"
    
    kubectl port-forward "service/$service" "$localPort:$remotePort" -n $Namespace
}

# Main execution
if (-not (Test-Kubectl)) {
    exit 1
}

if (-not (Test-ClusterConnection)) {
    exit 1
}

# Change to k8s directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $scriptDir

switch ($Action) {
    "deploy" { Deploy-Application }
    "delete" { Remove-Application }
    "status" { Get-ApplicationStatus }
    "logs" { Get-ApplicationLogs }
    "port-forward" { Start-PortForward }
}

Write-Info "`n🎉 Script execution completed!"