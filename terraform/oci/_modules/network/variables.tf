variable "tenancy_ocid" {
  description = "OCID of the OCI tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the OCI user"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the OCI API key"
  type        = string
}

variable "private_key_path" {
  description = "Path to the OCI API private key"
  type        = string
}

variable "region" {
  description = "OCI region"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, dev)"
  type        = string
}

variable "vcn_cidr_blocks" {
  description = "List of CIDR blocks for the VCN"
  type        = list(string)
  default     = ["192.168.223.0/24"]
}

variable "subnets" {
  description = "Subnet configuration for edge, app, data, and spare tiers"
  type = object({
    edge = object({
      cidr = string
    })
    app = object({
      cidr = string
    })
    data = object({
      cidr = string
    })
    spare = object({
      cidr = string
    })
  })
  default = {
    edge = {
      cidr = "192.168.223.0/26"
    }
    app = {
      cidr = "192.168.223.64/26"
    }
    data = {
      cidr = "192.168.223.128/26"
    }
    spare = {
      cidr = "192.168.223.192/26"
    }
  }
}

variable "enable_vpn" {
  description = "Enable VPN connectivity (creates DRG)"
  type        = bool
  default     = false
}

variable "remote_networks" {
  description = "Map of remote networks accessible via VPN"
  type = map(object({
    cidr        = string
    description = string
  }))
  default = {}
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
}