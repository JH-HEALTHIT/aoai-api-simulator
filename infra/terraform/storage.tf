resource "azurerm_storage_account" "storage" {
  name                            = "hgr${var.prefix}stor01"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.account_replication_type
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
  tags                            = local.tags

  network_rules {
    default_action = "Deny"
    ip_rules       = var.allowed_ip_ranges
  }

  blob_properties {
    container_delete_retention_policy {
      days = 7
    }
    delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_share" "simulator" {
  name               = "simulator"
  storage_account_id = azurerm_storage_account.storage.id
  quota              = 5120 # Set quota as needed
}
