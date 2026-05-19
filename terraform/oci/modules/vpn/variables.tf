variable "tenancy_ocid" {
  description = "OCID of the OCI tenancy"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "region" {
  description = "OCI region"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, dev)"
  type        = string
}

variable "drg_id" {
  description = "OCID of the Dynamic Routing Gateway"
  type        = string
}

variable "local_networks" {
  description = "List of local network CIDRs to advertise over VPN"
  type        = list(string)
  default     = ["192.168.223.0/24"]
}

variable "vpn_connections" {
  description = "Map of VPN connections to create"
  type = map(object({
    # CPE configuration
    peer_ip             = string           # Public IP of the remote VPN endpoint
    cpe_device_shape_id = optional(string) # CPE device shape ID (null for generic)
    type                = string           # Type of connection: "aws", "mikrotik", "other"

    # Routing configuration
    static_routes = list(string) # Remote network CIDRs
    routing_type  = string       # "STATIC" or "BGP"

    # BGP configuration (required if routing_type = "BGP")
    bgp_asn                = optional(number)
    bgp_customer_ip_tunnel1 = optional(string)
    bgp_oracle_ip_tunnel1   = optional(string)
    bgp_customer_ip_tunnel2 = optional(string)
    bgp_oracle_ip_tunnel2   = optional(string)

    # IKE configuration
    ike_version = optional(string, "V2") # "V1" or "V2"

    # Pre-shared keys (auto-generated if not provided)
    shared_secret_tunnel1 = optional(string)
    shared_secret_tunnel2 = optional(string)
  }))
  default = {}
}
