variable "tenancy_ocid" {
  description = "OCID of the OCI tenancy"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "vcn_id" {
  description = "OCID of the VCN"
  type = string
}

variable "environment" {
  description = "Environment name (e.g., prod, dev)"
  type        = string
}

variable "shape" {
  description = "Shape of the instance"
  type        = string
  default     = "VM.Standard.E2.1.Micro"  # Free tier x86 instance
}

variable "image_ocid" {
  description = "OCID of the image to use for the instance"
  type        = string
  # Default to Oracle Linux 8 for x86
  default     = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaawxrjyvekcjkpi3zo6x3fphepbrjrbvr2dkcdxwir7xdwpv2yfvqa"
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

variable "fault_domains" {
  description = "Map of fault domains to create instances in"
  type        = map(object({
    fault_domain = number
  }))
  default = {
    "fd1" = { fault_domain = 0 }
  }
}
