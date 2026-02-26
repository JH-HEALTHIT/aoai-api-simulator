# AKS infrastructure for HGE applications
resource "kubernetes_namespace_v1" "hgr-sim" {
  metadata {
    name        = "hgr-aoaisim-dev"
    labels      = local.default_namespace_labels
    annotations = {}
  }
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

  scope                = "${data.azurerm_kubernetes_cluster.hit.id}/namespaces/${kubernetes_namespace_v1.hgr-sim.metadata[0].name}"
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
  principal_id         = each.value

  depends_on = [kubernetes_namespace_v1.hgr-sim]
}
