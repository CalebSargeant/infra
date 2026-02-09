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
