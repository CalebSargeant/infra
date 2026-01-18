# PostgreSQL Alternative for WordPress

## Current Implementation

The WordPress deployment uses MariaDB as a sidecar container. This is the recommended approach because:

1. **Full Compatibility**: WordPress and Elementor are designed and tested with MySQL/MariaDB
2. **Plugin Ecosystem**: Most WordPress plugins expect MySQL
3. **Reliability**: No compatibility layers or adapters needed
4. **Performance**: Direct MySQL support without translation overhead

## PostgreSQL Alternative (Advanced)

If you prefer to use the existing PostgreSQL StatefulSet, here's how to do it:

### Option 1: Custom Docker Image (Recommended)

A Dockerfile is provided in `/dockerfiles/wordpress-postgres/` that:
- Extends the official WordPress image
- Installs PostgreSQL PHP extensions (pdo_pgsql, pgsql)
- Includes the PG4WP plugin for PostgreSQL compatibility

#### Steps:

1. Build the custom image:
```bash
cd dockerfiles/wordpress-postgres
docker build -t ghcr.io/calebsargeant/wordpress-postgres:latest .
docker push ghcr.io/calebsargeant/wordpress-postgres:latest
```

2. Update `deployment.yaml` to use the custom image:
```yaml
containers:
  - name: wordpress
    image: ghcr.io/calebsargeant/wordpress-postgres:latest
```

3. Update database environment variables:
```yaml
env:
  - name: WORDPRESS_DB_HOST
    value: "postgres.database.svc.cluster.local:5432"
```

4. Create a database in PostgreSQL:
```bash
kubectl exec -n database postgres-0 -- psql -U postgres -c "CREATE DATABASE wordpress;"
```

### Option 2: Runtime Configuration

Install PG4WP manually after WordPress starts:

1. Access the WordPress pod
2. Download PG4WP plugin
3. Copy `db.php` to wp-content directory
4. Configure wp-config.php

This is less reliable and not recommended for production.

## Limitations of PostgreSQL Approach

⚠️ **Important Considerations:**

1. **PG4WP Compatibility**: The PG4WP plugin hasn't been updated since 2017
2. **Elementor**: May have compatibility issues with PostgreSQL
3. **Plugin Support**: Many WordPress plugins don't test with PostgreSQL
4. **WordPress Core**: Assumes MySQL in many places

## Recommendation

**Use MariaDB** (current implementation) for:
- Maximum compatibility
- Better Elementor support
- Easier troubleshooting
- Production reliability

**Use PostgreSQL** only if:
- You have specific requirements for PostgreSQL
- You're willing to test thoroughly
- You can handle plugin compatibility issues

## Resources

- [PG4WP Plugin](https://wordpress.org/plugins/pg4wp/)
- [WordPress Database Requirements](https://wordpress.org/about/requirements/)
- [PostgreSQL for WordPress Discussion](https://core.trac.wordpress.org/ticket/17847)
