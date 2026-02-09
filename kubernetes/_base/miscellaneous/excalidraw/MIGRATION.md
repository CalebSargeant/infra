# Migration Guide: Excalidraw to excalidraw-persist

This guide explains how to complete the migration from the previous Excalidraw setup (with MongoDB Atlas) to the new excalidraw-persist setup with PostgreSQL.

## What Changed

- **Image**: Changed from `excalidraw/excalidraw:latest` + `kiliandeca/excalidraw-storage-backend:latest` to `ghcr.io/ozencb/excalidraw-persist:0.18.0-persist.1`
- **Architecture**: Consolidated from two containers (frontend + backend) to one integrated container
- **Storage**: Changed from MongoDB Atlas to PostgreSQL
- **Backend Port**: Changed from 8080/3000 to 4000

## Prerequisites

- PostgreSQL connection string already configured in the `excalidraw` secret (under `STORAGE_URI` key)
- Ensure the PostgreSQL database exists for Excalidraw

## Migration Steps

### 1. Create the Excalidraw Database (if needed)

Connect to your PostgreSQL instance and create the database if it doesn't exist:

```bash
# Connect to the postgres pod
kubectl exec -it -n database <postgres-pod-name> -- psql -U admin -d postgres

# Create the database
CREATE DATABASE excalidraw;

# Grant permissions (if needed)
GRANT ALL PRIVILEGES ON DATABASE excalidraw TO admin;

# Exit
\q
```

### 2. Secret Configuration

The existing `excalidraw` secret already contains the `STORAGE_URI` field with the PostgreSQL connection string. The deployment has been updated to use this existing field - no secret changes are needed.

**Important**: The deployment reads the `STORAGE_URI` secret key and injects it into the container as the `DATABASE_URL` environment variable. This mapping allows the excalidraw-persist image to connect to PostgreSQL.

**Expected format**: The `STORAGE_URI` should be a PostgreSQL connection string like:
```
postgresql://username:password@host:port/database
```

To verify the secret has the correct format, you can check it with:
```bash
kubectl get secret excalidraw -n misc -o jsonpath='{.data.STORAGE_URI}' | base64 -d
```

### 3. Deploy the Changes

If using Flux CD:
```bash
git add .
git commit -m "Migrate excalidraw to persist fork: update deployment, remove backend service, update ingress"
git push
```

Flux will automatically deploy the changes.

Or deploy manually:
```bash
kubectl apply -k kubernetes/_base/miscellaneous/excalidraw/
```

### 4. Verify the Deployment

Check that the pod is running:
```bash
kubectl get pods -n misc -l app=excalidraw
```

Check the logs:
```bash
kubectl logs -n misc -l app=excalidraw
```

You should see logs indicating successful database connection and migrations.

### 5. Test the Application

1. Navigate to `https://excalidraw.sargeant.co`
2. Create a new drawing
3. Verify it saves and persists after page refresh
4. Check the PostgreSQL database to confirm data is being stored:
   ```bash
   kubectl exec -it -n database <postgres-pod-name> -- psql -U admin -d excalidraw
   \dt  # List tables
   SELECT * FROM boards LIMIT 5;  # Check if boards are being saved
   ```

## Rollback Plan

If you need to rollback to the previous setup:

1. Revert the changes in git:
   ```bash
   git revert <commit-hash>
   git push
   ```

2. Restore the old secret with MongoDB credentials

3. The old data in MongoDB Atlas will still be available

## Notes

- The new excalidraw-persist version uses a different data model (boards instead of drawings)
- Old drawings from MongoDB will NOT be automatically migrated
- If you need to preserve old drawings, you'll need to manually export/import them
- The new version supports multiple boards, which is a new feature

## Troubleshooting

### Pod fails to start

Check logs: `kubectl logs -n misc -l app=excalidraw`

Common issues:
- STORAGE_URI is incorrect or missing in the secret
- PostgreSQL is not accessible
- Database doesn't exist

### Database connection errors

1. Verify the STORAGE_URI is correct in the secret
2. Check PostgreSQL is running: `kubectl get pods -n database`
3. Test connectivity from the pod:
   ```bash
   # Option A: Test from the excalidraw pod (if psql is already available)
   kubectl exec -it -n misc <excalidraw-pod> -- psql "<connection-string-from-secret>"
   
   # Option B: If psql is NOT available, install it according to the base distro:
   #   - Alpine-based images:
   kubectl exec -it -n misc <excalidraw-pod> -- sh -c 'apk add --no-cache postgresql-client && psql "<connection-string-from-secret>"'
   #   - Debian/Ubuntu-based images:
   kubectl exec -it -n misc <excalidraw-pod> -- sh -c 'apt-get update && apt-get install -y postgresql-client && psql "<connection-string-from-secret>"'
   
   # Option C: Test from the PostgreSQL pod directly:
   kubectl exec -it -n database <postgres-pod-name> -- psql "<connection-string-from-secret>"
   ```

### Application works but data doesn't persist

1. Check the database connection in logs
2. Verify the excalidraw database exists
3. Check for any migration errors in the logs
