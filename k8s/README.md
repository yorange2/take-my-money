# Kubernetes Deployment Guide

This directory contains Kubernetes manifests for deploying the Take My Money application to Google Cloud GKE.

## Directory Structure

```
k8s/
├── deployment.yaml          # Main deployment manifest
├── service.yaml             # ClusterIP service
├── ingress.yaml             # GCP Load Balancer ingress
├── configmap.yaml           # Environment configuration
├── hpa.yaml                 # Horizontal Pod Autoscaler
├── serviceaccount.yaml      # Service account for RBAC
├── kustomization.yaml       # Base Kustomize configuration
├── overlays/
│   ├── production/          # Production environment overrides
│   │   └── kustomization.yaml
│   └── staging/             # Staging environment overrides
│       └── kustomization.yaml
└── README.md
```

## Prerequisites

1. **GKE Cluster**: Create one with:

   ```bash
   gcloud container clusters create take-my-money \
     --zone us-central1-a \
     --num-nodes 3 \
     --enable-autoscaling \
     --min-nodes 3 \
     --max-nodes 10
   ```

2. **kubectl**: Install and configure to access your GKE cluster

3. **Container Registry**: Setup Google Container Registry (GCR)

   ```bash
   gcloud auth configure-docker gcr.io
   ```

4. **Kustomize**: Install from https://kustomize.io/

## Pre-Deployment Setup

### 1. Build and Push Docker Image

```bash
# From project root
docker build -t gcr.io/YOUR_PROJECT_ID/take-my-money:v1.0.0 .
docker push gcr.io/YOUR_PROJECT_ID/take-my-money:v1.0.0
```

### 2. Update Configuration

Edit `deployment.yaml`:

- Replace `PROJECT_ID` with your GCP project ID
- Update image tag to match your build

Edit `configmap.yaml`:

- Set `api_url` to your API endpoint
- Add any additional environment variables needed

Edit `k8s/overlays/production/kustomization.yaml` and `k8s/overlays/staging/kustomization.yaml`:

- Configure API URLs for each environment
- Adjust resource limits as needed

### 3. Configure Ingress (Optional but Recommended)

For HTTPS with managed certificate:

```yaml
# Edit ingress.yaml
annotations:
  networking.gke.io/managed-certificates: 'take-my-money-cert'

---
# Add to ingress.yaml
apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
  name: take-my-money-cert
spec:
  domains:
    - take-my-money.com
```

## Deployment

### Option 1: Using Kustomize (Recommended)

**Deploy to staging:**

```bash
kubectl apply -k k8s/overlays/staging
```

**Deploy to production:**

```bash
kubectl apply -k k8s/overlays/production
```

**Deploy base configuration:**

```bash
kubectl apply -k k8s
```

### Option 2: Direct kubectl

**Apply all manifests:**

```bash
kubectl apply -f k8s/
```

**Apply specific manifests:**

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

## Verification

### Check Deployment Status

```bash
# Watch rollout
kubectl rollout status deployment/take-my-money-web

# Get pod status
kubectl get pods -l app=take-my-money-web

# View pod logs
kubectl logs -l app=take-my-money-web --tail=50 -f

# Describe deployment
kubectl describe deployment take-my-money-web
```

### Access the Application

```bash
# Port forward to local machine
kubectl port-forward svc/take-my-money-web 3000:80

# Access at http://localhost:3000
```

### Check Ingress

```bash
kubectl get ingress take-my-money-ingress
kubectl describe ingress take-my-money-ingress

# Get external IP (may take a few minutes)
kubectl get ingress take-my-money-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## Scaling

### Manual Scaling

```bash
# Scale to 5 replicas
kubectl scale deployment take-my-money-web --replicas=5
```

### Automatic Scaling

HPA is already configured (3-10 replicas). Monitor with:

```bash
kubectl get hpa take-my-money-web-hpa --watch
```

## Updates & Rollouts

### Update Image

```bash
# Using kubectl patch
kubectl set image deployment/take-my-money-web \
  web=gcr.io/YOUR_PROJECT_ID/take-my-money:v1.0.1 \
  --record

