resource "azurerm_key_vault" "this" {
  name                = "test-kv"
  location            = "westeurope"
  resource_group_name = "rg-test"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
  sku_name            = "standard"
}

resource "azurerm_key_vault_key" "this" {
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
    resource_versionless_id = azurerm_key_vault_key.this.resource_versionless_id
    versionless_id          = azurerm_key_vault_key.this.versionless_id
  }
}

output "storage_account_name" {
  value = module.storage_account.name
}
