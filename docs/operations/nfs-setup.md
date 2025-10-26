# NFS Server Setup on Firefly (Bare-Metal)

This guide covers setting up an NFS server directly on the firefly host machine to share `/mnt/raid` storage with Linux clients (like the ember VM and other systems).

## Overview

The NFS server runs directly on the firefly host machine for optimal performance and reliability. This provides shared storage for media files and application data across multiple systems.

## Prerequisites

- Firefly host machine with `/mnt/raid` storage mounted
- SSH access to the firefly host
- Root or sudo access on firefly host

## Server Setup Instructions

### 1. Install NFS Server on Firefly Host

SSH into the firefly host and run the following commands:

```bash
# Install NFS server
sudo apt update
sudo apt install -y nfs-kernel-server

# Ensure /mnt/raid exists (should already be mounted)
sudo mkdir -p /mnt/raid

# Create subdirectories for different media types
sudo mkdir -p /mnt/raid/{movies,series,downloads,music,photos,config}

# Set appropriate permissions (keep existing ownership)
sudo chmod -R 755 /mnt/raid
```

### 2. Configure NFS Exports

Create the NFS exports configuration:

```bash
sudo tee /etc/exports << 'EOF'
# NFS exports for Linux clients (ember VM, other systems)
/mnt/raid *(rw,sync,no_subtree_check,no_root_squash,fsid=0)
/mnt/raid/movies *(rw,sync,no_subtree_check,no_root_squash)
/mnt/raid/series *(rw,sync,no_subtree_check,no_root_squash)
/mnt/raid/downloads *(rw,sync,no_subtree_check,no_root_squash)
/mnt/raid/music *(rw,sync,no_subtree_check,no_root_squash)
/mnt/raid/photos *(rw,sync,no_subtree_check,no_root_squash)
/mnt/raid/config *(rw,sync,no_subtree_check,no_root_squash)
EOF
```

### 3. Start and Enable NFS Services

```bash
# Enable and start NFS services
sudo systemctl enable nfs-kernel-server
sudo systemctl restart nfs-kernel-server
sudo systemctl restart nfs-mountd
sudo systemctl restart nfs-idmapd

# Export the shares
sudo exportfs -ra

# Verify exports are active
sudo exportfs -v
sudo showmount -e localhost
```

### 4. Get Firefly IP Address

Note the firefly host IP address for client configuration:

```bash
# Show all network interfaces
ip addr show

# Or just get the main IP
hostname -I | awk '{print $1}'
```

## Connecting Linux Clients

### Install NFS Client

On any Linux system that needs to access the NFS shares (like ember VM):

```bash
# Install NFS client tools
sudo apt update
sudo apt install -y nfs-common
```

### Test NFS Connection

Replace `FIREFLY_IP` with your actual firefly IP address:

```bash
# Test if NFS server is accessible
showmount -e FIREFLY_IP

# Create temporary mount point
sudo mkdir -p /mnt/test-firefly

# Mount the root NFS share
sudo mount -t nfs4 FIREFLY_IP:/ /mnt/test-firefly

# List available directories
ls -la /mnt/test-firefly/

# Test write access
sudo touch /mnt/test-firefly/test-file
ls -la /mnt/test-firefly/test-file

# Cleanup test
sudo rm /mnt/test-firefly/test-file
sudo umount /mnt/test-firefly
sudo rmdir /mnt/test-firefly
```

### Permanent Client Setup

#### Create Mount Points

```bash
# Create mount points on client system
sudo mkdir -p /mnt/raid/{movies,series,downloads,music,photos,config}
```

#### Manual Mounting

```bash
# Mount specific directories
sudo mount -t nfs4 FIREFLY_IP:/movies /mnt/raid/movies
sudo mount -t nfs4 FIREFLY_IP:/series /mnt/raid/series
sudo mount -t nfs4 FIREFLY_IP:/downloads /mnt/raid/downloads
sudo mount -t nfs4 FIREFLY_IP:/config /mnt/raid/config

# Or mount the entire /mnt/raid
sudo mount -t nfs4 FIREFLY_IP:/ /mnt/raid
```

#### Automatic Mounting (fstab)

For permanent mounts that survive reboots, add to `/etc/fstab`:

```bash
# Edit fstab
sudo nano /etc/fstab

# Add these lines (replace FIREFLY_IP with actual IP)
FIREFLY_IP:/movies    /mnt/raid/movies    nfs4    defaults,_netdev    0   0
FIREFLY_IP:/series    /mnt/raid/series    nfs4    defaults,_netdev    0   0
FIREFLY_IP:/downloads /mnt/raid/downloads nfs4    defaults,_netdev    0   0
FIREFLY_IP:/config    /mnt/raid/config    nfs4    defaults,_netdev    0   0

# Or mount entire raid directory
# FIREFLY_IP:/         /mnt/raid           nfs4    defaults,_netdev    0   0
```

#### Test fstab Configuration

```bash
# Test mounting all fstab entries
sudo mount -a

# Verify mounts
df -h | grep nfs
mount | grep nfs4
```

## Configuration Files

The NFS server uses standard Linux configuration files:

- **`/etc/exports`** - NFS server export definitions
- **`/etc/fstab`** - Client-side permanent mount configuration (on client systems)

## Troubleshooting

### Check NFS Server Status

```bash
# On firefly host
sudo systemctl status nfs-kernel-server
sudo exportfs -v
sudo showmount -e localhost
```

### Check Network Connectivity

```bash
# Test if NFS port is accessible
telnet YOUR_FIREFLY_IP 2049

# Check firewall (if applicable)
sudo ufw status
```

### Check Client Connectivity

```bash
# From client system, test NFS server connectivity
telnet FIREFLY_IP 2049

# Check available exports from client
showmount -e FIREFLY_IP

# Check current NFS mounts on client
mount | grep nfs4
df -h | grep nfs
```

### Common Issues

1. **Permission Denied**: Check that directories are owned by `nobody:nogroup`
2. **Connection Refused**: Verify NFS server is running and ports are open
3. **Mount Fails**: Check exports configuration and restart NFS services

## Security Considerations

- The current configuration allows access from any IP (`*`). For production, consider restricting to specific networks:
  ```bash
  /mnt/raid 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash,fsid=0)
  ```

- Consider using `all_squash` instead of `no_root_squash` if you don't need root access:
  ```bash
  /mnt/raid *(rw,sync,no_subtree_check,all_squash,anonuid=65534,anongid=65534,fsid=0)
  ```

## Usage Examples

### Direct File Access

Once mounted, NFS shares appear as local directories:

```bash
# Access files directly
ls /mnt/raid/movies/
cp /home/user/video.mp4 /mnt/raid/movies/

# Applications can read/write directly
vlc /mnt/raid/movies/movie.mkv
```

### Application Configuration

Configure applications to use NFS mount points:

```bash
# Jellyfin media paths
Media: /mnt/raid/movies, /mnt/raid/series
Config: /mnt/raid/config/jellyfin

# Download client paths
Downloads: /mnt/raid/downloads
Incomplete: /mnt/raid/downloads/.incomplete
```

## Monitoring

Monitor NFS performance and connections:

```bash
# Show NFS statistics
nfsstat -s

# Show active NFS connections
ss -tan | grep :2049
```