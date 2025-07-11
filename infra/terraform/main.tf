data "azurerm_client_config" "current" {}

locals {
  # These values will not change at run time hence not making them configurable variables
  # The values of the Subscription IDs will not change at run time hence not making them configurable variables
  pmap_subscription_id = "d238c5e1-9db0-4605-a0c6-e8d0af3ecf8d"

  # Default set of tags to apply to resources. These tags will be merged with any additional tags provided.
  # See "Tagging Conventions" Document - https://confluence.jh.edu/x/FJe9F.
  default_tags = {
    "ApplicationName" = "Healthcare General Reasoner - OpenAI API Simulator"
    "Approver"        = "cyoun112@jh.edu"
    "Owner"           = "cyoun112@jh.edu"
    "Jira"            = "HGR-1015"
    "ManagedBy"       = "Terraform"
    "Repo"            = "https://github.com/JH-HEALTHIT/aoai-api-simulator"

    # Otherwise, Terraform wants to "update" this tag like so if not provided:
    # ~ tags                  = {
    #     - "cmdb_pas"        = "" -> null
    "cmdb_pas" = ""
  }

  tags = merge(local.default_tags, var.additional_tags)

  default_namespace_labels = {
    "app.kubernetes.io/managed-by" = "terraform"
  }
}

data "azurerm_kubernetes_cluster" "pmap" {
  provider            = azurerm.pmap
  name                = var.aks_cluster_name
  resource_group_name = var.aks_cluster_rg
}

data "azurerm_cognitive_account" "openai" {
  name                = var.openai_account_name
  resource_group_name = var.openai_account_rg
}

##-----------------------------------------------------------------------------
# Security Groups
##-----------------------------------------------------------------------------
data "azuread_group" "healthit_hgr_vte_admins" {
  display_name     = "healthit-hgr-vte-admins"
  security_enabled = true
}

data "azuread_group" "healthit_hgr_vte_ms_read" {
  display_name     = "healthit-hgr-vte-ms-read"
  security_enabled = true
}

data "azuread_group" "healthit_hgr_vte_ms_users" {
  display_name     = "healthit-hgr-vte-ms-users"
  security_enabled = true
}

data "azuread_group" "hgr_msft_az_users" {
  display_name     = "hgr-msft-az-users"
  security_enabled = true
}

data "azuread_group" "hlt_pie_devops" {
  display_name     = "hlt-pie-devops"
  security_enabled = true
}
