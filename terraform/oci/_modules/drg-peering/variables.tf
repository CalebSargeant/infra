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

variable "drg_id" {
  description = "OCID of the local DRG"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, dev)"
  type        = string
}

variable "peer_region" {
  description = "Name of the peer region (e.g., eu-amsterdam-1)"
  type        = string
}
