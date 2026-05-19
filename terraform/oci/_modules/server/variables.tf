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

variable "shape" {
  description = "Shape of the instance"
  type        = string
  default     = "VM.Standard.A1.Flex"  # Free tier ARM instance
}

variable "image_ocid" {
  description = "OCID of the image to use for the instance"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
}

variable "subnet_id" {
  description = "ID of the app subnet"
  type        = string
}

variable "network_security_group_id" {
  description = "ID of the Network Security Group"
  type        = string
}

variable "ocpus" {
  description = "Number of OCPUs for the instance"
  type        = number
  default     = 2  # 2 OCPUs per server (total 4 for 2 servers = free tier limit)
}

variable "memory_in_gbs" {
  description = "Amount of memory in GBs for the instance"
  type        = number
  default     = 12  # 12GB per server (total 24GB for 2 servers = free tier limit)
}

variable "vcn_id" {
  description = "ID of the VCN"
  type        = string
}

variable "servers" {
  description = "Map of servers to create"
  type = map(object({
    fault_domain = number
    private_ip   = optional(string)
  }))
  default = {
    "fd1" = { fault_domain = 0 }
    "fd2" = { fault_domain = 1 }
  }
}

variable "k3s_url" {
  description = "URL of the existing k3s server to join as an agent (e.g. https://192.168.19.10:6443). Empty disables agent mode."
  type        = string
  default     = ""
}

variable "k3s_token" {
  description = "Node token of the existing k3s cluster. Read from /var/lib/rancher/k3s/server/node-token on the server. Must be non-empty if k3s_url is set, otherwise cloud-init silently produces a broken k3s-agent service."
  type        = string
  sensitive   = true
  default     = ""

  validation {
    condition     = var.k3s_token == "" || length(var.k3s_token) >= 16
    error_message = "k3s_token looks too short to be a real K3S node-token. Get the real value via: ssh firefly \"sudo cat /var/lib/rancher/k3s/server/node-token\""
  }
}

variable "cloud_init_rebuild_token" {
  description = "Opt-in escape hatch for forcing a VM rebuild after a meaningful cloud-init edit. Set to any non-empty value (e.g. \"2026-05-19\" or \"1\") to fold it into the user_data hash so existing VMs replace. Leave empty (the default) and routine applies won't replace VMs purely because the install script's wording changed."
  type        = string
  default     = ""
}
