# Kubernetes Manifests for GKE Application

This directory contains Kubernetes manifest files for deploying your application to the GKE cluster.

## 📁 File Structure

```
k8s/
├── namespace.yaml           # Creates the my-app namespace
├── deployment.yaml          # Main application deployment
├── service.yaml             # ClusterIP and LoadBalancer services
├── configmap.yaml           # Application configuration
├── secret.yaml              # Sensitive configuration (credentials, API keys)
├── ingress.yaml             # External access with SSL and CDN
├── hpa.yaml                 # Horizontal Pod Autoscaler
├── kustomization.yaml       # Kustomize configuration
├── deploy-app.ps1           # PowerShell deployment script
└── README.md                # This file
```

## 🚀 Quick Deployment

### Using the PowerShell Script (Recommended)

```powershell
# Deploy the application
.\deploy-app.ps1 -Action deploy -Environment dev

# Check status
.\deploy-app.ps1 -Action status

# View logs
.\deploy-app.ps1 -Action logs

# Port forward for local access
.\deploy-app.ps1 -Action port-forward

# Delete the application
.\deploy-app.ps1 -Action delete
```

### Using kubectl directly

```bash
# Apply all manifests
kubectl apply -f namespace.yaml
kubectl apply -f secret.yaml
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f hpa.yaml
kubectl apply -f ingress.yaml

# Or apply all at once
kubectl apply -f .
```

### Using Kustomize

```bash
# Deploy using kustomize
kubectl apply -k .

# Delete using kustomize
kubectl delete -k .
```

## 📋 Manifest Details

### `namespace.yaml`
- Creates the `my-app` namespace
- Provides isolation for the application resources

### `deployment.yaml`
- Deploys the application with 3 replicas
- Includes resource limits and requests
- Configures health checks (liveness and readiness probes)
- Sets up security contexts
- Implements pod anti-affinity for high availability

### `service.yaml`
- **ClusterIP Service**: Internal cluster access
- **LoadBalancer Service**: External access with Google Cloud Load Balancer

### `configmap.yaml`
- Application configuration files
- Logging configuration
- Database connection settings (non-sensitive)

### `secret.yaml`
- Database credentials (base64 encoded)
- API keys and JWT secrets
- Other sensitive configuration

### `ingress.yaml`
- External HTTPS access with managed SSL certificates
- Cloud CDN integration
- Custom domain routing
- Backend health check configuration

### `hpa.yaml`
- Automatic scaling between 3-10 pods
- CPU and memory-based scaling
- Custom scaling policies

## 🛠️ Prerequisites

Before deploying, ensure you have:

1. **GKE Cluster**: Running and accessible via kubectl
2. **kubectl**: Configured to connect to your GKE cluster
3. **Container Image**: Built and pushed to GCR/Artifact Registry
4. **Secrets**: Update `secret.yaml` with your actual credentials

## 🔧 Configuration

### Update Image Registry

In `deployment.yaml`, update the image reference:
```yaml
image: gcr.io/your-project-id/paypal-app:latest
```

### Update Secrets

In `secret.yaml`, replace the base64 encoded values:
```bash
# Encode your secrets
echo -n 'your-actual-password' | base64
```

### Update Domain Names

In `ingress.yaml`, replace example domains:
```yaml
domains:
  - your-domain.com
  - api.your-domain.com
```

## 📊 Monitoring and Observability

### Check Application Status
```bash
# Get all resources
kubectl get all -n my-app

# Check pod logs
kubectl logs -l app=my-app -n my-app

# Check events
kubectl get events -n my-app --sort-by='.lastTimestamp'
```

### Access the Application
```bash
# Get LoadBalancer IP
kubectl get service my-app-loadbalancer -n my-app

# Port forward for local testing
kubectl port-forward service/my-app-service 8080:80 -n my-app
```

### Scaling
```bash
# Manual scaling
kubectl scale deployment my-app --replicas=5 -n my-app

# Check HPA status
kubectl get hpa -n my-app
```

## 🔒 Security Features

- **Security Contexts**: Non-root containers with dropped capabilities
- **Resource Limits**: CPU and memory limits to prevent resource abuse
- **Network Policies**: (Add network-policy.yaml if needed)
- **Pod Security Standards**: Configured for restricted security

## 🔄 CI/CD Integration

These manifests can be integrated with:

- **Harness CD**: Use the existing `.harness/` configuration
- **GitHub Actions**: Create workflow files in `.github/workflows/`
- **GitLab CI**: Create `.gitlab-ci.yml` pipeline
- **ArgoCD**: For GitOps-based deployments

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kustomize Documentation](https://kustomize.io/)

## 🆘 Troubleshooting

### Common Issues

1. **Image Pull Errors**: Check GCR permissions and image URL
2. **Pod Not Starting**: Check resource limits and node capacity
3. **Service Not Accessible**: Verify service and ingress configuration
4. **HPA Not Scaling**: Ensure metrics-server is installed

### Debug Commands
```bash
# Describe pod for detailed info
kubectl describe pod <pod-name> -n my-app

# Check events
kubectl get events -n my-app

# Debug networking
kubectl exec -it <pod-name> -n my-app -- /bin/sh
```