# Or with Kustomize
kustomize edit set image gcr.io/YOUR_PROJECT_ID/take-my-money:v1.0.1
kubectl apply -k k8s/overlays/production
```

### Rollback

```bash
# View rollout history
kubectl rollout history deployment/take-my-money-web

# Rollback to previous version
kubectl rollout undo deployment/take-my-money-web

# Rollback to specific revision
kubectl rollout undo deployment/take-my-money-web --to-revision=2
```

## Monitoring & Logs

### View Logs

```bash
# Latest logs
kubectl logs deployment/take-my-money-web --tail=100

# Stream logs
kubectl logs deployment/take-my-money-web -f

# Logs from specific pod
kubectl logs POD_NAME -f
```

### Pod Events

```bash
kubectl describe pod POD_NAME
```

### GCP Cloud Logging

```bash
# Logs are automatically sent to Cloud Logging
gcloud logging read "resource.type=k8s_container AND resource.labels.deployment_name=take-my-money-web" --limit 50
```

## Environment Variables

The deployment uses ConfigMap for environment variables. Update in `configmap.yaml`:

```yaml
data:
  app_name: 'Take My Money'
  api_url: 'https://api.example.com'
```

For secrets (API keys, passwords):

```bash
# Create secret
kubectl create secret generic take-my-money-secrets \
  --from-literal=database_password=xxx \
  --from-literal=api_key=yyy

# Add to deployment
env:
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: take-my-money-secrets
      key: database_password
```

## Resource Management

Current resource limits:

- **CPU Request**: 100m | **Limit**: 500m
- **Memory Request**: 256Mi | **Limit**: 512Mi

Adjust in `deployment.yaml` and overlay files based on your load testing.

## Cleanup

```bash
# Delete all resources
kubectl delete -k k8s/overlays/production

# Or specific resource
kubectl delete deployment take-my-money-web
kubectl delete service take-my-money-web
kubectl delete ingress take-my-money-ingress
```

## Common Issues

### Pods not starting

```bash
kubectl describe pod POD_NAME
kubectl logs POD_NAME
```

### Image pull errors

```bash
# Verify image exists in GCR
gcloud container images list --repository=gcr.io/YOUR_PROJECT_ID
```

### Ingress in Pending

- Wait 5-10 minutes for load balancer to initialize
- Check ingress annotation errors
- Verify service is accessible

### Health check failures

- Check app is listening on port 3000
- Verify `/` endpoint responds with 200 status
- Increase `initialDelaySeconds` if app takes time to start

## Best Practices

1. **Use Kustomize overlays** for environment-specific configs
2. **Always set resource requests/limits** for predictable scaling
3. **Use ConfigMap for non-sensitive** config, Secrets for sensitive data
4. **Enable RBAC** with proper ServiceAccount permissions
5. **Use NetworkPolicies** to restrict traffic between pods
6. **Monitor with Cloud Monitoring** for alerts
7. **Set up log aggregation** with Cloud Logging
8. **Use container image scanning** to find vulnerabilities

## Security Considerations

- ✅ Non-root user (UID 1001)
- ✅ Read-only filesystem
- ✅ Pod security context configured
- ✅ Resource limits set
- ✅ Health checks in place
- ⚠️ Review ingress security policies
- ⚠️ Configure Network Policies if needed
- ⚠️ Use RBAC roles with minimal permissions

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Deploy to GKE
  run: |
    gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE
    docker build -t gcr.io/$PROJECT_ID/take-my-money:$GITHUB_SHA .
    docker push gcr.io/$PROJECT_ID/take-my-money:$GITHUB_SHA
    kustomize edit set image gcr.io/$PROJECT_ID/take-my-money:$GITHUB_SHA
    kubectl apply -k k8s/overlays/production
```

## References

- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Kustomize Guide](https://kustomize.io/)
- [Next.js Deployment](https://nextjs.org/docs/deployment)
