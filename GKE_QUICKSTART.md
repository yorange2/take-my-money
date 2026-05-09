# GKE Deployment Quickstart

## Quick Setup (5 minutes)

### 1. Create a GKE Cluster

```bash
gcloud container clusters create last-key \
  --zone us-central1-a \
  --num-nodes 3
```

### 2. Build and Push Image to GCR

```bash
# Replace YOUR_PROJECT_ID with your GCP project ID
docker build -t gcr.io/YOUR_PROJECT_ID/last-key:v1.0.0 .
docker push gcr.io/YOUR_PROJECT_ID/last-key:v1.0.0
```

### 3. Update Deployment Configuration

```bash
# Edit k8s/deployment.yaml
# Replace PROJECT_ID with YOUR_PROJECT_ID
# Update image tag if needed
```

### 4. Deploy to Kubernetes

```bash
# Using Kustomize (recommended)
kubectl apply -k k8s/overlays/production

# Or apply all manifests directly
kubectl apply -f k8s/
```

### 5. Check Status

```bash
kubectl get pods -l app=last-key-web
kubectl get ingress
```

## Access Your App

```bash
# Get the external IP
kubectl get ingress last-key-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Or port-forward locally
kubectl port-forward svc/last-key-web 3000:80
# Visit http://localhost:3000
```

## Key Files

- **Dockerfile**: Multi-stage build for Next.js
- **k8s/deployment.yaml**: Main deployment with 3 replicas, health checks, resource limits
- **k8s/service.yaml**: ClusterIP service
- **k8s/ingress.yaml**: GCP Load Balancer ingress
- **k8s/hpa.yaml**: Auto-scaling (3-10 replicas)
- **k8s/configmap.yaml**: Environment configuration
- **k8s/overlays/**: Environment-specific configs (staging, production)

## For Full Documentation

See [k8s/README.md](k8s/README.md) for:

- Scaling and rolling updates
- Monitoring and troubleshooting
- CI/CD integration examples
- Security best practices
- Environment management

## Environment Files

### Staging (2-5 replicas)

```bash
kubectl apply -k k8s/overlays/staging
```

### Production (5-20 replicas)

```bash
kubectl apply -k k8s/overlays/production
```

## Next Steps

1. Configure your domain in `k8s/ingress.yaml`
2. Set up HTTPS with managed certificates
3. Configure secrets for sensitive data (API keys, etc.)
4. Set up Cloud Logging and Monitoring alerts
5. Integrate with your CI/CD pipeline
