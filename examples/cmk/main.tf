terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4"
    }
  }
}

provider "azurerm" {
  features {}
}

# The module creates the storage account's identity, grants it access to the key, and sets the CMK
# in the create request, so this also works where Azure Policy denies storage accounts without CMK
# encryption.

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                       = "kv-storage-cmk"
  location                   = "West Europe"
  resource_group_name        = "rg-example"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  rbac_authorization_enabled = true
}

resource "azurerm_key_vault_key" "this" {
  name         = "storage-cmk"
  key_vault_id = azurerm_key_vault.this.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["wrapKey", "unwrapKey"]
}

module "storage_account" {
  source = "../.."

  name                = "stexamplecmk"
  resource_group_name = "rg-example"
  location            = "West Europe"

  cmk_key = {
    resource_versionless_id = azurerm_key_vault_key.this.resource_versionless_id
    versionless_id          = azurerm_key_vault_key.this.versionless_id
  }
}

# The storage account's identity can be granted access to other resources.
output "storage_account_principal_id" {
  value = module.storage_account.identity.principal_id
}
