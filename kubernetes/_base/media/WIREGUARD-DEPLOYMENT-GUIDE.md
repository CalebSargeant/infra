# WireGuard VPN Hub - Complete Deployment Guide

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│ Kubernetes Cluster (192.168.19.0/24)                       │
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ sabnzbd  │  │qbittorrent│  │ jackett  │  │ prowlarr │  │
│  │10.99.0.10│  │10.99.0.11 │  │10.99.0.12│  │10.99.0.13│  │
│  └────┬─────┘  └────┬──────┘  └────┬─────┘  └────┬─────┘  │
│       │             │               │             │        │
│       └─────────────┴───────────────┴─────────────┘        │
│                            │                                │
│                   WireGuard Tunnel                          │
│                            │                                │
└────────────────────────────┼────────────────────────────────┘
                             │
                             ▼
              ┌──────────────────────────┐
              │   MikroTik Router        │
              │   (sgt-router)           │
              │                          │
              │  media_vpn: 10.99.0.1/24 │◄─── Services connect here
              │                          │
              │  privado_vpn: 100.64.x.x │◄─── Connects to VPN provider
              └──────────────┬───────────┘
                             │
                   WireGuard Tunnel
                             │
                             ▼
              ┌──────────────────────────┐
              │   Privado VPN Headend    │
              │   (Amsterdam)            │
              │   91.148.240.47:51820    │
              └──────────────┬───────────┘
                             │
                             ▼
                        Internet
```

## Traffic Flow

1. **RFC1918 Traffic** (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
   - Goes directly through Kubernetes cluster network
   - Services can reach each other and internal resources

2. **Non-RFC1918 Traffic** (Internet)
   - Service → MikroTik (via media_vpn)
   - MikroTik → Privado VPN (via privado_vpn)
   - Privado → Internet
   - All internet traffic appears to come from Privado VPN IP

## Deployment Steps

### Step 1: Apply MikroTik Configuration

```bash
# Upload and apply the configuration
scp mikrotik-wireguard-config.rsc sgt-router:/
ssh sgt-router 'import file=mikrotik-wireguard-config.rsc'

# Get the media_vpn public key (save this!)
ssh sgt-router '/interface wireguard print proplist=public-key where name=media_vpn'
```

### Step 2: Generate WireGuard Keys for Services

```bash
cd kubernetes/_base/media/components/wireguard-sidecar

# Generate keypairs
mkdir -p keys
cd keys

for service in sabnzbd qbittorrent jackett prowlarr nzbhydra2; do
  wg genkey | tee ${service}-private.key | wg pubkey > ${service}-public.key
  echo "Generated: $service"
  echo "  Private: $(cat ${service}-private.key)"
  echo "  Public:  $(cat ${service}-public.key)"
  echo ""
done
```

### Step 3: Update MikroTik with Service Public Keys

```bash
# For each service, update the peer
ssh sgt-router '/interface wireguard peers set [find comment="sabnzbd"] public-key="PASTE_PUBLIC_KEY"'
ssh sgt-router '/interface wireguard peers set [find comment="qbittorrent"] public-key="PASTE_PUBLIC_KEY"'
ssh sgt-router '/interface wireguard peers set [find comment="jackett"] public-key="PASTE_PUBLIC_KEY"'
ssh sgt-router '/interface wireguard peers set [find comment="prowlarr"] public-key="PASTE_PUBLIC_KEY"'
ssh sgt-router '/interface wireguard peers set [find comment="nzbhydra2"] public-key="PASTE_PUBLIC_KEY"'

# Verify peers are configured
ssh sgt-router '/interface wireguard peers print'
```

### Step 4: Create wg0.conf for Each Service

Create separate wg0.conf files for each service. See `wg0-configs-README.md` for templates.

Example for sabnzbd (`sabnzbd-wg0.conf`):

```ini
[Interface]
PrivateKey = <from sabnzbd-private.key>
Address = 10.99.0.10/32
DNS = 192.168.19.1

[Peer]
PublicKey = <MikroTik media_vpn public key from Step 1>
Endpoint = sgt-router.yourdomain.com:51880
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

