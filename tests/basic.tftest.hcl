mock_provider "azurerm" {
  # The role assignment validates principal_id as a UUID, so the mocked identity needs real-looking ids.
  mock_resource "azurerm_user_assigned_identity" {
    defaults = {
      id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-sttestcore"
      principal_id = "11111111-1111-1111-1111-111111111111"
      client_id    = "22222222-2222-2222-2222-222222222222"
    }
  }

  # Runs after the apply run plan against its state, so child resources need a parseable account id.
  mock_resource "azurerm_storage_account" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Storage/storageAccounts/sttestcore"
    }
  }
}

mock_provider "time" {}

variables {
  name                = "sttestcore"
  resource_group_name = "rg-test"
  location            = "westeurope"
}

run "identity_created_without_cmk_by_default" {
  command = plan

  assert {
    condition     = azurerm_user_assigned_identity.this.name == "id-sttestcore"
    error_message = "The module should create a user-assigned identity named after the storage account."
  }

  assert {
    condition     = azurerm_storage_account.this.identity[0].type == "UserAssigned"
    error_message = "The storage account should only use a user-assigned identity."
  }

  assert {
    condition     = length(azurerm_storage_account.this.customer_managed_key) == 0
    error_message = "No CMK should be configured when cmk_key is not set."
  }

  assert {
    condition     = length(azurerm_role_assignment.cmk) == 0
    error_message = "No key role assignment should be created when cmk_key is not set."
  }

  assert {
    condition     = azurerm_storage_account.this.queue_encryption_key_type == "Service"
    error_message = "queue_encryption_key_type should default to 'Service' when no CMK is configured and enable_cmk_encryption is false."
  }
}

run "identity_name_configurable" {
  command = plan

  variables {
    identity_name = "id-custom"
  }

  assert {
    condition     = azurerm_user_assigned_identity.this.name == "id-custom"
    error_message = "identity_name should override the identity name."
  }
}

run "cmk_set_inline_with_module_identity" {
  command = plan

  variables {
    cmk_key = {
      resource_versionless_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.KeyVault/vaults/mykeyvault/keys/my-key"
      versionless_id          = "https://mykeyvault.vault.azure.net/keys/my-key"
    }
  }

  assert {
    condition     = length(azurerm_storage_account.this.customer_managed_key) == 1
    error_message = "The CMK should be set on the storage account itself, so it is part of the create request."
  }

  assert {
    condition     = azurerm_storage_account.this.customer_managed_key[0].key_vault_key_id == "https://mykeyvault.vault.azure.net/keys/my-key"
    error_message = "The CMK should use the versionless key id."
  }

  assert {
    condition     = azurerm_role_assignment.cmk[0].scope == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.KeyVault/vaults/mykeyvault/keys/my-key"
    error_message = "The key role assignment should be scoped to the key (least privilege)."
  }

  assert {
    condition     = azurerm_role_assignment.cmk[0].role_definition_name == "Key Vault Crypto Service Encryption User"
    error_message = "The identity should be granted 'Key Vault Crypto Service Encryption User' on the key."
  }

  assert {
    condition     = azurerm_storage_account.this.queue_encryption_key_type == "Account"
    error_message = "queue_encryption_key_type should switch to 'Account' when cmk_key is set."
  }
}

# Applies with a CMK, then changes the key, to check the plan has no dependency cycle between the
# create_before_destroy role assignment, the propagation wait and the storage account.
run "cmk_applied" {
  command = apply

  variables {
    cmk_key = {
      resource_versionless_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.KeyVault/vaults/mykeyvault/keys/my-key"
      versionless_id          = "https://mykeyvault.vault.azure.net/keys/my-key"
    }
  }

  assert {
    condition     = azurerm_storage_account.this.customer_managed_key[0].user_assigned_identity_id == azurerm_user_assigned_identity.this.id
    error_message = "The CMK should use the module's identity."
  }

  assert {
    condition     = azurerm_role_assignment.cmk[0].principal_id == azurerm_user_assigned_identity.this.principal_id
    error_message = "The key role assignment should be for the module's identity."
  }
}

run "cmk_key_change_plans_without_cycle" {
  command = plan

  variables {
    cmk_key = {
      resource_versionless_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.KeyVault/vaults/mykeyvault/keys/my-new-key"
      versionless_id          = "https://mykeyvault.vault.azure.net/keys/my-new-key"
    }
  }

  assert {
    condition     = azurerm_storage_account.this.customer_managed_key[0].key_vault_key_id == "https://mykeyvault.vault.azure.net/keys/my-new-key"
    error_message = "Changing the key should update the CMK on the storage account in place."
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
