terraform {
  required_version = "~> 1.11"

  required_providers {
    # https://registry.terraform.io/providers/hashicorp/azuread/latest
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.4"
    }
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.36"
    }
    # https://registry.terraform.io/providers/hashicorp/helm/latest
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    # https://registry.terraform.io/providers/hashicorp/kubernetes/latest
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    # https://registry.terraform.io/providers/hashicorp/random/latest
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }

  backend "azurerm" {
    resource_group_name  = "common-rg"
    container_name       = "terraform-state"
    key                  = "aoai-simulator.tfstate"
    storage_account_name = "hithgrnonprodterrastor"
    subscription_id      = "a0a4da4d-ddc2-45c9-9af9-f772abd9cca1"
  }
}

provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

provider "azurerm" {
  resource_provider_registrations = "none"
  subscription_id                 = var.target_subscription_id

  features {}
}

provider "azurerm" {
  alias                           = "esg"
  resource_provider_registrations = "none"
  subscription_id                 = local.esg_subscription_id

  features {}
}

provider "azurerm" {
  alias                           = "hit"
  resource_provider_registrations = "none"
  subscription_id                 = local.hit_subscription_id

  features {}
}

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = var.aks_cluster_name
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.aks_cluster_name
}

provider "random" {
}
