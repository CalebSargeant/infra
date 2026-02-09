variable "tenancy_ocid" {
  description = "OCID of the OCI tenancy"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of the compartment (typically tenancy OCID for root-level policies)"
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

variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
}

variable "description" {
  description = "Description of the policy"
  type        = string
}

variable "statements" {
  description = "List of policy statements"
  type        = list(string)
}
