data "azurerm_client_config" "current" {}

locals {
  # These values will not change at run time hence not making them configurable variables
  # The values of the Subscription IDs will not change at run time hence not making them configurable variables
  esg_subscription_id = "9acba645-cdeb-4c07-87d7-5197d0858c58"
  hit_subscription_id = "55fbf412-20d9-4c4e-bef3-78958e1188db"

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
    "app.kubernetes.io/managed-by" = "terraform",
    "app.kubernetes.io/name"       = "hgr-aoaisim-dev",
    "app.kubernetes.io/instance"   = "hgr-aoaisim-dev",
    "app.kubernetes.io/component"  = "hgr-aoaisim-dev"
  }
}

data "azurerm_kubernetes_cluster" "hit" {
  provider            = azurerm.hit
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
