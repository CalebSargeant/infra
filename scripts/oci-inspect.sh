#!/bin/bash
# OCI Resource Inspection Script
# This script gathers OCIDs for existing resources to prepare for Terraform imports

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}OCI Resource Inspection Script${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if OCI CLI is installed
if ! command -v oci &> /dev/null; then
    echo -e "${RED}Error: OCI CLI is not installed${NC}"
    echo "Install it with: brew install oci-cli"
    exit 1
fi

# Check required environment variables
REQUIRED_VARS=("OCI_TENANCY_OCID" "OCI_COMPARTMENT_OCID" "OCI_REGION")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo -e "${RED}Error: $var environment variable is not set${NC}"
        exit 1
    fi
done

COMPARTMENT_ID="${OCI_COMPARTMENT_OCID}"
REGION="${OCI_REGION}"

echo -e "\n${YELLOW}Compartment:${NC} $COMPARTMENT_ID"
echo -e "${YELLOW}Region:${NC} $REGION"

# Output file for terraform import commands
IMPORT_FILE="terraform-import-commands.sh"
echo "#!/bin/bash" > $IMPORT_FILE
echo "# Terraform import commands for OCI resources" >> $IMPORT_FILE
echo "# Generated on $(date)" >> $IMPORT_FILE
echo "" >> $IMPORT_FILE

echo -e "\n${GREEN}=== VCN (Virtual Cloud Networks) ===${NC}"
VCN_LIST=$(oci network vcn list \
    --compartment-id "$COMPARTMENT_ID" \
    --region "$REGION" \
    --all 2>/dev/null || echo '{"data":[]}')

echo "$VCN_LIST" | jq -r '.data[] | "  VCN: \(.["display-name"]) | OCID: \(.id) | CIDR: \(.["cidr-block"])"'

# Get VCN OCIDs for later use
VCN_OCIDS=$(echo "$VCN_LIST" | jq -r '.data[].id')

for VCN_OCID in $VCN_OCIDS; do
    VCN_NAME=$(echo "$VCN_LIST" | jq -r --arg id "$VCN_OCID" '.data[] | select(.id == $id) | .["display-name"]')
    echo "" >> $IMPORT_FILE
    echo "# VCN: $VCN_NAME" >> $IMPORT_FILE
    echo "# terragrunt import oci_core_virtual_network.this $VCN_OCID" >> $IMPORT_FILE

    echo -e "\n${GREEN}=== Subnets in VCN: $VCN_NAME ===${NC}"
    SUBNET_LIST=$(oci network subnet list \
        --compartment-id "$COMPARTMENT_ID" \
        --vcn-id "$VCN_OCID" \
        --region "$REGION" \
        --all 2>/dev/null || echo '{"data":[]}')

    echo "$SUBNET_LIST" | jq -r '.data[] | "  Subnet: \(.["display-name"]) | OCID: \(.id) | CIDR: \(.["cidr-block"])"'

    echo "$SUBNET_LIST" | jq -r '.data[] | "# terragrunt import oci_core_subnet.this \(.id) # \(.["display-name"])"' >> $IMPORT_FILE

    echo -e "\n${GREEN}=== Internet Gateways in VCN: $VCN_NAME ===${NC}"
    IGW_LIST=$(oci network internet-gateway list \
        --compartment-id "$COMPARTMENT_ID" \
        --vcn-id "$VCN_OCID" \
        --region "$REGION" \
        --all 2>/dev/null || echo '{"data":[]}')

    echo "$IGW_LIST" | jq -r '.data[] | "  IGW: \(.["display-name"]) | OCID: \(.id)"'
    echo "$IGW_LIST" | jq -r '.data[] | "# terragrunt import oci_core_internet_gateway.this \(.id) # \(.["display-name"])"' >> $IMPORT_FILE

    echo -e "\n${GREEN}=== Route Tables in VCN: $VCN_NAME ===${NC}"
    RT_LIST=$(oci network route-table list \
        --compartment-id "$COMPARTMENT_ID" \
        --vcn-id "$VCN_OCID" \
        --region "$REGION" \
        --all 2>/dev/null || echo '{"data":[]}')

    echo "$RT_LIST" | jq -r '.data[] | "  Route Table: \(.["display-name"]) | OCID: \(.id)"'
    echo "$RT_LIST" | jq -r '.data[] | "# terragrunt import oci_core_route_table.this \(.id) # \(.["display-name"])"' >> $IMPORT_FILE

    echo -e "\n${GREEN}=== Network Security Groups in VCN: $VCN_NAME ===${NC}"
    NSG_LIST=$(oci network nsg list \
        --compartment-id "$COMPARTMENT_ID" \
        --vcn-id "$VCN_OCID" \
        --region "$REGION" \
        --all 2>/dev/null || echo '{"data":[]}')

    echo "$NSG_LIST" | jq -r '.data[] | "  NSG: \(.["display-name"]) | OCID: \(.id)"'
    echo "$NSG_LIST" | jq -r '.data[] | "# terragrunt import oci_core_network_security_group.this \(.id) # \(.["display-name"])"' >> $IMPORT_FILE

    echo -e "\n${GREEN}=== DRG Attachments in VCN: $VCN_NAME ===${NC}"
    DRG_ATTACH_LIST=$(oci network drg-attachment list \
        --compartment-id "$COMPARTMENT_ID" \
        --vcn-id "$VCN_OCID" \
        --region "$REGION" \
        --all 2>/dev/null || echo '{"data":[]}')

    echo "$DRG_ATTACH_LIST" | jq -r '.data[] | "  DRG Attachment: \(.["display-name"]) | OCID: \(.id) | DRG: \(.["drg-id"])"'
done

echo -e "\n${GREEN}=== Compute Instances ===${NC}"
INSTANCE_LIST=$(oci compute instance list \
    --compartment-id "$COMPARTMENT_ID" \
    --region "$REGION" \
    --all 2>/dev/null || echo '{"data":[]}')

echo "$INSTANCE_LIST" | jq -r '.data[] | select(.["lifecycle-state"] != "TERMINATED") | "  Instance: \(.["display-name"]) | OCID: \(.id) | Shape: \(.shape) | State: \(.["lifecycle-state"]) | FD: \(.["fault-domain"])"'

echo "" >> $IMPORT_FILE
echo "# Compute Instances" >> $IMPORT_FILE
echo "$INSTANCE_LIST" | jq -r '.data[] | select(.["lifecycle-state"] != "TERMINATED") | "# terragrunt import oci_core_instance.this[\"\(.["display-name"])\"] \(.id)"' >> $IMPORT_FILE

echo -e "\n${GREEN}=== MySQL DB Systems ===${NC}"
MYSQL_LIST=$(oci mysql db-system list \
    --compartment-id "$COMPARTMENT_ID" \
    --region "$REGION" \
    --all 2>/dev/null || echo '{"data":[]}')

echo "$MYSQL_LIST" | jq -r '.data[] | select(.["lifecycle-state"] != "DELETED") | "  MySQL: \(.["display-name"]) | OCID: \(.id) | Shape: \(.["shape-name"]) | State: \(.["lifecycle-state"])"'

echo "" >> $IMPORT_FILE
echo "# MySQL DB Systems" >> $IMPORT_FILE
echo "$MYSQL_LIST" | jq -r '.data[] | select(.["lifecycle-state"] != "DELETED") | "# terragrunt import oci_mysql_mysql_db_system.this \(.id) # \(.["display-name"])"' >> $IMPORT_FILE

echo -e "\n${GREEN}=== Dynamic Routing Gateways (DRGs) ===${NC}"
DRG_LIST=$(oci network drg list \
    --compartment-id "$COMPARTMENT_ID" \
    --region "$REGION" \
    --all 2>/dev/null || echo '{"data":[]}')

echo "$DRG_LIST" | jq -r '.data[] | "  DRG: \(.["display-name"]) | OCID: \(.id)"'

echo "" >> $IMPORT_FILE
echo "# Dynamic Routing Gateways" >> $IMPORT_FILE
echo "$DRG_LIST" | jq -r '.data[] | "# terragrunt import oci_core_drg.this \(.id) # \(.["display-name"])"' >> $IMPORT_FILE

echo -e "\n${GREEN}=== CPE (Customer Premises Equipment) ===${NC}"
CPE_LIST=$(oci network cpe list \
    --compartment-id "$COMPARTMENT_ID" \
    --region "$REGION" \
    --all 2>/dev/null || echo '{"data":[]}')

echo "$CPE_LIST" | jq -r '.data[] | "  CPE: \(.["display-name"]) | OCID: \(.id) | IP: \(.["ip-address"])"'

echo -e "\n${GREEN}=== IPSec Connections ===${NC}"
IPSEC_LIST=$(oci network ip-sec-connection list \
    --compartment-id "$COMPARTMENT_ID" \
    --region "$REGION" \
    --all 2>/dev/null || echo '{"data":[]}')

echo "$IPSEC_LIST" | jq -r '.data[] | "  IPSec: \(.["display-name"]) | OCID: \(.id) | State: \(.["lifecycle-state"])"'

echo -e "\n${GREEN}=== Vaults ===${NC}"
VAULT_LIST=$(oci kms management vault list \
    --compartment-id "$COMPARTMENT_ID" \
    --region "$REGION" \
    --all 2>/dev/null || echo '{"data":[]}')

echo "$VAULT_LIST" | jq -r '.data[] | select(.["lifecycle-state"] != "DELETED") | "  Vault: \(.["display-name"]) | OCID: \(.id) | State: \(.["lifecycle-state"])"'

echo -e "\n${GREEN}=== Object Storage Buckets ===${NC}"
# Get namespace first
NAMESPACE=$(oci os ns get 2>/dev/null | jq -r '.data' || echo "unknown")
echo -e "  Namespace: $NAMESPACE"

BUCKET_LIST=$(oci os bucket list \
    --compartment-id "$COMPARTMENT_ID" \
    --namespace "$NAMESPACE" \
    --region "$REGION" \
    --all 2>/dev/null || echo '{"data":[]}')

echo "$BUCKET_LIST" | jq -r '.data[] | "  Bucket: \(.name)"'

echo -e "\n${GREEN}=== Custom Images ===${NC}"
IMAGE_LIST=$(oci compute image list \
    --compartment-id "$COMPARTMENT_ID" \
    --region "$REGION" \
    --all 2>/dev/null || echo '{"data":[]}')

echo "$IMAGE_LIST" | jq -r '.data[] | select(.["base-image-id"] != null or .["compartment-id"] == env.COMPARTMENT_ID) | "  Image: \(.["display-name"]) | OCID: \(.id)"' | head -20

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Import commands written to: $IMPORT_FILE${NC}"
echo -e "${BLUE}========================================${NC}"

chmod +x $IMPORT_FILE
echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Review the import commands in $IMPORT_FILE"
echo "2. Update the terragrunt.hcl files with the correct resource references"
echo "3. Run terragrunt init in each module directory"
echo "4. Execute the import commands as needed"
