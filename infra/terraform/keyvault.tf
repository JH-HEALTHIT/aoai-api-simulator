resource "azurerm_key_vault" "kv" {
  name                          = "hgr-${var.prefix}-kv"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  tags                          = local.tags
  purge_protection_enabled      = true
  rbac_authorization_enabled    = true
  public_network_access_enabled = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.allowed_ip_ranges
  }
}

##-----------------------------------------------------------------------------
## Private endpoint
##-----------------------------------------------------------------------------
resource "azurerm_private_endpoint" "kv" {
  name                          = "hgr-${var.prefix}-kv-pe"
  custom_network_interface_name = "hgr-${var.prefix}-kv-pe-nic"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  subnet_id                     = data.azurerm_subnet.hgr-default.id
  tags                          = local.tags

  private_service_connection {
    name                           = "hgr-${var.prefix}-kv-pe"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.keyvault.id]
  }
}


resource "azurerm_key_vault_secret" "openai_key" {
  depends_on   = [azurerm_role_assignment.kv_role_assignments]
  name         = "azure-openai-key"
  value        = data.azurerm_cognitive_account.openai.primary_access_key
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "simulator_api_key" {
  depends_on   = [azurerm_role_assignment.kv_role_assignments]
  name         = "simulator-api-key"
  value        = random_password.simulator_api_key.result
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "app_insights" {
  depends_on   = [azurerm_role_assignment.kv_role_assignments]
  name         = "app-insights-connection-string"
  value        = azurerm_application_insights.app_insights.connection_string
  key_vault_id = azurerm_key_vault.kv.id
}

resource "random_password" "simulator_api_key" {
  length  = 16
  special = true
}

##-----------------------------------------------------------------------------
## Role assignments
##-----------------------------------------------------------------------------

# Map the AD groups and their corresponding role assignments
locals {
  ad_groups = {
    "Key Vault Administrator" = [
      data.azuread_group.healthit_hgr_vte_admins,
      data.azuread_group.hlt_pie_devops,
    ]
    "Key Vault Reader" = [
      data.azuread_group.healthit_hgr_vte_ms_read,
      data.azuread_group.healthit_hgr_vte_ms_users
    ]
    "Key Vault Secrets Officer" = [
      data.azuread_group.hgr_msft_az_users
    ]
    "Key Vault Secrets User" = [
      data.azuread_group.healthit_hgr_vte_ms_read,
      data.azuread_group.healthit_hgr_vte_ms_users
    ]
  }
  kv_roles_objects = {
    "Key Vault Secrets User" = [
      data.azurerm_kubernetes_cluster.hit.kubelet_identity[0]
    ]
  }

  # Flatten the map into a list of maps
  flattened_ad_groups = flatten([
    for role, groups in local.ad_groups : [
      for group in groups : {
        role           = role
        name           = group.display_name
        object_id      = group.object_id
        principal_type = "Group"
      }
    ]
  ])

  # Flatten the map into a list of maps
  flattened_kv_roles = flatten([
    for role, identities in local.kv_roles_objects : [
      for identity in identities : {
        role           = role
        name           = identity.client_id
        object_id      = identity.object_id
        principal_type = "ServicePrincipal"
      }
    ]
  ])

  combined_roles = concat(local.flattened_ad_groups, local.flattened_kv_roles)
}

# Create multiple azurerm_role_assignment instances using a loop
resource "azurerm_role_assignment" "kv_role_assignments" {
  for_each = { for group in local.combined_roles : "${group.role}_${group.name}" => group }

  scope                = azurerm_key_vault.kv.id
  role_definition_name = each.value.role
  principal_id         = each.value.object_id
  principal_type       = each.value.principal_type
}
