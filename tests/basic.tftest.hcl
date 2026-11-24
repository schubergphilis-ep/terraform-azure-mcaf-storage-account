mock_provider "azurerm" {}

variables {
  name                = "sttestcore"
  resource_group_name = "rg-test"
  location            = "westeurope"
}

run "no_identity_and_no_cmk_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_storage_account.this.identity) == 0
    error_message = "No identity should be configured by default."
  }

  assert {
    condition     = length(azurerm_storage_account.this.customer_managed_key) == 0
    error_message = "No CMK should be configured when cmk_key is not set."
  }

  assert {
    condition     = azurerm_storage_account.this.queue_encryption_key_type == "Service"
    error_message = "queue_encryption_key_type should default to 'Service' when no CMK is configured and enable_cmk_encryption is false."
  }
}

run "cmk_set_inline_on_storage_account" {
  command = plan

  variables {
    cmk_key = {
      key_vault_key_id          = "https://mykeyvault.vault.azure.net/keys/my-key"
      user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cmk"
    }
  }

  assert {
    condition     = length(azurerm_storage_account.this.customer_managed_key) == 1
    error_message = "The CMK should be set on the storage account itself, so it is part of the create request."
  }

  assert {
    condition     = azurerm_storage_account.this.customer_managed_key[0].key_vault_key_id == "https://mykeyvault.vault.azure.net/keys/my-key"
    error_message = "The CMK should use the given key id."
  }

  assert {
    condition     = azurerm_storage_account.this.customer_managed_key[0].user_assigned_identity_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cmk"
    error_message = "The CMK should use the given user-assigned identity."
  }

  assert {
    condition     = azurerm_storage_account.this.identity[0].type == "UserAssigned"
    error_message = "The storage account should only use a user-assigned identity."
  }

  assert {
    condition     = contains(azurerm_storage_account.this.identity[0].identity_ids, "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cmk")
    error_message = "The CMK identity should be attached to the storage account automatically."
  }

  assert {
    condition     = azurerm_storage_account.this.queue_encryption_key_type == "Account"
    error_message = "queue_encryption_key_type should switch to 'Account' when cmk_key is set."
  }
}

run "cmk_identity_not_duplicated" {
  command = plan

  variables {
    user_assigned_identities = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cmk"]
    cmk_key = {
      key_vault_key_id          = "https://mykeyvault.vault.azure.net/keys/my-key"
      user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-cmk"
    }
  }

  assert {
    condition     = length(azurerm_storage_account.this.identity[0].identity_ids) == 1
    error_message = "The CMK identity should not be added twice when it is also in user_assigned_identities."
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
