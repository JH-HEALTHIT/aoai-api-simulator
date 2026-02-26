##-----------------------------------------------------------------------------
## Optional
##-----------------------------------------------------------------------------
variable "target_subscription_id" {
  type        = string
  nullable    = false
  default     = "a0a4da4d-ddc2-45c9-9af9-f772abd9cca1"
  description = "The target Azure Subscription ID."
}

variable "prefix" {
  type        = string
  nullable    = false
  default     = "aoaisim"
  description = "Prefix for Azure resource names. (default: aoaisim)"
}

variable "region" {
  type        = string
  nullable    = false
  default     = "eastus"
  description = "Azure location where the resources will be created. (default: eastus)"
}

variable "account_replication_type" {
  type        = string
  nullable    = false
  default     = "LRS"
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
}

variable "aks_cluster_name" {
  type        = string
  nullable    = false
  default     = "hit-nonprod-aks"
  description = "Name of the HIT AKS cluster to use."
}

variable "aks_cluster_id_name" {
  type        = string
  nullable    = false
  default     = "hit-nonprod-aks-id"
  description = "Name of the HIT AKS cluster ID to use."
}

variable "aks_cluster_rg" {
  type        = string
  nullable    = false
  default     = "hit-nonprod-aks-rg"
  description = "Resource Group of the HIT AKS cluster to use."
}

variable "hgr_vnet_name" {
  type        = string
  nullable    = false
  default     = "AZ-East-JH-HEALTHIT-PROD-10-209-4-0_24"
  description = "The name of the VNET that hosts HGR."
}

variable "hgr_vnet_rg" {
  type        = string
  nullable    = false
  default     = "JH-HEALTHIT-PROD-RG"
  description = "Resource Group of the VNET that hosts HGR."
}

variable "hgr_snet_default_name" {
  type        = string
  nullable    = false
  default     = "hgr-nonprod-snet-10-209-4-0_26"
  description = "The name of the default subnet in the HGR VNET."
}

variable "hit_vnet_name" {
  type        = string
  nullable    = false
  default     = "AZ-East-JH-HIT-PLATFORM-PROD-10.208.137.0-24"
  description = "The name of the VNET that hosts the HIT cluster."
}

variable "hit_vnet_rg" {
  type        = string
  nullable    = false
  default     = "INFRASTRUCTURE-SVI-USE-ONLY-RG"
  description = "Resource Group of the VNET that hosts the HIT cluster."
}

variable "hit_snet_name" {
  type        = string
  nullable    = false
  default     = "hit-nonprod-aks-snet"
  description = "The name of the subnet for the HIT cluster."
}

variable "openai_account_name" {
  type        = string
  nullable    = false
  default     = "aigateway-llm-test-oai-eastus"
  description = "Name of the Azure OpenAI account to use."
}

variable "openai_account_rg" {
  type        = string
  nullable    = false
  default     = "aigateway-test-rg"
  description = "Resource Group of the Azure OpenAI account to use."
}

variable "additional_tags" {
  type        = map(any)
  description = <<-EOT
    Additional tags to apply to resources. These tags will be merged with the default tags.
    See "Tagging Conventions" Document - https://confluence.jh.edu/x/FJe9F.
  EOT
  default     = {}
}

variable "storage_account_tier" {
  type        = string
  nullable    = true
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium."
  default     = "Standard"
}

variable "allowed_ip_ranges" {
  type        = list(any)
  description = "List of public IP or IP ranges in CIDR Format that are allowed to access Azure resources. Only IPv4 addresses are allowed. Default includes commonly used JH IPs for access and Azure DevOps."
  default = [
    "162.129.0.0/16",
    "128.220.0.0/16",
    "198.57.32.0/21",
    "198.57.40.0/22",
    "204.124.184.0/22",
    "20.37.158.0/23", # DevOps Central US https://learn.microsoft.com/en-us/azure/devops/organizations/security/allow-list-ip-url?view=azure-devops&tabs=IP-V4#inbound-connections
  ]
}

## AKS
variable "namespace_annotations" {
  type        = map(any)
  description = "An unstructured key value map stored with the namespace that may be used to store arbitrary metadata."
  default     = {}
}

variable "additional_namespace_labels" {
  type        = map(any)
  description = "Map of string keys and values that can be used to organize and categorize (scope and select) namespaces. May match selectors of replication controllers and services."
  default     = {}
}
