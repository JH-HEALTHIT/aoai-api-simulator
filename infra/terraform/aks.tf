# AKS infrastructure for HGE applications
resource "kubernetes_namespace" "hgr-sim" {
  metadata {
    name        = "hgr-aoaisim-dev"
    labels      = local.default_namespace_labels
    annotations = {}
  }
}

resource "helm_release" "hgr-aoai-simulator" {
  name      = "hgr-aoai-simulator"
  namespace = kubernetes_namespace.hgr-sim.metadata[0].name
  chart     = "../helm/aoaisim"

  values = [
    templatefile("${path.module}/templates/sim-values.tftpl", {
      st_rg           = azurerm_resource_group.rg.name,
      st_name         = azurerm_storage_account.storage.name,
      st_key          = azurerm_storage_account.storage.primary_access_key,
      st_share        = azurerm_storage_share.simulator.name,
      openai_endpoint = data.azurerm_cognitive_account.openai.endpoint,
      image_tag       = "1.11.0",
      ingress_class   = "nginx-dev",
      hostname        = "hgr-aoaisim-dev.pm.jh.edu",
      tenant_id       = data.azurerm_client_config.current.tenant_id,
      client_id       = data.azurerm_kubernetes_cluster.pmap.kubelet_identity[0].client_id,
      kv_name         = azurerm_key_vault.kv.name
    })
  ]

  depends_on = [kubernetes_namespace.hgr-sim]
}

##-----------------------------------------------------------------------------
## Role assignments
##-----------------------------------------------------------------------------
locals {
  aks_groups = {
    healthit_hgr_vte_admins = data.azuread_group.healthit_hgr_vte_admins.object_id
    hgr_msft_az_users       = data.azuread_group.hgr_msft_az_users.object_id
  }
}

resource "azurerm_role_assignment" "aks_rbac_admin_ns" {
  for_each = { for key, value in local.aks_groups : key => value }

  scope                = "${data.azurerm_kubernetes_cluster.pmap.id}/namespaces/${kubernetes_namespace.hgr-sim.metadata[0].name}"
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
  principal_id         = each.value

  depends_on = [kubernetes_namespace.hgr-sim]
}
