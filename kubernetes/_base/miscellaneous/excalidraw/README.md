# Excalidraw Deployment

This directory contains Kubernetes manifests for deploying Excalidraw with MongoDB Atlas storage backend on the firefly cluster.

## Architecture

- **Excalidraw Frontend**: Official excalidraw/excalidraw Docker image
- **Storage Backend**: Custom Node.js Express API that connects to MongoDB Atlas
- **Database**: MongoDB Atlas (free tier)
- **Ingress**: Traefik with automatic HTTPS via Let's Encrypt

## Setup Instructions

### 1. MongoDB Atlas Setup

1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) and create a free account if you don't have one
2. Create a new cluster (free M0 tier)
3. Create a database user:
   - Go to Database Access
   - Add a new database user with username and password
   - Save these credentials
4. Configure network access:
   - Go to Network Access
   - Add IP address: `0.0.0.0/0` (allow from anywhere) or your cluster's public IP
5. Get your connection string:
   - Go to your cluster
   - Click "Connect"
   - Choose "Connect your application"
   - Copy the connection string (it will look like: `mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority`)

### 2. Update the Secret

Edit `secret.yaml` and replace the MongoDB connection string:

```yaml
stringData:
  MONGODB_URI: "mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/excalidraw?retryWrites=true&w=majority"
```

**Important**: Replace:
- `username` with your MongoDB Atlas username
- `password` with your MongoDB Atlas password
- `cluster0.xxxxx` with your actual cluster URL
- The database name is set to `excalidraw`

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
kubectl apply -k /Users/caleb/Nextcloud/repos/calebsargeant/infra/kubernetes/_base/miscellaneous/excalidraw/
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
# Frontend logs
kubectl logs -n misc -l app=excalidraw -c excalidraw

# Backend logs
kubectl logs -n misc -l app=excalidraw -c excalidraw-backend
```

## API Endpoints

The storage backend provides the following endpoints:

- `GET /health` - Health check
- `GET /api/drawings` - List all drawings
- `GET /api/drawings/:id` - Get a specific drawing
- `POST /api/drawings` - Save a new drawing
- `PUT /api/drawings/:id` - Update an existing drawing
- `DELETE /api/drawings/:id` - Delete a drawing

## Usage

1. Navigate to `https://excalidraw.sargeant.co` (or your configured domain)
2. Create your drawings
3. Drawings are automatically saved to MongoDB Atlas
4. You can share drawing IDs with others

## Customization

### Resource Limits

Adjust CPU/memory in `deployment.yaml`:

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "50m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Timezone

Change the timezone in `deployment.yaml`:

```yaml
env:
  - name: TZ
    value: "Europe/Amsterdam"  # Change this
```

## Troubleshooting

### Backend can't connect to MongoDB

1. Check the MongoDB Atlas connection string is correct
2. Verify network access is configured in MongoDB Atlas
3. Check backend logs: `kubectl logs -n misc -l app=excalidraw -c excalidraw-backend`

### Ingress not working

1. Verify cert-manager is installed and working
2. Check Traefik is running
3. Verify DNS points to your cluster
4. Check ingress status: `kubectl describe ingress -n misc`

## Notes

- The backend container builds and installs dependencies on startup, so initial startup may take a minute
- MongoDB Atlas free tier has storage limits (512 MB)
- Drawings are stored as JSON documents in the `drawings` collection
- The frontend uses the official Excalidraw image which gets regular updates
