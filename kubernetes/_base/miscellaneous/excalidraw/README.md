# Excalidraw Deployment

This directory contains Kubernetes manifests for deploying Excalidraw with PostgreSQL storage backend on the firefly cluster.

## Architecture

- **Excalidraw with Persistence**: Uses `ghcr.io/ozencb/excalidraw-persist:0.18.0-persist.1` which includes both frontend and backend in a single container
- **Database**: PostgreSQL (shared instance at 10.42.0.35:5432)
- **Ingress**: Traefik with automatic HTTPS via Let's Encrypt

## Setup Instructions

### 1. PostgreSQL Database Setup

The deployment uses the existing PostgreSQL instance. Create a database for Excalidraw:

```sql
CREATE DATABASE excalidraw;
-- Grant permissions to the admin user if needed
GRANT ALL PRIVILEGES ON DATABASE excalidraw TO admin;
```

### 2. Secret Configuration

The secret is already configured with the `STORAGE_URI` field containing the PostgreSQL connection string. The deployment uses this existing secret - no changes needed.

**Note**: Ensure the database referenced in `STORAGE_URI` exists (see step 1 above).

### 3. Update the Ingress Hostname

Edit `ingress.yaml` and update the hostname to your desired domain:

```yaml
host: excalidraw.sargeant.co  # Change this to your domain
```

Make sure your DNS is configured to point to your firefly cluster's ingress.

### 4. Deploy to Firefly Cluster

If you're using Flux CD (based on your existing setup):

1. Commit these changes to your git repository
2. Flux will automatically pick up the changes and deploy

Or deploy manually:

```bash
kubectl apply -k kubernetes/_base/miscellaneous/excalidraw/
```

### 5. Verify Deployment

Check the deployment status:

```bash
kubectl get pods -n misc
kubectl get svc -n misc
kubectl get ingress -n misc
```

Check the logs:

```bash
kubectl logs -n misc -l app=excalidraw
```

## API Endpoints

The excalidraw-persist backend provides the following endpoints on port 4000:

- `GET /health` - Health check
- `GET /api/boards` - List all boards
- `GET /api/boards/:id` - Get a specific board
- `POST /api/boards` - Create a new board
- `PUT /api/boards/:id` - Update an existing board
- `DELETE /api/boards/:id` - Delete a board

## Usage

1. Navigate to `https://excalidraw.sargeant.co` (or your configured domain)
2. Create your drawings
3. Drawings are automatically saved to PostgreSQL
4. You can create multiple boards and share board IDs with others

## Features

- **Persistent Storage**: All drawings are saved to PostgreSQL
- **Multiple Boards**: Create and manage multiple drawing boards
- **Collaboration**: Share board links with others for real-time collaboration
- **Auto-save**: Drawings are automatically saved as you work

## Customization

### Resource Limits

Adjust CPU/memory in `deployment.yaml`:

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

### Timezone

Change the timezone in `deployment.yaml`:

```yaml
env:
  - name: TZ
    value: "Europe/Amsterdam"  # Change this
```

## Troubleshooting

### Backend can't connect to PostgreSQL

1. Check the PostgreSQL connection string is correct in the secret
2. Verify the excalidraw database exists in PostgreSQL
3. Check backend logs: `kubectl logs -n misc -l app=excalidraw`
4. Verify PostgreSQL is accessible: `kubectl exec -it -n database <postgres-pod> -- psql -U admin -d excalidraw`

### Ingress not working

1. Verify cert-manager is installed and working
2. Check Traefik is running
3. Verify DNS points to your cluster
4. Check ingress status: `kubectl describe ingress -n misc`

### Application errors

1. Check pod status: `kubectl get pods -n misc`
2. View logs: `kubectl logs -n misc -l app=excalidraw`
3. Verify the DATABASE_URL environment variable is set correctly
4. Check if the database migrations ran successfully

## Notes

- The excalidraw-persist image includes both frontend (port 80) and backend (port 4000) in a single container
- PostgreSQL is shared with other applications in the cluster
- The application handles database migrations automatically on startup
- Boards are stored in the PostgreSQL database with versioning support
