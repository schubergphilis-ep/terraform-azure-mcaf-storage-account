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

# The network rules must be part of the storage account create request, so the
# secure defaults (Deny, no IP rules) are set on the account itself.
run "network_rules_set_on_storage_account_with_secure_defaults" {
  command = plan

  assert {
    condition     = length(azurerm_storage_account.this.network_rules) == 1
    error_message = "Network rules should be configured on the storage account itself, not in a separate resource."
  }

  assert {
    condition     = azurerm_storage_account.this.network_rules[0].default_action == "Deny"
    error_message = "The default network action should be Deny."
  }

  assert {
    condition     = length(azurerm_storage_account.this.network_rules[0].ip_rules) == 0
    error_message = "No IP rules should be configured by default."
  }
}

# Policies can restrict the allowed bypass values (e.g. only None), so the
# value from network_configuration must reach the storage account.
run "network_rules_bypass_configurable" {
  command = plan

  variables {
    network_configuration = {
      bypass = ["None"]
    }
  }

  assert {
    condition     = contains(azurerm_storage_account.this.network_rules[0].bypass, "None") && length(azurerm_storage_account.this.network_rules[0].bypass) == 1
    error_message = "The bypass value from network_configuration should be set on the storage account."
  }
}

run "cmk_attached_on_create" {
  command = plan

  variables {
    user_assigned_identities = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cmk"]
    cmk_key = {
      resource_versionless_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.KeyVault/vaults/mykeyvault/keys/my-key"
      versionless_id          = "https://mykeyvault.vault.azure.net/keys/my-key"
      attach_on_create        = true
    }
  }

  assert {
    condition     = length(azurerm_storage_account.this.customer_managed_key) == 1
    error_message = "CMK should be set inline on the storage account when attach_on_create is true."
  }

  assert {
    condition     = azurerm_storage_account.this.customer_managed_key[0].key_vault_key_id == "https://mykeyvault.vault.azure.net/keys/my-key"
    error_message = "Inline CMK should use the versionless key id."
  }

  assert {
    condition     = azurerm_storage_account.this.customer_managed_key[0].user_assigned_identity_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cmk"
    error_message = "Inline CMK should use the first user assigned identity."
  }

  assert {
    condition     = length(azurerm_storage_account_customer_managed_key.this) == 0
    error_message = "The standalone CMK resource should not be created when attach_on_create is true."
  }

  assert {
    condition     = length(azurerm_role_assignment.cmk) == 0
    error_message = "No CMK role assignment should be created when attach_on_create is true."
  }

  assert {
    condition     = azurerm_storage_account.this.queue_encryption_key_type == "Account"
    error_message = "queue_encryption_key_type should be 'Account' when a CMK is attached on create."
  }
}

run "cmk_attach_on_create_requires_user_assigned_identity" {
  command = plan

  variables {
    cmk_key = {
      resource_versionless_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.KeyVault/vaults/mykeyvault/keys/my-key"
      versionless_id          = "https://mykeyvault.vault.azure.net/keys/my-key"
      attach_on_create        = true
    }
  }

  expect_failures = [var.cmk_key]
}

run "cmk_not_inline_by_default" {
  command = plan

  variables {
    cmk_key = {
      resource_versionless_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.KeyVault/vaults/mykeyvault/keys/my-key"
      versionless_id          = "https://mykeyvault.vault.azure.net/keys/my-key"
    }
  }

  assert {
    condition     = length(azurerm_storage_account.this.customer_managed_key) == 0
    error_message = "CMK should not be set inline unless attach_on_create is true."
  }

  assert {
    condition     = length(azurerm_role_assignment.cmk) == 1
    error_message = "The system-assigned identity should still be granted access to the key in the default mode."
  }
}
