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
    default_action             = "Deny"
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = [data.azurerm_subnet.pmap-aks.id]
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

##-----------------------------------------------------------------------------
## Private endpoint
##-----------------------------------------------------------------------------
resource "azurerm_private_endpoint" "storage" {
  name                          = "hgr-${var.prefix}-stor-pe"
  custom_network_interface_name = "hgr-${var.prefix}-stor-pe-nic"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  subnet_id                     = data.azurerm_subnet.hgr-default.id
  tags                          = local.tags

  private_service_connection {
    name                           = "hgr-${var.prefix}-stor-pe"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.file.id]
  }
}
