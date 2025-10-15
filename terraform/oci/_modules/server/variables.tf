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
  # Default to Oracle Linux 8 for ARM
  default     = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaafkbieqzlgvjlnvdkfzoyy6at5n3xk2nu5wkmu7otjz6wxfn6eqnq"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "network_security_group_id" {
  description = "ID of the Network Security Group"
  type        = string
}

variable "ocpus" {
  description = "Number of OCPUs for the instance"
  type        = number
  default     = 4  # Free tier allows up to 4 OCPUs
}

variable "memory_in_gbs" {
  description = "Amount of memory in GBs for the instance"
  type        = number
  default     = 24  # Free tier allows up to 24 GB RAM
}

variable "vcn_id" {
  description = "ID of the VCN"
  type        = string
}

variable "servers" {
  description = "Map of servers to create"
  type        = map(object({
    fault_domain    = number
    subnet_cidr     = string
    edge_instance_key = string  # Key to lookup the edge instance from edge module outputs
  }))
  default = {}
}