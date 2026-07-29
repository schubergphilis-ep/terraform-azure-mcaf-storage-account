resource "azurerm_key_vault" "this" {
  #checkov:skip=CKV_AZURE_42:test fixture, not production configuration
  #checkov:skip=CKV_AZURE_189:test fixture, not production configuration
  #checkov:skip=CKV_AZURE_110:test fixture, not production configuration
  #checkov:skip=CKV_AZURE_109:test fixture, not production configuration
  #checkov:skip=CKV2_AZURE_32:test fixture, not production configuration
  name                = "test-kv"
  location            = "westeurope"
  resource_group_name = "rg-test"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
  sku_name            = "standard"
}

resource "azurerm_key_vault_key" "this" {
  #checkov:skip=CKV_AZURE_40:test fixture, not production configuration
  #checkov:skip=CKV_AZURE_112:test fixture, not production configuration
  name         = "test-key"
  key_vault_id = azurerm_key_vault.this.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["wrapKey", "unwrapKey"]
}

module "storage_account" {
  source = "../../.."

  name                = "teststorageaccount"
  resource_group_name = "rg-test"
  location            = "westeurope"

  cmk_key = {
    key_vault_id = azurerm_key_vault.this.id
    key_name     = azurerm_key_vault_key.this.name
  }
}

output "storage_account_name" {
  value = module.storage_account.name
}
