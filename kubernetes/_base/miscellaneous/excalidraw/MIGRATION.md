# Migration Guide: Excalidraw to excalidraw-persist

This guide explains how to complete the migration from the previous Excalidraw setup (with MongoDB Atlas) to the new excalidraw-persist setup with PostgreSQL.

## What Changed

- **Image**: Changed from `excalidraw/excalidraw:latest` + `kiliandeca/excalidraw-storage-backend:latest` to `ghcr.io/ozencb/excalidraw-persist:0.18.0-persist.1`
- **Architecture**: Consolidated from two containers (frontend + backend) to one integrated container
- **Storage**: Changed from MongoDB Atlas to PostgreSQL
- **Backend Port**: Changed from 8080/3000 to 4000

## Prerequisites

- PostgreSQL instance running at `10.42.0.35:5432` (already deployed in your cluster)
- SOPS encryption key configured for encrypting secrets
- PostgreSQL admin credentials

## Migration Steps

### 1. Create the Excalidraw Database

Connect to your PostgreSQL instance and create the database:

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

### 2. Update the Secret

The secret needs to be updated to replace `DB_PASSWORD` and `STORAGE_URI` with `DATABASE_URL`.

1. Create a new unencrypted secret file from the template:
   ```bash
   cp secret.yaml.template secret.yaml
   ```

2. Edit `secret.yaml` and set the correct DATABASE_URL:
   ```yaml
   stringData:
     DATABASE_URL: "postgresql://admin:YOUR_ACTUAL_PASSWORD@10.42.0.35:5432/excalidraw"
   ```
   Replace `YOUR_ACTUAL_PASSWORD` with the actual PostgreSQL admin password.

3. Encrypt the secret with SOPS:
   ```bash
   sops --encrypt secret.yaml > secret.enc.yaml
   ```

4. Remove the unencrypted file:
   ```bash
   rm secret.yaml
   ```

### 3. Deploy the Changes

If using Flux CD:
```bash
git add .
git commit -m "Update excalidraw secret for PostgreSQL"
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
- DATABASE_URL is incorrect or missing
- PostgreSQL is not accessible
- Database doesn't exist

### Database connection errors

1. Verify the DATABASE_URL is correct in the secret
2. Check PostgreSQL is running: `kubectl get pods -n database`
3. Test connectivity from the pod:
   ```bash
   kubectl exec -it -n misc <excalidraw-pod> -- /bin/sh
   apk add postgresql-client  # if not available
   psql "postgresql://admin:password@10.42.0.35:5432/excalidraw"
   ```

### Application works but data doesn't persist

1. Check the database connection in logs
2. Verify the excalidraw database exists
3. Check for any migration errors in the logs
