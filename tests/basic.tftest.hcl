mock_provider "azurerm" {}

variables {
  name                = "sttestcore"
  resource_group_name = "rg-test"
  location            = "westeurope"
}

run "cmk_not_attached_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_storage_account_customer_managed_key.this) == 0
    error_message = "CMK association should not be created when cmk_key is not set."
  }

  assert {
    condition     = azurerm_storage_account.this.queue_encryption_key_type == "Service"
    error_message = "queue_encryption_key_type should default to 'Service' when no CMK is configured and enable_cmk_encryption is false."
  }
}

run "cmk_attached_with_known_values" {
  command = plan

  variables {
    cmk_key = {
      key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/test-kv"
      key_name     = "test-key"
    }
  }

  assert {
    condition     = length(azurerm_storage_account_customer_managed_key.this) == 1
    error_message = "CMK association should be created when cmk_key is set."
  }

  assert {
    condition     = azurerm_storage_account.this.queue_encryption_key_type == "Account"
    error_message = "queue_encryption_key_type should switch to 'Account' when cmk_key is set."
  }
}
