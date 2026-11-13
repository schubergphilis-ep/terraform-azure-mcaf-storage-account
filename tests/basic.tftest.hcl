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
      resource_versionless_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.KeyVault/vaults/mykeyvault/keys/my-key"
      versionless_id          = "https://mykeyvault.vault.azure.net/keys/my-key"
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

run "local_users_enabled_by_default" {
  command = plan

  assert {
    condition     = azurerm_storage_account.this.local_user_enabled == true
    error_message = "local_user_enabled should default to true to keep the azurerm default behaviour."
  }
}

run "local_users_can_be_disabled" {
  command = plan

  variables {
    local_user_enabled = false
  }

  assert {
    condition     = azurerm_storage_account.this.local_user_enabled == false
    error_message = "local_user_enabled should be false when explicitly disabled."
  }
}

run "local_users_forced_on_by_sftp" {
  command = plan

  variables {
    local_user_enabled = false
    sftp_enabled       = true
    is_hns_enabled     = true
    sftp_local_user_config = [{
      name                = "sftpuser"
      ssh_authorized_keys = []
      permission_scopes   = []
    }]
  }

  assert {
    condition     = azurerm_storage_account.this.local_user_enabled == true
    error_message = "local_user_enabled must be true when sftp_enabled is true."
  }
}
