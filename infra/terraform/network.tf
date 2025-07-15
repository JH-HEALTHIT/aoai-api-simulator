data "azurerm_subnet" "hgr-default" {
  name                 = var.hgr_snet_default_name
  virtual_network_name = var.hgr_vnet_name
  resource_group_name  = var.hgr_vnet_rg
}

data "azurerm_private_dns_zone" "file" {
  provider            = azurerm.esg
  name                = "privatelink.file.core.windows.net"
  resource_group_name = "esg-azuredns"
}

data "azurerm_private_dns_zone" "keyvault" {
  provider            = azurerm.esg
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = "esg-azuredns"
}