**IMPORTANT:** Each service needs:
- Its own `PrivateKey`
- Its own `Address` (10.99.0.10-14)
- Same `PublicKey` (MikroTik's media_vpn)
- Same `Endpoint` (MikroTik)

### Step 5: Create Kubernetes Secrets

**Option A: Individual secrets per service**

```bash
kubectl create secret generic sabnzbd-wireguard \
  --from-file=wg0.conf=sabnzbd-wg0.conf \
  --namespace=media

# Repeat for each service...
```

**Option B: Shared secret (simpler, but all services share same IP)**

```bash
# Use one wg0.conf for all services
kubectl create secret generic wireguard-config \
  --from-file=wg0.conf=sabnzbd-wg0.conf \
  --namespace=media
```

**RECOMMENDED: Use per-service secrets for better isolation**

### Step 6: Deploy Services

```bash
cd kubernetes/_base/media

# Apply each service
kubectl apply -k sabnzbd/
kubectl apply -k qbittorrent/
kubectl apply -k jackett/
kubectl apply -k prowlarr/
kubectl apply -k nzbhydra2/
```

## Verification

### 1. Check MikroTik Connections

```bash
# Check if peers are connected (look for "current-endpoint-address")
ssh sgt-router '/interface wireguard peers print'

# Should show something like:
# 0  interface=media_vpn public-key="..." endpoint=<pod-ip>:random-port 
#    allowed-address=10.99.0.10/32 current-endpoint-address=<ip> rx=1.2KiB tx=3.4KiB
```

### 2. Check Privado VPN Connection

```bash
# Verify MikroTik connects to Privado
ssh sgt-router '/interface wireguard peers print where interface=privado_vpn'

# Should show current-endpoint-address=91.148.240.47
```

### 3. Test from Pods

```bash
# Get pod name
kubectl get pods -n media

# Test VPN IP (should return Privado VPN IP, NOT your home IP)
kubectl exec -n media sabnzbd-xxx -c sabnzbd -- curl -s ifconfig.me

# Test internal connectivity (should work without VPN)
kubectl exec -n media sabnzbd-xxx -c sabnzbd -- ping -c 2 192.168.19.1

# Check routes
kubectl exec -n media sabnzbd-xxx -c sabnzbd -- ip route

# Check WireGuard from sidecar
kubectl exec -n media sabnzbd-xxx -c wireguard -- wg show
```

## Troubleshooting

### Pods can't connect to MikroTik

**Check:**
- Firewall allows UDP 51880: `ssh sgt-router '/ip firewall filter print where dst-port=51880'`
- MikroTik is reachable from pods: `kubectl exec -n media <pod> -c wireguard -- ping <mikrotik-ip>`
- Endpoint in wg0.conf is correct (should be MikroTik's IP/hostname)

**Fix:**
```bash
# Check if firewall rule exists
ssh sgt-router '/ip firewall filter print where comment~"media_vpn"'

# If missing, add it
ssh sgt-router '/ip firewall filter add chain=input protocol=udp dst-port=51880 action=accept comment="Allow WireGuard media_vpn"'
```

### Traffic not going through VPN

**Check mangle rules:**
```bash
ssh sgt-router '/ip firewall mangle print where comment~"media"'
```

**Check routing:**
```bash
ssh sgt-router '/ip route print where routing-table=vpn_routing'
```

**Test from MikroTik:**
```bash
# Ping a service
ssh sgt-router '/ping 10.99.0.10 count=5'
```

### Some traffic goes through VPN, some doesn't

This is expected! Only non-RFC1918 traffic goes through VPN:
- ✅ `curl ifconfig.me` - through VPN
- ✅ `curl google.com` - through VPN
- ❌ `curl 192.168.19.1` - direct (not through VPN)
- ❌ `curl 10.0.0.1` - direct (not through VPN)

### DNS not resolving

**Check DNS in wg0.conf:**
```ini
DNS = 192.168.19.1
```

**Test:**
```bash
kubectl exec -n media <pod> -c <container> -- nslookup google.com
```

## Monitoring

### Real-time traffic monitoring

```bash
# Monitor specific peer
ssh sgt-router '/interface wireguard peers monitor [find comment="sabnzbd"]'

# Watch all peers
watch -n 2 'ssh sgt-router "/interface wireguard peers print"'
```

### Check routing decisions

```bash
# See which packets are being marked for VPN routing
ssh sgt-router '/ip firewall mangle print stats where comment~"media"'
```

## Maintenance

### Rotate Keys

```bash
# Generate new keypair
wg genkey | tee new-private.key | wg pubkey > new-public.key

# Update MikroTik peer
ssh sgt-router '/interface wireguard peers set [find comment="sabnzbd"] public-key="<new-public-key>"'

# Update Kubernetes secret
kubectl create secret generic wireguard-config \
  --from-file=wg0.conf=new-wg0.conf \
  --namespace=media \
  --dry-run=client -o yaml | kubectl apply -f -

# Restart pod to pick up new secret
kubectl rollout restart deployment/sabnzbd -n media
```

### Update VPN Endpoint

If Privado endpoint changes, update MikroTik:

```bash
ssh sgt-router '/interface wireguard peers set [find interface=privado_vpn] endpoint-address=<new-ip> endpoint-port=51820'
```

## Security Notes

1. **Private keys** are sensitive - store securely
2. **Each service** has its own identity on the VPN
3. **RFC1918 traffic** stays local for better performance
4. **VPN traffic** is encrypted end-to-end (pod → MikroTik → Privado)
5. **MikroTik** acts as a controlled gateway/hub

## Performance

- **WireGuard overhead**: ~60-80 bytes per packet
- **MTU**: 1420 (accounts for WireGuard + IP headers)
- **Latency**: +5-10ms (pod → MikroTik) + VPN latency
- **Throughput**: Limited by VPN provider, not WireGuard

## Next Steps

1. Monitor for a few days to ensure stability
2. Add more services as needed (just create new peers)
3. Consider per-service secrets for better isolation
4. Set up alerts for VPN disconnections
5. Document your specific endpoint/DNS settings
