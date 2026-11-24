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

# Example for environments where Azure Policy denies storage accounts without CMK encryption:
# the CMK is part of the storage account create request instead of being attached afterwards.

data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "storage" {
  name                = "id-storage-cmk"
  location            = "West Europe"
  resource_group_name = "rg-example"
}

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

# The user-assigned identity must be able to use the key before the storage account is created.
resource "azurerm_role_assignment" "storage_cmk" {
  scope                = azurerm_key_vault_key.this.resource_versionless_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.storage.principal_id
}

module "storage_account" {
  source = "../.."

  name                     = "stexamplecmk"
  resource_group_name      = "rg-example"
  location                 = "West Europe"
  user_assigned_identities = [azurerm_user_assigned_identity.storage.id]

  cmk_key = {
    resource_versionless_id = azurerm_key_vault_key.this.resource_versionless_id
    versionless_id          = azurerm_key_vault_key.this.versionless_id
    attach_on_create        = true
  }

  depends_on = [azurerm_role_assignment.storage_cmk]
}
