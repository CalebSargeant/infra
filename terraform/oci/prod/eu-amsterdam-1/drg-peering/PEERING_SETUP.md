# DRG Peering Setup - Amsterdam to Johannesburg

This guide describes how to complete the DRG peering between **Amsterdam (eu-amsterdam-1)** and **Johannesburg (af-johannesburg-1) FranklinHouse**.

## Architecture

```
┌─────────────────────────────┐         ┌─────────────────────────────┐
│   Amsterdam (AMS)            │         │   Johannesburg (JHB)        │
│   192.168.223.0/24          │◄───────►│   192.168.72.0/24          │
│   (Sargeant)                 │         │   (FranklinHouse)          │
│   DRG (eu-amsterdam-1)      │         │   DRG (af-johannesburg-1)  │
│   └─ RPC (Acceptor)         │         │   └─ RPC (Requestor)       │
└─────────────────────────────┘         └─────────────────────────────┘
```

## Prerequisites

- ✅ DRG peering module copied from franklinhouse
- ✅ Amsterdam drg-peering configuration created
- ✅ Network routes updated to include FranklinHouse JHB network (192.168.72.0/24)
- Johannesburg RPC already exists (from FranklinHouse deployment)

## Deployment Steps

### 1. Deploy Amsterdam Network Updates

First, update the network configuration to add the route to JHB:

```bash
cd ~/repos/calebsargeant/infra/terraform/oci/prod/eu-amsterdam-1/network
terragrunt apply
```

This adds the route for `192.168.72.0/24` (FranklinHouse JHB) to all route tables.

### 2. Deploy Amsterdam RPC

```bash
cd ~/repos/calebsargeant/infra/terraform/oci/prod/eu-amsterdam-1/drg-peering
terragrunt apply
```

After deployment, get the RPC OCID:

```bash
AMS_RPC_ID=$(terragrunt output -raw rpc_id)
echo $AMS_RPC_ID
```

Save this OCID - example:
```
ocid1.remotepeeringconnection.oc1.eu-amsterdam-1.aaaaaaaa...
```

### 3. Get Johannesburg RPC OCID

From the FranklinHouse infrastructure:

```bash
cd ~/repos/magmamoose/franklinhouse/terraform/oci/prod/af-johannesburg-1/drg-peering
JHB_RPC_ID=$(terragrunt output -raw rpc_id)
echo $JHB_RPC_ID
```

### 4. Establish Peering Connection

The connection is initiated from **Johannesburg (requestor)** to **Amsterdam (acceptor)**:

```bash
# Ensure you have the right region set for JHB
export OCI_REGION="af-johannesburg-1"

# Establish peering
oci network remote-peering-connection connect \
  --region af-johannesburg-1 \
  --remote-peering-connection-id $JHB_RPC_ID \
  --peer-id $AMS_RPC_ID \
  --peer-region-name eu-amsterdam-1
```

### 5. Verify Peering Status

Check both sides of the peering:

```bash
# Check Johannesburg RPC
oci network remote-peering-connection get \
  --region af-johannesburg-1 \
  --remote-peering-connection-id $JHB_RPC_ID \
  --query 'data.{"peering-status":"peering-status",state:state}'

# Check Amsterdam RPC
oci network remote-peering-connection get \
  --region eu-amsterdam-1 \
  --remote-peering-connection-id $AMS_RPC_ID \
  --query 'data.{"peering-status":"peering-status",state:state}'
```

Both should show:
```json
{
  "peering-status": "PEERED",
  "state": "AVAILABLE"
}
```

### 6. Test Connectivity

From an Amsterdam instance:
```bash
ping 192.168.72.X  # Replace with JHB instance IP
```

From a Johannesburg instance:
```bash
ping 192.168.223.X  # Replace with Amsterdam instance IP
```

## Network Summary

- **Amsterdam (Sargeant)**: 192.168.223.0/24
- **Johannesburg (FranklinHouse)**: 192.168.72.0/24
- **Sargeant On-Prem**: 192.168.19.0/24
- **FranklinHouse On-Prem**: 192.168.68.0/22

## Troubleshooting

### Peering Status Issues
- Ensure both RPCs are in `AVAILABLE` state before connecting
- Verify OCIDs are correct
- Connection must be initiated from one side only (Johannesburg)

### Connectivity Issues
1. Check Security Lists/NSGs allow ICMP
2. Verify route tables in both regions
3. Confirm DRG attachments to VCNs
4. Verify peering status is `PEERED`

## Quick Reference Commands

```bash
# Deploy Amsterdam components
cd ~/repos/calebsargeant/infra/terraform/oci/prod/eu-amsterdam-1
cd network && terragrunt apply
cd ../drg-peering && terragrunt apply
AMS_RPC_ID=$(terragrunt output -raw rpc_id)

# Get Johannesburg RPC
cd ~/repos/magmamoose/franklinhouse/terraform/oci/prod/af-johannesburg-1/drg-peering
JHB_RPC_ID=$(terragrunt output -raw rpc_id)

# Establish peering (from JHB side)
oci network remote-peering-connection connect \
  --region af-johannesburg-1 \
  --remote-peering-connection-id $JHB_RPC_ID \
  --peer-id $AMS_RPC_ID \
  --peer-region-name eu-amsterdam-1
```
